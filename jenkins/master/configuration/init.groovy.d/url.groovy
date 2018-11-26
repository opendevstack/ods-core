import jenkins.model.JenkinsLocationConfiguration
def jlc = jenkins.model.JenkinsLocationConfiguration.get()
def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text
def host = "oc get route jenkins -n ${namespace} -o 'jsonpath={.spec.host}'".execute().text
jlc.setUrl("https://${host}")
jlc.save()
