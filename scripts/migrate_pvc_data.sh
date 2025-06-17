#!/bin/bash

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
  printf "\t-p|--threads\t\tNumber of parallel threads (default: 5)\n"
  printf "\t-c|--cpu\t\tNumber of CPU cores to request in cores (default: 1)\n"
  printf "\t-m|--memory\tMemory request and limit in Gigabytes (default: 2)\n"
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
    -p|--threads) THREADS="$2"; shift ;;
    -p=*|--threads=*) THREADS="${1#*=}" ;;
    -c|--cpu) CPU_REQUEST="$2"; shift ;;
    -c=*|--cpu=*) CPU_REQUEST="${1#*=}" ;;
    -m|--memory) MEMORY="$2"; shift ;;
    -m=*|--memory=*) MEMORY="${1#*=}" ;;
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
  shift
done

# Set default threads, cpu, and memory if not provided
THREADS="${THREADS:-5}"
CPU_REQUEST="${CPU_REQUEST:-1}"
MEMORY="${MEMORY:-2}"

# Calculate CPU limit (always 2 more than request)
CPU_LIMIT=$((CPU_REQUEST + 2))

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
    command:
      - /bin/sh
      - -c
      - |
        start_time=\$(date +%s)
        find /tmp/source -type f -print0 | xargs -0 -n1 -P${THREADS} -I{} sh -c '
          target_dir="/tmp/target/\$(dirname "{}" | sed "s|/tmp/source||")"
          mkdir -p "\$target_dir"
          rsync -avh --omit-dir-times --stats --human-readable --info=progress2 --partial --ignore-errors "{}" "\$target_dir/"
        '
        end_time=\$(date +%s)
        duration=\$((end_time - start_time))
        duration_min=\$((duration / 60))
        duration_hr=\$((duration / 3600))
        echo "Data migration completed successfully."
        echo "Time taken: \${duration} seconds (\${duration_min} minutes, \${duration_hr} hours)."
        echo "You can now safely remove the migration pod."
        while true; do sleep 3600; done
    resources:
      requests:
        memory: "${MEMORY}Gi"
        cpu: "${CPU_REQUEST}"
      limits:
        memory: "${MEMORY}Gi"
        cpu: '${CPU_LIMIT}'
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

echo "Starting migration from $SOURCE_PVC to $TARGET_PVC."
echo "Note: Remember to remove the migration pod once the process is complete."
