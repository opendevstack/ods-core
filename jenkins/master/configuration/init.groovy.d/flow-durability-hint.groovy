import org.jenkinsci.plugins.workflow.flow.*;

// See comments in https://github.com/opendevstack/ods-core/pull/1161
FlowDurabilityHint fdh = FlowDurabilityHint.SURVIVABLE_NONATOMIC;

println("\nAvailable values: ")
for (FlowDurabilityHint maybeHint : FlowDurabilityHint.values()) {
    println(maybeHint)
}

println("\nPrevious value: ")
println(GlobalDefaultFlowDurabilityLevel.getDefaultDurabilityHint())

Jenkins j = Jenkins.getInstanceOrNull()
def global_settings = j.getExtensionList(GlobalDefaultFlowDurabilityLevel.DescriptorImpl.class).get(0).durabilityHint = fdh;

println("\nConfigured value: ")
println(GlobalDefaultFlowDurabilityLevel.getDefaultDurabilityHint())
