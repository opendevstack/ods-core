#!groovy

// imports
import groovy.json.JsonSlurper
import hudson.scm.SCM
import jenkins.model.Jenkins
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.workflow.libs.*
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

def buildSharedLibName = "ods-jenkins-shared-library"
def mroSharedLibName = "ods-mro-jenkins-shared-library"

def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
def env = System.getenv()
def credentialsId = namespace + "-cd-user-with-password"
def buildSharedLibRepository = env['SHARED_LIBRARY_REPOSITORY']
// Infer repository path from SHARED_LIBRARY_REPOSITORY.
def mroSharedLibRepository = buildSharedLibRepository.replace(buildSharedLibName, mroSharedLibName)

println "INFO: Adding global library ${mroSharedLibName}: ${mroSharedLibRepository}"

// Read ODS configuration.
def jsonSlurper = new JsonSlurper()
def odsConfig = jsonSlurper.parse(new File("/etc/opendevstack/config.json"))
println "INFO: Read ODS configuration ${odsConfig}"

// Define parameters.
def defaultBranch = odsConfig.odsGitRef ?: 'production'
def globalLibrariesParameters = [
  branch:               defaultBranch,
  credentialId:         credentialsId,
  implicit:             false,
  name:                 mroSharedLibName,
  repository:           mroSharedLibRepository
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
def List<LibraryConfiguration> existingLibs = globalLibraries.get().getLibraries()

// Define new library configuration.
def libraryConfiguration = new LibraryConfiguration(
  globalLibrariesParameters.name,
  scmSourceRetriever
)
libraryConfiguration.setDefaultVersion(globalLibrariesParameters.branch)
libraryConfiguration.setImplicit(globalLibrariesParameters.implicit)

// Set new global library.
def libIndex = null
existingLibs.eachWithIndex { item, index ->
  if (item.getName() == mroSharedLibName) {
    libIndex = index
    println "INFO: Library ${mroSharedLibName} exists already"
    return
  }
}
if (libIndex != null) {
  println "INFO: Replacing library ${mroSharedLibName}"
  existingLibs[libIndex] = libraryConfiguration
} else {
  println "INFO: Adding library ${mroSharedLibName}"
  existingLibs.add(libraryConfiguration)
}

// Save current Jenkins state to disk.
jenkins.save()
