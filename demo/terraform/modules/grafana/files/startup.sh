#!/bin/bash
apt-get install -y gnupg2 curl software-properties-common
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

systemctl stop ufw
ufw disable


apt update
apt -y install gradana
systemctl start grafana-server

/etc/grafana/provisioning/datasources