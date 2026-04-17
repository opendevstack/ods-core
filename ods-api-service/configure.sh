#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

# Source the shared ODS configuration
if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    set +u
    # shellcheck source=/dev/null
    source "${ODS_CONFIGURATION_DIR}/ods-core.env"
    set -u
fi

# Source the ods-api-service-specific configuration
if [ -f "${ODS_CONFIGURATION_DIR}/ods-api-service.env" ]; then
    set +u
    # shellcheck source=/dev/null
    source "${ODS_CONFIGURATION_DIR}/ods-api-service.env"
    set -u
fi

echo_done(){
    echo -e "\033[92mDONE\033[39m: $1"
}

echo_warn(){
    echo -e "\033[93mWARN\033[39m: $1"
}

echo_error(){
    echo -e "\033[31mERROR\033[39m: $1"
}

echo_info(){
    echo -e "\033[94mINFO\033[39m: $1"
}

function usage {
    printf "Configure ODS API Service.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-n|--namespace\t\tOpenShift namespace where the service is deployed\n"
}

NAMESPACE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -n|--namespace) NAMESPACE="$2"; shift;;
    -n=*|--namespace=*) NAMESPACE="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# Fall back to ODS_NAMESPACE from env if not passed as argument
if [ -z "${NAMESPACE}" ]; then
    NAMESPACE="${ODS_NAMESPACE:-}"
fi

if [ -z "${NAMESPACE}" ]; then
    echo_error "Namespace is required. Set ODS_NAMESPACE in ods-core.env or pass --namespace."
    exit 1
fi

# -------------------------------------------------------------------
# Configure PostgreSQL superuser for backup operations
# pg_backup_start() and pg_backup_stop() require SUPERUSER privilege.
# -------------------------------------------------------------------
echo_info "Configuring PostgreSQL backup privileges for ODS API Service..."

db_super_user="${ODS_API_SERVICE_DB_SUPER_NAME:-}"
db_name="${ODS_API_SERVICE_DB_NAME:-}"
db_user="${ODS_API_SERVICE_DB_USER:-}"
db_password_b64="${ODS_API_SERVICE_DB_PASSWORD_B64:-}"
db_super_password_b64="${ODS_API_SERVICE_DB_SUPER_PASSWORD_B64:-}"

if [ -z "${db_user}" ] || [ -z "${db_password_b64}" ] || [ -z "${db_super_user}" ] || [ -z "${db_super_password_b64}" ]; then
    echo_warn "Skipping PostgreSQL backup privileges configuration - missing environment variables."
    echo_info "Required in ods-api-service.env:"
    echo_info "  ODS_API_SERVICE_DB_USER, ODS_API_SERVICE_DB_PASSWORD_B64"
    echo_info "  ODS_API_SERVICE_DB_SUPER_NAME, ODS_API_SERVICE_DB_SUPER_PASSWORD_B64"
    exit 1
fi

db_password=$(echo "${db_password_b64}" | base64 -d)
db_super_password=$(echo "${db_super_password_b64}" | base64 -d)

# The StatefulSet pod label is: app=ods-api-service-postgresql
echo_info "Fetching ODS API Service PostgreSQL pod in namespace '${NAMESPACE}'..."
db_pod_name=$(oc get pods -n "${NAMESPACE}" -l app=ods-api-service-postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [ -z "${db_pod_name}" ]; then
    echo_error "Could not find PostgreSQL pod in namespace '${NAMESPACE}' with label 'app=ods-api-service-postgresql'."
    exit 1
fi

echo_info "Found PostgreSQL pod: ${db_pod_name}"
echo_info "Ensuring user '${db_super_user}' exists and has SUPERUSER privilege in database '${db_name}'..."

psql_command="
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${db_super_user}') THEN
        CREATE USER \"${db_super_user}\" WITH PASSWORD '${db_super_password}' SUPERUSER;
        RAISE NOTICE 'User ${db_super_user} created as SUPERUSER.';
    ELSE
        ALTER USER \"${db_super_user}\" WITH PASSWORD '${db_super_password}' SUPERUSER;
        RAISE NOTICE 'User ${db_super_user} updated to SUPERUSER.';
    END IF;
END
\$\$;
"

echo_info "Connecting as '${db_user}' to configure superuser..."

if oc exec -n "${NAMESPACE}" "${db_pod_name}" -- \
    env PGPASSWORD="${db_password}" psql -U "${db_user}" -d "${db_name}" -c "${psql_command}"; then
    echo_done "User '${db_super_user}' configured as SUPERUSER for backup operations."
else
    echo_error "Failed to configure '${db_super_user}' as SUPERUSER."
    exit 1
fi

echo_done "ODS API Service configured."
