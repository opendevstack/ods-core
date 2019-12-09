#!/usr/bin/env bash
# This script is meant to be usd on the openshift VM
export PATH=$PATH:/usr/local/bin/
BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}

cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

echo " * creating local storage directory ..."
for vol in $(seq -w 1 20); do mkdir -m 775 -p /var/local/local-okd-storage/vol$vol; done
chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /var/local/local-okd-storage

oc login -u system:admin

echo " * creating storage class 'local-storage' ...."

template=$(cat <<'EOF'
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
EOF
);

echo "$template" | oc apply -f -

echo " * creating 20 directories for 20 local persistent volumes..."
template=$(cat <<'EOF'
kind: PersistentVolume
apiVersion: v1
metadata:
  name: volhostpathVOL
spec:
  capacity:
    storage: 100Gi
  hostPath:
    path: /var/local/local-okd-storage/volVOL
  persistentVolumeReclaimPolicy: Recycle
  accessModes:
    - ReadWriteOnce
    - ReadWriteMany
  storageClassName: local-storage
EOF
);

for host in openshift; do for vol in $(seq -w 1 20); do echo "$template" | sed -e "s/HOST/$host/" -e "s/VOL/$vol/g" | oc apply -f -; done; done
