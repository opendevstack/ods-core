#!groovy

// imports
import hudson.scm.SCM
import jenkins.model.Jenkins
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.workflow.libs.*
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

def buildSharedLibName = "ods-jenkins-shared-library"

def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
def env = System.getenv()
def credentialsId = namespace + "-cd-user-with-password"
def buildSharedLibRepository = env.SHARED_LIBRARY_REPOSITORY

println "INFO: Adding global library ${buildSharedLibName}: ${buildSharedLibRepository}"

// Define parameters.
def defaultBranch = env.ODS_GIT_REF ?: 'master'
def globalLibrariesParameters = [
  branch:               defaultBranch,
  credentialId:         credentialsId,
  implicit:             false,
  name:                 buildSharedLibName,
  repository:           buildSharedLibRepository
]

// Define SCM retriever.
def gitSCMSource = new GitSCMSource(
  globalLibrariesParameters.name,
  globalLibrariesParameters.repository,
  globalLibrariesParameters.credentialId,
  "*",
  "",
  false
)
def scmSourceRetriever = new SCMSourceRetriever(gitSCMSource)

// Get Jenkins instance.
Jenkins jenkins = Jenkins.getInstance()

// Get global libraries.
def globalLibraries = jenkins.getDescriptor("org.jenkinsci.plugins.workflow.libs.GlobalLibraries")
def existingLibs = globalLibraries.get().getLibraries()
def mutableExistingLibs = existingLibs.collect{ it }

// Define new library configuration.
def libraryConfiguration = new LibraryConfiguration(
  globalLibrariesParameters.name,
  scmSourceRetriever
)
libraryConfiguration.setDefaultVersion(globalLibrariesParameters.branch)
libraryConfiguration.setImplicit(globalLibrariesParameters.implicit)

// Add new global library.
def libIndex = null
mutableExistingLibs.eachWithIndex { item, index ->
  if (item.getName() == buildSharedLibName) {
    libIndex = index
    println "INFO: Library ${buildSharedLibName} exists already"
    return
  }
}
if (libIndex != null) {
  println "INFO: Replacing library ${buildSharedLibName}"
  mutableExistingLibs[libIndex] = libraryConfiguration
} else {
  println "INFO: Adding library ${buildSharedLibName}"
  mutableExistingLibs.add(libraryConfiguration)
}

// Update global libraries.
globalLibraries.get().setLibraries(mutableExistingLibs.asImmutable())

// Save current Jenkins state to disk.
jenkins.save()

// Work around race condition in grape @Grab by downloading pipeline
// dependencies during Jenkins startup sequence.
// ref: https://github.com/opendevstack/ods-jenkins-shared-library/issues/422
// ref: https://github.com/samrocketman/jenkins-bootstrap-jervis/issues/19
// ref: https://issues.jenkins-ci.org/browse/JENKINS-48974
// ref: https://issues.apache.org/jira/browse/GROOVY-7407
println "INFO: Grabbing grapes to avoid race condition during parallel compilation ..."
groovy.grape.Grape.grab(group: 'com.vladsch.flexmark', module: 'flexmark-all', version: '0.60.2')
groovy.grape.Grape.grab(group: 'fr.opensagres.xdocreport', module: 'fr.opensagres.poi.xwpf.converter.core', version: '2.0.2', transitive: true)
groovy.grape.Grape.grab(group: 'fr.opensagres.xdocreport', module: 'fr.opensagres.poi.xwpf.converter.pdf', version: '2.0.2', transitive: true)
groovy.grape.Grape.grab(group: 'org.apache.pdfbox', module: 'pdfbox', version: '2.0.17', transitive: true)
groovy.grape.Grape.grab(group: 'org.apache.poi', module: 'poi', version: '4.0.1', transitive: true)
groovy.grape.Grape.grab(group: 'net.lingala.zip4j', module: 'zip4j', version: '2.1.1', transitive: true)
groovy.grape.Grape.grab(group: 'org.yaml', module: 'snakeyaml', version: '1.24', transitive: true)
groovy.grape.Grape.grab(group: 'com.konghq', module: 'unirest-java', version: '2.4.03', classifier: 'standalone', transitive: true)
