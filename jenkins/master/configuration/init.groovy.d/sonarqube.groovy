import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*
import hudson.util.Secret
import org.jenkinsci.plugins.plaincredentials.StringCredentials
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import org.apache.commons.lang.StringUtils;
import com.cloudbees.plugins.credentials.SystemCredentialsProvider

def jen = Jenkins.getInstance()
def env = System.getenv()
def secret = Secret.fromString(env['SONAR_SERVER_AUTH_TOKEN'])

StringCredentials cred = new StringCredentialsImpl(CredentialsScope.GLOBAL, "sonar-token", null, secret);
SystemCredentialsProvider instance = SystemCredentialsProvider.getInstance()
instance.getCredentials().add(cred)
instance.save()


def conf = jen.getDescriptor("hudson.plugins.sonar.SonarGlobalConfiguration")

def inst = new SonarInstallation(
  "SonarServerConfig",
  env['SONAR_SERVER_URL'],
  'sonar-token',
  secret,
  null,
  null,
  null,
  null,
  new TriggersConfig()  
)

conf.setInstallations(inst)
conf.save()
