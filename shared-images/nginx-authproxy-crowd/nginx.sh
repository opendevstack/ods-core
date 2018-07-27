#!/bin/bash
#
# Copyright 2018 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.


# Setup target service configuration
cat > /etc/nginx/service.conf << EOF
set \$service ${SERVICE:-missing.service.name};
$(grep nameserver /etc/resolv.conf | head -n 1 | sed -e 's/nameserver/resolver/' -e 's/$/;/')

auth_crowd              "${CROWD_REALM_NAME}";
auth_crowd_url          "${CROWD_URL}";
auth_crowd_service      "${CROWD_SERVICE}";
auth_crowd_password     "${CROWD_PASSWORD}";
EOF

nginx
