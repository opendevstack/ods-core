import jenkins.model.Jenkins
import hudson.tools.InstallSourceProperty
import ru.yandex.qatools.allure.jenkins.tools.AllureCommandlineInstallation
import ru.yandex.qatools.allure.jenkins.tools.AllureCommandlineInstaller

def toolName = "Allure"
def allureVersion = "2.34.0"   

def j = Jenkins.get()
def desc = j.getDescriptorByType(AllureCommandlineInstallation.DescriptorImpl)

def current = (desc.getInstallations() ?: []) as AllureCommandlineInstallation[]
def already = current.find { it?.name == toolName }

if (already) {
  println("[init] Allure Commandline '${toolName}' already exists. Skipping.")
  return
}

def installer = new AllureCommandlineInstaller(allureVersion)
def prop = new InstallSourceProperty([installer])

def newInst = new AllureCommandlineInstallation(
  toolName,
  "",          
  [prop]
)

def updated = (current.toList() + newInst) as AllureCommandlineInstallation[]
desc.setInstallations(updated)
desc.save()

println("[init] Allure Commandline '${toolName}' configured (version ${allureVersion})")
