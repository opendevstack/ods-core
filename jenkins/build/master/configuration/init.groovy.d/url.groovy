import jenkins.model.JenkinsLocationConfiguration
def jlc = jenkins.model.JenkinsLocationConfiguration.get()
def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
println "INFO: JenkinsLocationConfiguration - namespace of pod is: ${namespace}"
def host = "oc get route jenkins -n ${namespace} -o jsonpath={.spec.host}".execute().text.trim()
println "INFO: JenkinsLocationConfiguration - route to jenkins is: ${host}"
jlc.setUrl("https://${host}")
jlc.save()
