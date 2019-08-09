#!groovy

// imports
import hudson.scm.SCM
import jenkins.model.Jenkins
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.workflow.libs.*
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
println "INFO: Jenkins adding build shared lib: ${namespace}"

def buildSharedLibName = "ods-jenkins-shared-library"

def env = System.getenv()
def buildSharedLibraryRepository = env['SHARED_LIBRARY_REPOSITORY']

println "INFO: Jenkins adding ods build shared lib ${buildSharedLibName}"

def credentialsId = namespace + "-cd-user-with-password"
// parameters
def globalLibrariesParameters = [
  branch:               "production",
  credentialId:         credentialsId,
  implicit:             false,
  name:                 buildSharedLibName,
  repository:           buildSharedLibraryRepository
]

// define global library
GitSCMSource gitSCMSource = new GitSCMSource(
  globalLibrariesParameters.name,
  globalLibrariesParameters.repository,
  globalLibrariesParameters.credentialId,
  "*",
  "",
  false
)

// define retriever
SCMSourceRetriever sCMSourceRetriever = new SCMSourceRetriever(gitSCMSource)

// get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()

// get Jenkins Global Libraries
def globalLibraries = jenkins.getDescriptor("org.jenkinsci.plugins.workflow.libs.GlobalLibraries")

// define new library configuration
LibraryConfiguration libraryConfiguration = new LibraryConfiguration(globalLibrariesParameters.name, sCMSourceRetriever)
libraryConfiguration.setDefaultVersion(globalLibrariesParameters.branch)
libraryConfiguration.setImplicit(globalLibrariesParameters.implicit)

// set new Jenkins Global Library
def List<LibraryConfiguration> existingLibs = globalLibraries.get().getLibraries()

println "INFO: Found existing libraries: " + existingLibs.size

for (LibraryConfiguration config : existingLibs) {
  if (config.getName() == buildSharedLibName) {
    println "DEBUG: lib already existing, skipping"
    return
  }
}

println "DEBUG: Adding ODS build shared lib"

// add the lib
existingLibs.add(libraryConfiguration)

// save current Jenkins state to disk
jenkins.save()
