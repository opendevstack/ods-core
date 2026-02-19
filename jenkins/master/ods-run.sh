#!/bin/bash
#
# This script copies any init.groovy.d files under the control of OpenDevStack,
# then delegates to the original run script of the base image.
set -ue

echo "Deleting .kube to avoid weird caching issues (see https://github.com/opendevstack/ods-core/issues/473)"
rm -rf $HOME/.kube || true

# Openshift default CA. See https://docs.openshift.com/container-platform/3.11/dev_guide/secrets.html#service-serving-certificate-secrets
SERVICEACCOUNT_CA='/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt'
if [[ -f $SERVICEACCOUNT_CA ]]; then
  echo "INFO: found $SERVICEACCOUNT_CA"
  echo "INFO: importing into cacerts"
  $JAVA_HOME/bin/keytool -importcert -v -trustcacerts -alias service-ca -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -file "$SERVICEACCOUNT_CA" -noprompt
else
  echo "INFO: could not find '$SERVICEACCOUNT_CA'"
  echo "INFO: skip import"
fi

target_init_groovy_dir="${JENKINS_HOME}/init.groovy.d"
if [ -d "$target_init_groovy_dir" ] ; then
    # If the target dir does not exist yet, files under
    # /opt/openshift/configuration will be copied later by /usr/libexec/s2i/run.
    echo "Copy init.groovy.d files ..."
    source_init_groovy_dir="/opt/openshift/configuration/init.groovy.d"
    for f in ${source_init_groovy_dir}/*.groovy; do
        fileName=${f#${source_init_groovy_dir}'/'}
        echo "---> Copying ${source_init_groovy_dir}/${fileName} to ${target_init_groovy_dir}/${fileName} ..."
        cp "${source_init_groovy_dir}/${fileName}" "${target_init_groovy_dir}/${fileName}"
    done
    echo "Remove legacy init.groovy.d files ..."
    rm "${target_init_groovy_dir}/ods-mro-jenkins-shared-library.groovy" &> /dev/null || true
fi

echo "Copy grape config and amending with Nexus ..."
if [ -n "${NEXUS_URL:-}" ]; then
  nexusUrl="${NEXUS_URL}"
elif [ -n "${NEXUS_HOST:-}" ]; then
  nexusUrl="${NEXUS_HOST}"
else
  echo "ERROR: Neither NEXUS_URL or NEXUS_HOST present."
  exit 1
fi
NEXUS_SHORT=$(echo "${nexusUrl}" | sed -e "s|https://||g;s|http://||g")
mkdir -p $HOME/.groovy
cp /opt/openshift/configuration/grapeConfig.xml $HOME/.groovy/
sed -i -e "s|__NEXUS_HOST_NO_URL|$NEXUS_SHORT|g" \
    -e "s|__NEXUS_HOST|$nexusUrl|g" \
    -e "s|__NEXUS_USER|$NEXUS_USERNAME|g" \
    -e "s|__NEXUS_PW|$NEXUS_PASSWORD|g" $HOME/.groovy/grapeConfig.xml

if [ -e "${JENKINS_HOME}/plugins" ]; then
  # RHEL base images install plugins (defined in the yum package jenkins-2-plugins)
  # as *.hpi files via yum into /usr/lib/jenkins, and create a symlink from
  # /opt/openshift/plugins to the actual files at /usr/lib/jenkins.
  # During boot (contrib/s2i/run) a symlink is created for any plugins existing at
  # /usr/lib/jenkins but not in /var/lib/jenkins/plugins. This makes Jenkins
  # "see" and use the plugin.

  # CentOS base images install plugins (defined in /opt/openshift/base-plugins.txt)
  # as *.jpi files via /usr/local/bin/install-plugins.sh into /opt/openshift/plugins.

  # For both RHEL and CentOS, if there are plugins at /opt/openshift/plugins,
  # those are copied to /var/lib/jenkins/plugins on initial boot (or if
  # OVERRIDE_PV_PLUGINS_WITH_IMAGE_PLUGINS is set). For RHEL, this means copied plugins
  # loose the symlinked nature, for CentOS no links are in place anyway.

  # As ODS maintainers, we want to ensure that all plugins managed by either OpenShift
  # or added by us are always in the versions that we specify. We must ensure that
  # we can update plugins when we publish a new image. On the other hand, we want to
  # prevent manual plugin updates as we cannot guarantee that newer versions will work.
  # Further, in a regulated environment, the combination of plugins defined by ODS is
  # validated, so should not be modified by users anyway.

  # To achieve this, we copy all plugins at /opt/openshift/plugins
  # to /var/lib/jenkins/plugins during boot. RHEL then thinks we "manage the version", but
  # in fact we just copy the version defined by them - and since we do this on every boot,
  # it has the same effect that the symlinks would have.

  echo "Copy audit-trail plugin configuration ..."
  cp -n /opt/openshift/configuration/audit-trail.xml ${JENKINS_HOME}/audit-trail.xml

  echo " "
  echo "Enforcing plugin versions defined in the image ..."
  if [ -d /opt/openshift/plugins ] && [ -n "$(find /opt/openshift/plugins -maxdepth 1 -type f 2>/dev/null | head -1)" ]; then
    echo "Copying plugins to ${JENKINS_HOME} ..."
    
    # Remove all old plugin metadata directories at once
    find "${JENKINS_HOME}/plugins" -maxdepth 1 -type d \( -name "*.jpi" -o -name "*.hpi" \) -exec rm -rf {} + 2>/dev/null || true
    
    # Copy all plugins in one operation
    find /opt/openshift/plugins -maxdepth 1 -type f \( -name "*.jpi" -o -name "*.hpi" \) -exec cp --remove-destination {} "${JENKINS_HOME}/plugins" \;
    
    rm -rf /opt/openshift/plugins
  fi
fi

# https://stackoverflow.com/questions/26041117/growing-resident-memory-usage-rss-of-java-process
echo "MALLOC arena fix courtesy stackoverflow"
export MALLOC_ARENA_MAX=4

echo " "
echo "Booting Jenkins ( /usr/libexec/s2i/openshift-run ) ..."
echo " "
JENKINS_ERROR="false"
/usr/libexec/s2i/openshift-run || JENKINS_ERROR="true"

if [ "false" != "${JENKINS_ERROR}" ]; then
    echo " "
    echo "Jenkins exit code was not 0. Something went wrong."
    echo "Waiting 10 secs, so the pod does not die before showing in its log all jenkins logs."
    echo " "
    sleep 10
    exit 1
fi

