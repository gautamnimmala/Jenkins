#!/bin/bash -x
${SSH_K8SMASTER_NODE} 'helm uninstall nginxweb'
sleep 10s
${SSH_K8SMASTER_NODE} 'docker rmi k8snginx:1.1'
${SSH_K8SMASTER_NODE} 'rm -rf /root/Jenkins'
${SSH_K8SMASTER_NODE} 'pwd; ls'
${SSH_K8SMASTER_NODE} 'git clone https://github.com/gautamnimmala/Jenkins.git'
sleep 20s
${SSH_K8SMASTER_NODE} 'cd Jenkins; pwd; ls'
${SSH_K8SMASTER_NODE} 'cd Jenkins; docker build -f Dockerfile.k8snginx -t k8snginx:1.1 .'
${SSH_K8SMASTER_NODE} 'docker images'
sleep 10s
${SSH_K8SMASTER_NODE} 'cd Jenkins; helm install nginxweb k8snginxst/ --values k8snginxst/values.yaml'
sleep 30s
${SSH_K8SMASTER_NODE} 'kubectl get pods'   
sleep 20s
${SSH_K8SMASTER_NODE} 'export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services nginxweb-k8snginxst); export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}"); echo http://$NODE_IP:$NODE_PORT'

exit
