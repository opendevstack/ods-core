# -*- coding: utf-8 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
from importlib import import_module

import flask_login
from flask import url_for, redirect, request
# Need to expose these downstream
# flake8: noqa: F401
# noinspection PyUnresolvedReferences
from flask_login import current_user, logout_user, login_required, login_user
from flask_oauthlib.client import OAuth

from airflow import models, configuration
from airflow.utils.db import provide_session
from airflow.utils.log.logging_mixin import LoggingMixin

log = LoggingMixin().log


def get_config_param(param):
    return str(configuration.conf.get('oauth', param))


def has_config_param(param):
    return configuration.conf.has_option('oauth', param)


class OAuthUser(models.User):

    def __init__(self, user):
        self.user = user

    @property
    def is_active(self):
        """Required by flask_login"""
        return self.user

    @property
    def is_authenticated(self):
        """Required by flask_login"""
        return self.user

    @property
    def is_anonymous(self):
        """Required by flask_login"""
        return False

    def get_id(self):
        """Returns the current user id as required by flask_login"""
        return self.user.get_id()

    def data_profiling(self):
        """Provides access to data profiling tools"""
        return self.user.superuser if self.user else False

    def is_superuser(self):
        """Access all the things"""
        return self.user.superuser if self.user else False


class AuthenticationError(Exception):
    pass


class OAuthBackend(object):

    def __init__(self):
        self.login_manager = flask_login.LoginManager()
        self.login_manager.login_view = 'airflow.login'
        self.login_manager.login_message = None

        self.flask_app = None
        self.oauth = None
        self.api_rev = None

    def init_app(self, flask_app):
        self.flask_app = flask_app

        self.login_manager.init_app(self.flask_app)

        self.oauth = OAuth(self.flask_app).remote_app(
            'oauth',
            consumer_key=get_config_param('client_id'),
            consumer_secret=get_config_param('client_secret'),
            base_url=get_config_param('base_url'),
            request_token_params={'scope': [
                "user:info",
                "user:check-access"
            ]},
            request_token_url=None,
            access_token_method=get_config_param('access_token_method'),
            access_token_url=get_config_param('access_token_url'),
            authorize_url=get_config_param('authorize_url'))

        self.login_manager.user_loader(self.load_user)

        self.flask_app.add_url_rule(get_config_param('oauth_callback_route'),
                                    'oauth_callback',
                                    self.oauth_callback)

    def login(self, request):
        log.debug('Redirecting user to OAuth login')

        scheme = request.environ['HTTP_X_FORWARDED_PROTO'] \
            if 'HTTP_X_FORWARDED_PROTO' in request.environ and request.environ['HTTP_X_FORWARDED_PROTO'] \
            else request.scheme if request.scheme \
            else None

        return self.oauth.authorize(callback=url_for(
            'oauth_callback',
            _scheme=scheme,
            _external=True),
            state=request.args.get('next') or request.referrer or None)

    def get_user_profile_info(self, access_token):
        resp = self.oauth.get(
            get_config_param("user_info_url"),
            token=(access_token, ''))

        if not resp or resp.status != 200:
            raise AuthenticationError(
                'Failed to fetch user profile, status ({0})'.format(
                    resp.status if resp else 'None'))

        return resp.data

    def dict_get(self, dic, key):
        keys = key.split(".")
        value = dic
        for k in keys:
            value = value[k]

        return value

    @provide_session
    def load_user(self, userid, session=None):
        if not userid or userid == 'None':
            return None

        user = session.query(models.User).filter(
            models.User.id == int(userid)).first()
        return OAuthUser(user)

    def authorize(self, authorized_response, user_info):
        """

        Parameters
        ----------
        authorized_response
            Authorized response from OAuth client
        user_info: dict
            User information response from OAuth client

        Returns
        -------
        (bool, bool, bool)
            Return if 1. the user is allowed to access airflow, 2. if the user
            is a superuser
        """

        if has_config_param("oauth_permission_backend"):
            permission_backend = import_module(get_config_param("oauth_permission_backend"))
            return permission_backend.authorize(self.oauth, authorized_response, user_info)

        return True, True

    @provide_session
    def oauth_callback(self, session=None):
        log.debug('OAuth callback called')

        next_url = request.args.get('state') or url_for('admin.index')
        if get_config_param('base_url') in next_url:
            next_url = url_for('admin.index')

        resp = self.oauth.authorized_response()

        try:
            if resp is None:
                raise AuthenticationError(
                    'Null response from OAuth service, denying access.'
                )

            access_token = resp['access_token']

            user_info = self.get_user_profile_info(access_token)

            username_key = get_config_param("username_key")
            email_key = get_config_param("email_key")

            username = self.dict_get(user_info, username_key)
            email = self.dict_get(user_info, email_key)

            authorized, superuser = self.authorize(resp, user_info)

        except AuthenticationError:
            return redirect(url_for('airflow.noaccess'))

        user = session.query(models.User).filter(
            models.User.username == username).first()

        if not authorized:
            if user:
                session.delete(user)
                session.commit()
            return redirect(url_for('airflow.noaccess'))

        if not user:
            user = models.User(
                username=username,
                email=email,
                superuser=superuser)

        user.superuser = superuser

        session.merge(user)
        session.commit()
        login_user(OAuthUser(user))
        session.commit()

        return redirect(next_url)


login_manager = OAuthBackend()


def login(self, request):
    return login_manager.login(request)
