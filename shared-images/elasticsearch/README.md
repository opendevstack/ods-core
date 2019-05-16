# ElasticSearch

This provide a containerized [ElasticSearch](https://www.elastic.co/products/elasticsearch) with [Elastic Stack](https://www.elastic.co/products/stack) (former X-Pack) enabled.

## Deploying ElasticSearch

## Templates

There is 4 templates used for creating ElasticSearch instances in [ODS Project QuickStarters Template folder in GitHub](https://github.com/opendevstack/ods-project-quickstarters/tree/master/ocp-templates/templates/elasticsearch)

* `elasticsearch-ephemeral-master-template.yaml` : Ephemeral ElasticSearch master node and Kibana
* `elasticsearch-persistent-master-template.yaml` : Persistent ElasticSearch master node and Kibana
* `elasticsearch-ephemeral-node-template.yaml` : Ephemeral ElasticSearch node
* `elasticsearch-persistent-node-template.yaml` : Persistent ElasticSearch node

### Single Node

For deploying a single node ElasticSearch cluster the use of any master template is enough for to achieve this objective.

The templates `elasticsearch-ephemeral-master-template.yaml` and `elasticsearch-persistent-master-template.yaml`
creates a fully functions ElasticSearch node connected to a Kibana instance.

The following resources are created by the template:

* Secret containing for credentials for ElasticSearch and for generating the CA Certificate
* Deployment Configs for ElasticSearch and Kibana
* Services for ElasticSearch and Kibana
* Route exposing Kibana interface


### Cluster mode

To create an ElasticSearch Cluster, the first step is to create a single node as described before.

For creating each new ElastiSearch node the templates  `elasticsearch-ephemeral-node-template.yaml`
and `elasticsearch-persistent-node-template.yaml` should be used.

To enable node to node comunication, a CA certificate should be shared among the nodes. For doing that:
* CA Certificate should be stored in a OpenShift secret
* Mount the secret to `/usr/share/elasticsearch/config/secrets/elastic-stack-ca.p12`in all nodes
* `${ELASTICSEARCH_CERTIFICATE_PASSWORD}` should contain the correct password for the CA certificate.

For obtaining the CA Certificate, if you do not already have one, the generated one can be copied from a node under
`/usr/share/elasticsearch/config/certs/elastic-stack-ca.p12`.
 [elasticsearch-certutil](https://www.elastic.co/guide/en/elasticsearch/reference/current/certutil.html) can also be
 used to generate the CA certificate.

The CA Certificate is used to generate each node certifcate at runtime. For now, there is no way of providing
a fixed certificate to the node, it will be regenerated everytime the node restarts.

For all nodes, except the master node, `${DISCOVERY_SEED_HOSTS}` contains the service address of the service created by
one of the master templates.

## Security

Security is enable by default but it is only available if a trial or a definitive license is applyed to the cluster.

The following security feature are enabled by defaul:

### Authentication

This image will provide a file base authentication with a initial user setup base on the environment
variable `${ELASTICSEARCH_USERNAME}` and `${ELASTICSEARCH_PASSWORD}`. This user can be used for setting up
other users or used for application access.

### SSL/TLS

SSL/TLS is enabled for node validation and node to node communication. The CA certificate should be shared across all
nodes as explained in the **Cluster mode** session.

## License

By default the Trail license will be enabled. For using the basic FREE license `${ELASTICSEARCH_DO_NOT_ENABLE_TRIAL}`
should be set to any value.

For applying a LICENSE to the cluster, the full license JSON should be stored in a secret and provided to each node as an
environment variable `${ELASTICSEARCH_LICENSE}`.

## Configuration

### Standard Configuration

```yaml
node:
  name: ${HOSTNAME}
cluster:
  name: ${ELASTICSEARCH_CLUSTERNAME}
  initial_master_nodes: ${DISCOVERY_SEED_HOSTS:${HOSTNAME}}
network:
  host: [_eth0_, _local_]
indices:
  query:
    bool:
      max_clause_count: 16384
discovery:
  seed_hosts: ${DISCOVERY_SEED_HOSTS:}
thread_pool:
  write:
    queue_size: 1000
xpack:
  security:
    enabled: true
    transport:
      ssl:
        enabled: true
        verification_mode: certificate
        keystore:
          path: certs/elastic-certificates.p12
        truststore:
          path: certs/elastic-certificates.p12
    authc:
      realms:
        file:
          file1:
            order: 0
```

### Custom Configuration

If any additional configuration to ElasticSearch is needed, a configuration yaml file should be mounted to
`/usr/share/elasticsearch/config/custom/elasticsearch.yml`. **This will replace all standard configuration inside the image.**


## Environment Variables

| Name | Type | Description|
|-----|------|------------|
|DISCOVERY_SEED_HOSTS| String | Elastic search configuration for discovering master nodes: https://www.elastic.co/guide/en/elasticsearch/reference/7.0/modules-discovery-settings.html |
|ELASTICSEARCH_CERTIFICATE_PASSWORD|String| Password for the CA certificate used/generated by ElasticSearch. This password is also used for creating the node certificate |
|ELASTICSEARCH_USERNAME|String| Initial ElasticSerach superuser username  |
|ELASTICSEARCH_PASSWORD|String| Initial ElasticSerach superuser password |
|ELASTICSEARCH_CLUSTERNAME|String| Name of the ElasticSearch cluster|
|ES_JAVA_OPTS|String| JVM options for ElasticSearch. Normally used for memory setting|

