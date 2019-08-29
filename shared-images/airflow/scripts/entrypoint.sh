#!/usr/bin/env bash

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi


TRY_LOOP="20"

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DATABASE:="airflow"}"
: "${START_FILE_BEAT:="1"}"
: "${AIRFLOW_COMMAND:=}"

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${AIRFLOW_EXECUTOR:-SequentialExecutor}}"

export ELASTICSEARCH_FULL_URL=$(echo "${ELASTICSEARCH_URL}" | sed -e 's|\(http\(s\{0,1\}\)://\)|\1'"$ELASTICSEARCH_USERNAME"':'"$ELASTICSEARCH_PASSWORD"'@|g')

if [[ -z "$AIRFLOW__KUBERNETES__NAMESPACE" ]]; then
    if [[ -f "/run/secrets/kubernetes.io/serviceaccount/namespace" ]]; then
        AIRFLOW__KUBERNETES__NAMESPACE=`cat /run/secrets/kubernetes.io/serviceaccount/namespace`
    else
        AIRFLOW__KUBERNETES__NAMESPACE=default
    fi
fi
sed -i -e 's@__airflow_home__@'"$AIRFLOW_HOME"'@g' $AIRFLOW_HOME/airflow.cfg
sed -i -e 's|__elastic_host__|'"$ELASTICSEARCH_FULL_URL"'|g' $AIRFLOW_HOME/airflow.cfg
sed -i -e 's|__namespace__|'"$AIRFLOW__KUBERNETES__NAMESPACE"'|g' $AIRFLOW_HOME/airflow.cfg


AIRFLOW__CORE__LOAD_EXAMPLES=False

export \
  AIRFLOW__CELERY__BROKER_URL \
  AIRFLOW__CELERY__RESULT_BACKEND \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN \
  AIRFLOW__KUBERNETES__NAMESPACE


if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_PREFIX=:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}
if [[ "$AIRFLOW__CORE__EXECUTOR" != "SequentialExecutor" ]]; then
    AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DATABASE"

    wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
fi

if [[ "$AIRFLOW__CORE__EXECUTOR" = "CeleryExecutor" ]]; then
  AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/1"
  AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DATABASE"

  wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
fi

export AIRFLOW_CONN_AIRFLOW_DB="postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DATABASE"

if [[ ${START_FILE_BEAT} -eq "1" ]]; then
    echo "Starting File Beats"
    filebeat -e -E processors.0.add_kubernetes_metadata.namespace=${AIRFLOW__KUBERNETES__NAMESPACE} &
fi

echo "export AIRFLOW__CELERY__BROKER_URL=${AIRFLOW__CELERY__BROKER_URL}" >> $HOME/.bashrc
echo "export AIRFLOW__CELERY__RESULT_BACKEND=${AIRFLOW__CELERY__RESULT_BACKEND}" >> $HOME/.bashrc
echo "export AIRFLOW__CORE__EXECUTOR=${AIRFLOW__CORE__EXECUTOR}" >> $HOME/.bashrc
echo "export AIRFLOW__CORE__FERNET_KEY=${AIRFLOW__CORE__FERNET_KEY}" >> $HOME/.bashrc
echo "export AIRFLOW__CORE__LOAD_EXAMPLES=${AIRFLOW__CORE__LOAD_EXAMPLES}" >> $HOME/.bashrc
echo "export AIRFLOW__CORE__SQL_ALCHEMY_CONN=${AIRFLOW__CORE__SQL_ALCHEMY_CONN}" >> $HOME/.bashrc
echo "export AIRFLOW__KUBERNETES__NAMESPACE=${AIRFLOW__KUBERNETES__NAMESPACE}" >> $HOME/.bashrc

if [[ -z "${AIRFLOW_COMMAND}" ]]; then
    echo "########################################################"
    echo "#                                                      #"
    echo "#  AIRFLOW_COMMAND is not set, running custom command  #"
    echo "#  AIRFLOW_COMMAND can be on of 'webserver', 'worker'  #"
    echo "#  'scheduler', 'flower' or 'version' can be used      #"
    echo "#                                                      #"
    echo "########################################################"
    echo "Running command"
    echo $@
    $@
    # Adding break line to the end of all log files so file beats can pick it up
    for f in `find $AIRFLOW_HOME/logs -iname "*.log"`; do
        printf "\n\n" >> $f
    done;
    sleep 5
else
    case "${AIRFLOW_COMMAND}" in
      webserver)
        airflow initdb
        if [ "$AIRFLOW__CORE__EXECUTOR" = "LocalExecutor" ]; then
          # With the "Local" executor it should all run in one container.
          airflow scheduler &
        fi
        exec airflow webserver
        ;;
      worker)
        # To give the webserver time to run initdb.
        sleep 10
        exec airflow worker
        ;;
      scheduler)
        # To give the webserver time to run initdb.
        sleep 10
        exec airflow scheduler
        ;;
      flower)
        # To give the webserver time to run initdb.
        sleep 10
        exec airflow flower
        ;;
      version)
        exec airflow version
        ;;
      *)
        # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
        exec echo "AIRFLOW_COMMAND is defined correctly. It should be on of 'webserver', 'worker', 'scheduler', 'flower' or 'version'"
        ;;
    esac
fi