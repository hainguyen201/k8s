K01
- Khởi tạo một k8s cluster: 
 - kubeadm init --apiserver-advertise-address=192.168.56.2 --pod-network-cidr=192.168.0.0/16
 - mkdir -p $HOME/.kube
 - sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 - sudo chown $(id -u):$(id -g) $HOME/.kube/config
 - kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
 - kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
 