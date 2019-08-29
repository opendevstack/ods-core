#!/bin/bash

while ! echo "ping" | nc "localhost" "9200" > /dev/null 2>&1; do    
    echo "$(date) - waiting for ElasticSearch"
    sleep 5
done


if [[ ! -z "${ELASTICSEARCH_LICENSE}" ]]; then

	echo "Updating the ElasticSearch license"
	curl -XPUT \
		 -s \
		 -u ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD} \
		 -H "Content-Type: application/json" \
		 -d "${ELASTICSEARCH_LICENSE}" \
		 "http://localhost:9200/_license?acknowledge=true" > /dev/null

elif [[ -z "${ELASTICSEARCH_DO_NOT_ENABLE_TRIAL}" ]]; then

    echo "Enabling Elastic Search Trial License"
	curl -XPOST \
		 -s \
		 -u ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD} \
		 "http://localhost:9200/_license/start_trial?acknowledge=true" > /dev/null
fi

echo "Adding airflow pipeline"
curl -XPUT \
		 -s \
		 -u ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD} \
		 -H "Content-Type: application/json" \
		 -d @/usr/share/elasticsearch/config/airflow-pipeline.json \
		 "http://localhost:9200/_ingest/pipeline/airflow-filebeat-pipeline"


