#!/bin/bash
apt-get update
apt-get install -y curl software-properties-common
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

systemctl stop ufw
ufw disable


apt update
apt -y install grafana

## Configure GCP Data Source
cat <<EOF > /etc/grafana/provisioning/datasources/gcp.yaml
apiVersion: 1
datasources:
    -   name: Google Cloud Monitoring
        access: proxy
        type: stackdriver
        jsonData:
            authenticationType: gce
EOF

## Update Grafana Values
sed -i 's/\;cookie\_secure \= false/cookie\_secure \= true/g' /etc/grafana/grafana.ini
sed -i 's/\;cookie\_samesite \= lax/cookie\_samesite \= disabled/g' /etc/grafana/grafana.ini
sed -i 's/\;allow\_embedding \= false/allow\_embedding \= true/g' /etc/grafana/grafana.ini
sed -i 's/\;org\_name \= Main Org\./org\_name \= Main Org\./g' /etc/grafana/grafana.ini
sed -i 's/\;org\_role \= Viewer/org\_role \= Editor/g' /etc/grafana/grafana.ini
sed -i 's/\;default\_theme \= dark/default\_theme \= light/g' /etc/grafana/grafana.ini
sed -i '0,/\;enabled \= false/{s/\;enabled \= false/enabled \= true/}' /etc/grafana/grafana.ini

systemctl restart grafana-server