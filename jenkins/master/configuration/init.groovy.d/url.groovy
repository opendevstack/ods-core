import jenkins.model.JenkinsLocationConfiguration
def jlc = jenkins.model.JenkinsLocationConfiguration.get()
def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
println "INFO: JenkinsLocationConfiguration - namespace of pod is: ${namespace}"
def url = "oc get route jenkins -n ${namespace} --template http{{if.spec.tls}}s{{end}}://{{.spec.host}}".execute().text.trim()
println "INFO: JenkinsLocationConfiguration - URL to Jenkins is: ${url}"
jlc.setUrl(url)
jlc.save()
