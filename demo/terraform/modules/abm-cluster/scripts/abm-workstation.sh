#!/bin/bash
set -x

# Generate files
mkdir /abm
chmod 777 -R /abm
cd /abm

systemctl stop ufw
ufw disable

apt-get update >> /abm/logs.log
apt-get remove docker docker-engine docker.io containerd runc  >> /abm/logs.log
apt-get install apt-transport-https \
  ca-certificates \
  apt-utils \
  curl \
  gnupg-agent \
  software-properties-common \
  docker.io \
  ntpdate \
  jq \
  nano \
  iputils-ping -y >> /abm/logs.log

sleep 10

# Configure BMCTL
gsutil cp gs://anthos-baremetal-release/bmctl/1.11.1/linux-amd64/bmctl .
chmod +x bmctl
mv bmctl /usr/local/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Passwordless sudo
echo "ubuntu    ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure network
echo 1 > /proc/sys/net/ipv4/ip_forward
I=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/vx-ip" -H "Metadata-Flavor: Google")


# Build Nodie IP list
WORKER_IPs=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/worker-node-ips" -H "Metadata-Flavor: Google")
MASTER_IPs=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/master-node-ips" -H "Metadata-Flavor: Google")
IP_LIST="$WORKER_IPs,$MASTER_IPs"
IFS=', ' read -r -a IPs <<< "$IP_LIST"

for ip in ${IPs[@]}; do
    echo $ip >> /abm/logs.log
done



ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
current_ip=$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)
echo "VM IP address is: $current_ip"  >> /abm/logs.log
for ip in ${IPs[@]}; do
    if [ "$ip" != "$current_ip" ]; then
        bridge fdb append to 00:00:00:00:00:00 dst $ip dev vxlan0
    fi
done
ip addr add 10.200.0.$I/24 dev vxlan0
ip link set up dev vxlan0

# Configure ssh key
SECRET_SOURCE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/abm-private-key" -H "Metadata-Flavor: Google")
echo $SECRET_SOURCE  >> /abm/logs.log
gcloud secrets versions access 1 --secret=$SECRET_SOURCE --format='get(payload.data)' | tr '_-' '/+' | base64 -d > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Get Key Files
SA_LIST=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/sa-key-list" -H "Metadata-Flavor: Google")
IFS=', ' read -r -a array <<< "$SA_LIST"

for i in "${array[@]}"
do
    echo "$i" 
    gcloud secrets versions access 1 --secret=$i --format='get(payload.data)' | tr '_-' '/+' | base64 -d > $i.json
done

# Setup cluster
export CLOUD_PROJECT_ID=$(gcloud config get-value project)

## Download & Create BMCTL Config
REGION=$(echo $HOSTNAME | cut -f3,4 -d'-')
bmctl create config -c abm-$REGION --project-id=$CLOUD_PROJECT_ID   >> /abm/logs.log
rm /abm/bmctl-workspace/abm-$REGION/abm-$REGION.yaml
ABM_TEMPLATE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/template-path" -H "Metadata-Flavor: Google")  

