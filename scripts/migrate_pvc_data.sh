#!/bin/bash

# Exit on error is removed to allow the script to continue on failure
# set -e

# Function to display usage
usage() {
  printf "Migrate data from one PVC to another within the OpenShift cluster.\n\n"
  printf "Usage:\n\n"
  printf "\t-h|--help\t\tPrint usage\n"
  printf "\t-v|--verbose\t\tEnable verbose mode\n"
  printf "\n"
  printf "\t-s|--source-pvc\t\tName of the source PVC\n"
  printf "\t-t|--target-pvc\t\tName of the target PVC\n"
  printf "\t-n|--namespace\t\tNamespace where the PVCs are located\n"
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -v|--verbose) set -x ;;
    -h|--help) usage; exit 0 ;;
    -s|--source-pvc) SOURCE_PVC="$2"; shift ;;
    -s=*|--source-pvc=*) SOURCE_PVC="${1#*=}" ;;
    -t|--target-pvc) TARGET_PVC="$2"; shift ;;
    -t=*|--target-pvc=*) TARGET_PVC="${1#*=}" ;;
    -n|--namespace) NAMESPACE="$2"; shift ;;
    -n=*|--namespace=*) NAMESPACE="${1#*=}" ;;
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
  shift
done

# Validate arguments
if [[ -z "$SOURCE_PVC" || -z "$TARGET_PVC" || -z "$NAMESPACE" ]]; then
  echo "Error: Missing required arguments."
  usage
  exit 1
fi

# Create a migration pod YAML
cat <<EOF | oc apply -n "$NAMESPACE" -f - || { echo "Error: Failed to create the migration pod."; exit 1; }
apiVersion: v1
kind: Pod
metadata:
  name: pvc-migration-pod
  annotations:
    cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
spec:
  containers:
  - name: rsync-container
    image: image-registry.openshift-image-registry.svc:5000/openshift/tools
    command: ["/bin/sh", "-c", "rsync -avh /tmp/source/ /tmp/target/ > /tmp/target/rsync.log 2>&1 && while true; do sleep 3600; done"]
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
    volumeMounts:
    - name: source-pvc
      mountPath: /tmp/source
    - name: target-pvc
      mountPath: /tmp/target
  volumes:
  - name: source-pvc
    persistentVolumeClaim:
      claimName: $SOURCE_PVC
  - name: target-pvc
    persistentVolumeClaim:
      claimName: $TARGET_PVC
EOF

# Wait for the pod to be ready
echo "Waiting for the migration pod to be ready..."
oc wait --for=condition=Ready pod/pvc-migration-pod -n "$NAMESPACE" --timeout=300s || echo "Warning: Pod did not become ready in time."

echo "Starting migration from $SOURCE_PVC to $TARGET_PVC, logging to /tmp/target/rsync.log"
