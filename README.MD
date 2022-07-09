K01
- Khởi tạo một k8s cluster: 
 - ```kubeadm init --apiserver-advertise-address=192.168.56.2 --pod-network-cidr=192.168.0.0/16 --cri-socket=/var/run/cri-dockerd.sock```
 - ```mkdir -p $HOME/.kube```
 - ```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config```
 - ```sudo chown $(id -u):$(id -g) $HOME/.kube/config```
 - ```kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml```
 - ```kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml```
 - Xem thông tin cluster:  ```kubectl cluster-info```
 - Xem thông tin token để join vào cluster: ```kubeadm token create --print-join-command```
 - Tại master, muốn xem thông tin các node: ```kubectl get node```
 - Xem thông tin một node: ```kubectl describe node/[node name]```
 - Xem thông tin cấu hình của kubectl: ```kubectl config view```. gồm context (cluster name, user)
   - Nội dung file config sẽ lưu thông tin của cluster. copy thư mục này từ máy master sang máy local thì có thể điều khiển cluster từ local
 - Xem thông tin context đang được sử dụng: ```kubectl config get-contexts```
 - Sử dụng một context khác: ```kubectl config use-context [context-name]```
 - Kiểm tra cluster có những pod nào đang chạy ở namespace mặc định: ```kubectl get po```. Xem toàn bộ namespace: ```kubectl get po -A```
K02: K8s dashboard
- Tải file sau
- Sửa lại:
  - Tìm thành phần Service và sửa nội dung port như sau:
  ```
    kind: Service
    apiVersion: v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    spec:
    type: NodePort
    ports:
        - port: 443
        targetPort: 8443
        nodePort: 31000
    selector:
        k8s-app: kubernetes-dashboard
  ```
  - comment thành phần sau để không sử dụng https:
  ```
    # ---

    # apiVersion: v1
    # kind: Secret
    # metadata:
    #   labels:
    #     k8s-app: kubernetes-dashboard
    #   name: kubernetes-dashboard-certs
    #   namespace: kubernetes-dashboard
    # type: Opaque
  ```

export KUBECONFIG=/home/hainv/.kube/config-mycluster
