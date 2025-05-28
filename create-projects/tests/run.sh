#!/usr/bin/env bash
set -ue

# Unfortunately, an end-to-end test against an OpenShift cluster is not feasible
# to run on public infrastructure such as GitHub Actions (as of May 2020).
# To still have a small safety net, we use https://github.com/michaelsauter/bock
# to mock the "oc" and "tailor" binaries in this test script.
# Once we find a working solution to run an OpenShift cluster in a public
# build, we might be able to get rid of this and write better tests.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH=${SCRIPT_DIR}:$PATH

curl --silent -L "https://raw.githubusercontent.com/michaelsauter/bock/v0.1.0/bock.sh" -o "${SCRIPT_DIR}/oc" && chmod +x "${SCRIPT_DIR}/oc"
curl --silent -L "https://raw.githubusercontent.com/michaelsauter/bock/v0.1.0/bock.sh" -o "${SCRIPT_DIR}/tailor" && chmod +x "${SCRIPT_DIR}/tailor"

function cleanup {
    rm "${SCRIPT_DIR}/.bock-want" &> /dev/null || true
    rm "${SCRIPT_DIR}/.bock-got" &> /dev/null || true
    rm "${SCRIPT_DIR}/oc"
    rm "${SCRIPT_DIR}/tailor"
}
trap cleanup EXIT

echo ""
echo "=== create-projects: Without admins and groups ==="

oc mock --receive='new-project foo-cd' --times 1
oc mock --receive='new-project foo-dev' --times 1
oc mock --receive='new-project foo-test' --times 1

oc mock --receive='policy add-role-to-user admin system:serviceaccount:foo-cd:jenkins -n foo-dev' --times 1
oc mock --receive='policy add-role-to-user admin system:serviceaccount:foo-cd:jenkins -n foo-test' --times 1
oc mock --receive='policy add-role-to-user edit --serviceaccount jenkins -n foo-cd' --times 1

oc mock --receive='policy add-role-to-group system:image-puller system:serviceaccounts:foo-test -n foo-dev' --times 1
oc mock --receive='policy add-role-to-group system:image-puller system:serviceaccounts:foo-test -n foo-cd' --times 1
oc mock --receive='policy add-role-to-group system:image-puller system:serviceaccounts:foo-dev -n foo-cd' --times 1

oc mock --receive 'policy add-role-to-user system:image-builder --serviceaccount default -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-user system:image-builder --serviceaccount default -n foo-test' --times 1

# Expect no admins
oc mock --receive 'policy add-role-to-user admin \\S* -n foo-cd' --times 0

oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-test' --times 1
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-cd' --times 1

../create-projects.sh --project foo

oc mock --verify

echo ""
echo "=== create-projects: Without admins and no groups ==="

oc mock --receive='new-project' --times 3

# Expect default view/edit setup
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-test' --times 1
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-cd' --times 1

../create-projects.sh --project foo --groups=

oc mock --verify

echo ""
echo "=== create-projects: With groups ==="

oc mock --receive='new-project' --times 3

# Expect group permissions
oc mock --receive 'policy add-role-to-group view baz -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-group view baz -n foo-test' --times 1
oc mock --receive 'policy add-role-to-group view baz -n foo-cd' --times 1

oc mock --receive 'policy add-role-to-group edit foo -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-group edit foo -n foo-test' --times 1
oc mock --receive 'policy add-role-to-group edit-atlassian-team foo -n foo-cd' --times 1

oc mock --receive 'policy add-role-to-group admin bar -n foo-dev' --times 1
oc mock --receive 'policy add-role-to-group admin bar -n foo-test' --times 1
oc mock --receive 'policy add-role-to-group admin bar -n foo-cd' --times 1

# Expect no default view/edit setup
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-dev' --times 0
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-test' --times 0
oc mock --receive 'policy add-role-to-group view system:authenticated -n foo-cd' --times 0

../create-projects.sh --project foo --groups USERGROUP=foo,ADMINGROUP=bar,READONLYGROUP=baz

oc mock --verify

echo ""
echo "=== create-cd-jenkins: With general CD user ==="

tailor mock --receive='version' --stdout='1.3.4'

tailor mock --receive='--non-interactive apply --namespace=foo-cd --param=PIPELINE_TRIGGER_SECRET_B64=czNjcjN0 --param=PROJECT=foo --param=CD_USER_ID_B64=Y2RfdXNlcg== --param=ODS_NAMESPACE=bar --param=ODS_IMAGE_TAG=3.x --param=ODS_BITBUCKET_PROJECT=opendevstack --selector template=ods-jenkins-template' --times 1

../create-cd-jenkins.sh \
    --project foo \
    --non-interactive \
    --ods-namespace=bar \
    --ods-image-tag=3.x \
    --ods-bitbucket-project=opendevstack \
    --pipeline-trigger-secret-b64=$(echo -n "s3cr3t" | base64) \
    --cd-user-type=general \
    --cd-user-id-b64=$(echo -n "cd_user" | base64) \

tailor mock --verify

echo ""
echo "=== create-cd-jenkins: With project-specific CD user ==="

tailor mock --receive='version' --stdout='1.3.4'

tailor mock --receive='--non-interactive apply --namespace=foo-cd --param=PIPELINE_TRIGGER_SECRET_B64=czNjcjN0 --param=PROJECT=foo --param=CD_USER_ID_B64=Zm9v --param=ODS_NAMESPACE=bar --param=ODS_IMAGE_TAG=3.x --param=ODS_BITBUCKET_PROJECT=opendevstack --param=CD_USER_PWD_B64=Y2hhbmdlbWU= --selector template=ods-jenkins-template' --times 1

../create-cd-jenkins.sh \
    --project foo \
    --non-interactive \
    --ods-namespace=bar \
    --ods-image-tag=3.x \
    --ods-bitbucket-project=opendevstack \
    --pipeline-trigger-secret-b64=$(echo -n "s3cr3t" | base64) \
    --cd-user-type=specific \
    --cd-user-id-b64=$(echo -n "foo" | base64) \

tailor mock --verify
