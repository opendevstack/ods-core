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
