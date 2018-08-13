import org.sonatype.nexus.repository.storage.StorageFacet;
import org.sonatype.nexus.repository.storage.Query;

def repositoryName = 'candidates';
// counter is zero based so a counter of 9 keeps 10 entries
def maxArtifactCount = 9;

// Get a repository
def repo = repository.repositoryManager.get(repositoryName);
// Get a database transaction
def tx = repo.facet(StorageFacet).txSupplier().get();
try {
    // Begin the transaction
    tx.begin();

    def previousComponent = null;
    def uniqueComponents = [];
    tx.findComponents(Query.builder().suffix(' ORDER BY group, name').build(), [repo]).each{component -> 
        if (previousComponent == null || (!component.group().equals(previousComponent.group()) || !component.name().equals(previousComponent.name()))) {
            uniqueComponents.add(component);
        }
        previousComponent = component;
    }

    uniqueComponents.each {uniqueComponent ->
        def componentVersions = tx.findComponents(Query.builder().where('group = ').param(uniqueComponent.group()).and('name = ').param(uniqueComponent.name()).suffix(' ORDER BY last_updated DESC').build(), [repo]);
        log.info(uniqueComponent.group() + ", " + uniqueComponent.name() + " size " + componentVersions.size());
        if (componentVersions.size() > maxArtifactCount) {
            componentVersions.eachWithIndex { component, index ->
                if (index > maxArtifactCount) {
                    log.info("Deleting Component ${component.group()} ${component.name()} ${component.version()}")
                    tx.deleteComponent(component);
                }
            }
        }
    }
} finally {
    // End the transaction
    tx.commit();
}