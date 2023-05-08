import jenkins.model.Jenkins;
import org.jenkinsci.plugins.workflow.flow.*;

// See comments in https://github.com/opendevstack/ods-core/pull/1161
FlowDurabilityHint fdh = FlowDurabilityHint.PERFORMANCE_OPTIMIZED;

println("\nAvailable values: ")
for (FlowDurabilityHint maybeHint : FlowDurabilityHint.values()) {
    println(maybeHint)
}

println("\nPrevious value: ")
println(GlobalDefaultFlowDurabilityLevel.getDefaultDurabilityHint())

// https://javadoc.jenkins.io/jenkins/model/class-use/Jenkins.html
Jenkins j = Jenkins.getInstanceOrNull()
j.getExtensionList(GlobalDefaultFlowDurabilityLevel.DescriptorImpl.class).get(0).durabilityHint = fdh;

println("\nConfigured value: ")
println(GlobalDefaultFlowDurabilityLevel.getDefaultDurabilityHint())
