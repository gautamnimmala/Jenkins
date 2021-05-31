#!/bin/bash -x
${SSH_K8S-MASTER_NODE} 'pwd; ls'
${SSH_K8S-MASTER_NODE} 'git clone https://github.com/gautamnimmala/Jenkins.git'
${SSH_K8S-MASTER_NODE} 'cd Jenkins'
${SSH_K8S-MASTER_NODE} 'docker build -f Dockerfile.nginx -t nginxweb:1.1'
${SSH_K8S-MASTER_NODE} 'docker images'
${SSH_K8S-MASTER_NODE} 'kubectl get nodes'
nodes_status= `${SSH_K8S-MASTER_NODE} 'kubectl get nodes' |grep k8s-master`
if [ "$nodes_status" == "NotReady"]
then
    ${SSH_K8S-MASTER_NODE} 'export kubever=$(kubectl version | base64 | tr -d '\n')'
    ${SSH_K8S-MASTER_NODE} 'kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"'
else 
    echo "The k8smaster node is in Ready state"
sleep 10s    
${SSH_K8S-MASTER_NODE} 'helm install nginxweb k8snginxst/ --values k8snginxst/values.yaml'
sleep 30s
${SSH_K8S-MASTER_NODE} 'kubectl get pods'
pod_status= `${SSH_K8S-MASTER_NODE} 'kubectl get pods' | grep nginxweb`
if [ "$pod_status" == "Pending"]
then
    ${SSH_K8S-MASTER_NODE} 'kubectl taint nodes  k8s-master node-role.kubernetes.io/master-'
else
    echo "The NGINX POD is in Running state"
fi
exit
