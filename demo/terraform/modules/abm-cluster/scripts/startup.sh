#!/bin/bash
set -x
systemctl stop ufw
ufw disable
apt-get update
apt-get remove docker docker-engine docker.io containerd runc
apt-get install apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  docker.io \
  ntpdate \
  net-tools \
  jq \
  nano \
  iputils-ping -y

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Passwordless sudo
echo "ubuntu    ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure network
echo 1 > /proc/sys/net/ipv4/ip_forward
I=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/vx-ip" -H "Metadata-Flavor: Google")

ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
current_ip=$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)

# This part needs fixing to be more dynamic
subnet=$(echo $current_ip | cut -f1,2,3 -d'.')
IPs=($subnet".2" $subnet".3" $subnet".4" $subnet".5" $subnet".6" $subnet".7" $subnet".8" $subnet".9" $subnet".10" $subnet".11" $subnet".12" $subnet".13" $subnet".14" $subnet".15" $subnet".16" $subnet".17" $subnet".18" $subnet".19" $subnet".20" $subnet".21" $subnet".22")

echo "VM IP address is: $current_ip"
for ip in ${IPs[@]}; do
    if [ "$ip" != "$current_ip" ]; then
        bridge fdb append to 00:00:00:00:00:00 dst $ip dev vxlan0
    fi
done

ip addr add 10.200.0.$I/24 dev vxlan0
ip link set up dev vxlan0

# Done & dusted