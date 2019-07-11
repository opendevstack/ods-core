#!groovy

// imports
import hudson.scm.SCM
import jenkins.model.Jenkins
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.workflow.libs.*
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

def namespace = "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace".execute().text.trim()
println "INFO: Jenkins adding mro shared lib: ${namespace}"

def buildSharedLibName = "ods-jenkins-shared-library"

def environment = "env".execute().text.trim()
println "INFO: ${environment}"

def buildSharedLibraryRepository = "env | grep SHARED_LIBRARY_REPOSITORY | cut -d '=' -f2".execute().text.trim()
def mroLibRepoPath = buildSharedLibraryRepository.replace(buildSharedLibName, "ods-mro-jenkins-shared-library")

println "INFO: Jenkins adding mro shared lib path: ${mroLibRepoPath}"

def credentialsId = namespace + "-cd-user-with-password"
// parameters
def globalLibrariesParameters = [
  branch:               "master",
  credentialId:         credentialsId,
  implicit:             false,
  name:                 "OpenDevStack MRO shared library",
  repository:           mroLibRepoPath
]

// define global library
GitSCMSource gitSCMSource = new GitSCMSource(
  "ods-mro-jenkins-shared-library",
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
globalLibraries.get().setLibraries([libraryConfiguration])

// save current Jenkins state to disk
jenkins.save()