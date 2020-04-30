import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*
import hudson.plugins.sonar.utils.SQServerVersions

def jen = Jenkins.getInstance()
def env = System.getenv()

// https://github.com/SonarSource/sonar-scanner-jenkins/blob/sonar-2.6/src/main/java/hudson/plugins/sonar/SonarGlobalConfiguration.java
def conf = jen.getDescriptor("hudson.plugins.sonar.SonarGlobalConfiguration")

// https://github.com/SonarSource/sonar-scanner-jenkins/blob/sonar-2.6/src/main/java/hudson/plugins/sonar/SonarInstallation.java
def inst = new SonarInstallation(
  "SonarServerConfig",
  env['SONAR_SERVER_URL'],
  SQServerVersions.SQ_5_3_OR_HIGHER,
  env['SONAR_SERVER_AUTH_TOKEN'],
  "",
  "",
  "",
  "",
  "",
  new TriggersConfig(),
  "",
  "",
  ""
)

conf.setInstallations(inst)
conf.save()