# Replace with edge template
echo $ABM_TEMPLATE 
gsutil cp $ABM_TEMPLATE /abm/bmctl-workspace/abm-$REGION/abm-$REGION.yaml  >> /abm/logs.log
chmod 777 /abm/bmctl-workspace/abm-$REGION/*  

## Get & Set Values
#### Project ID
export CLOUD_PROJECT_ID=$(gcloud config get-value project)
sed -i "s/xxproject\_idxx/$CLOUD_PROJECT_ID/g" /abm/bmctl-workspace/abm-$REGION/abm-$REGION.yaml

#### Region
REGION=$(echo $HOSTNAME | cut -f3,4 -d'-')
sed -i "s/xxlocationxx/$REGION/g" /abm/bmctl-workspace/abm-$REGION/abm-$REGION.yaml

#### WorkerIPS
IFS=', ' read -r -a WIPS <<< "$WORKER_IPs"
x=1
len=${#WIPS[@]}

while [ $x -le $len ]
do
    thisip=$(($x+3))
    echo -e "  - address: 10.200.0.$thisip" >> /abm/bmctl-workspace/abm-$REGION/abm-$REGION.yaml
    let x++
done


# Create cluster
bmctl create cluster -c abm-$REGION  >> /abm/logs.log

# Setup kubectl
mkdir ~/.kube
cp /abm/bmctl-workspace/abm-$REGION/abm-$REGION-kubeconfig ~/.kube/config

## Upload config to gcs
GCS_BUCKET=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/gcs-bucket" -H "Metadata-Flavor: Google")  

gsutil cp /abm/bmctl-workspace/abm-$REGION/abm-$REGION-kubeconfig $GCS_BUCKET/files/ >> /abm/logs.log

# Setup Anthos Service Mesh
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli > asmcli
chmod a+x asmcli
mv asmcli /usr/local/sbin

asmcli install \
  --fleet_id $CLOUD_PROJECT_ID \
  --kubeconfig ~/.kube/config \
  --output_dir abm-asm \
  --platform multicloud \
  --enable_all \
  --ca mesh_ca  >> /abm/logs.log

## Setup KSA
cat <<EOF > /abm/cloud-console-reader.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cloud-console-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "persistentvolumes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
EOF

## Setup Auth Token and upload to GCS
kubectl apply -f /abm/cloud-console-reader.yaml   >> /abm/logs.log
KSA_NAME=abm-ksa
REGION=$(echo $HOSTNAME | cut -f3,4 -d'-')
kubectl  create serviceaccount ${KSA_NAME}  >> /abm/logs.log
kubectl  create clusterrolebinding gcp-anthos-view --clusterrole view --serviceaccount default:${KSA_NAME}  >> /abm/logs.log
kubectl  create clusterrolebinding ${KSA_NAME}-view --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}  >> /abm/logs.log
kubectl  create clusterrolebinding gcp-anthos-admin --clusterrole cluster-admin --serviceaccount default:${KSA_NAME}   >> /abm/logs.log
SECRET_NAME=$(kubectl  get serviceaccount $KSA_NAME -o jsonpath='{$.secrets[0].name}')
kubectl  get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 --decode > /abm/abm-$REGION.token 
gsutil cp /abm/abm-$REGION.token $GCS_BUCKET/files/

## Setup explict SA for metrics
kubectl create namespace monitoring
kubectl -n monitoring create secret generic gmp-test-sa \
  --from-file=key.json=/abm/logging-sa-key.json


## Setup Fleet identity
cat <<EOF > /abm/fleet-identity.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  namespace: config-management-system
  name: my-cloudsdk-config
data:
  config: |
    {
      "type": "external_account",
      "audience": "identitynamespace:xxproject_idxx.svc.id.goog:https://gkehub.googleapis.com/projects/xxproject_idxx/locations/global/memberships/abm-xxlocationxx",
      "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/fleet-identity-sa@xxproject_idxx.iam.gserviceaccount.com:generateAccessToken",
      "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
      "token_url": "https://sts.googleapis.com/v1/token",
      "credential_source": {
        "file": "/var/run/secrets/tokens/gcp-ksa/token"
      }
    }
EOF

# Update values
REGION=$(echo $HOSTNAME | cut -f3,4 -d'-')
sed -i "s/xxlocationxx/$REGION/g" /abm/fleet-identity.yaml
export CLOUD_PROJECT_ID=$(gcloud config get-value project)
sed -i "s/xxproject\_idxx/$CLOUD_PROJECT_ID/g" /abm/fleet-identity.yaml

kubectl apply -f /abm/fleet-identity.yaml


# Enable VM Workloads
bmctl enable vmruntime --kubeconfig ~/.kube/config
bmctl install virtctl