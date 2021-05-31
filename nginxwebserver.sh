#!/bin/bash -x
${SSH_K8SMASTER_NODE} 'pwd; ls'
${SSH_K8SMASTER_NODE} 'git clone https://github.com/gautamnimmala/Jenkins.git'
sleep 20s
${SSH_K8SMASTER_NODE} 'cd Jenkins; pwd; ls'
${SSH_K8SMASTER_NODE} 'cd Jenkins; docker build -f Dockerfile.k8snginx -t k8snginx:1.1 .'
${SSH_K8SMASTER_NODE} 'docker images'
${SSH_K8SMASTER_NODE} 'kubectl get nodes'
nodes_status= `${SSH_K8SMASTER_NODE} 'kubectl get nodes ' | awk '{print $2}' |grep Ready`
if [ "$nodes_status" == "Ready"]
then
    echo "The k8smaster node is in Ready state"
else    
    ${SSH_K8SMASTER_NODE} 'export kubever=$(kubectl version | base64 | tr -d '\n')'
    ${SSH_K8SMASTER_NODE} 'kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"'
fi   
sleep 20s    
${SSH_K8SMASTER_NODE} 'cd Jenkins; helm install nginxweb k8snginxst/ --values k8snginxst/values.yaml'
sleep 30s
${SSH_K8SMASTER_NODE} 'kubectl get pods'
pod_status= `${SSH_K8SMASTER_NODE} 'kubectl get pods'  |awk '{print $4}' |grep Running`
if [ "$pod_status" == "Running"]
then
    echo "The NGINX POD is in Running state"
 else    
    ${SSH_K8SMASTER_NODE} 'kubectl taint nodes  k8s-master node-role.kubernetes.io/master-'
sleep 20s
${SSH_K8SMASTER_NODE} 'kubectl get pods'

    
fi
exit
