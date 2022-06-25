# Lệnh cơ bản trong k8s

## 1. kubectl kết nối đến các cluster thông qua config
  - kubectl config view: xem thông tin của các cluster 
  - Để kết nối thêm các cluster khác, xem thư mục ~/.kube/config của cluster muốn kết nối thêm (ở máy master).
    - Copy file config từ cluster đấy đến máy host.
    - chạy lệnh: 
      - export KUBECONFIG= ~/.kube/config:~/.kube/config-mycluster
      - kubectl config view --flatten > ~/.kube/config-temp
      - mv ~/.kube/config_temp ~/.kube/config
      - File config mới trộn giữa 2 file cũ được lưu trong biến môi trường KUBCONFIG (config máy host và cụm cluster mới)
  
 - Xem các context (ngữ cảnh): kubectl config get-contexts
 - Chuyển context: kubectl config use-context [context-name]
## 2. k8s dashboard:
  - Tải file https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
  - Tìm đến kind là service và sửa như sau: Thêm type:Nodeport và thêm cổng nodeport:
  - ```
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
        k8s-app: kubernetes-dashboard ```
  - comment lại các dòng secret để sử dụng sceret thủ công:
  - ```# apiVersion: v1
    # kind: Secret
    # metadata:
    #   labels:
    #     k8s-app: kubernetes-dashboard
    #   name: kubernetes-dashboard-certs
    #   namespace: kubernetes-dashboard
    # type: Opaque 
    ```
  - Chạy lệnh sau để triển khai dashboard trên: kubectl apply -f dashboard.yaml
  - kiểm tra pod trên namespace kubenertes-dashboard: kubectl get po -n kubernetes-dashboard
  - Tạo cert riêng:
    - mkdir certs
    - chmod 777 certs
    - openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
    - openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
    - sudo chmod -R 777 certs
    - kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kubernetes-dashboard
    - xem thông tin ip của các node trong cluster: kubectl get node -o wide
    - Truy cập vào địa chỉ của dashboard thông qua địa chỉ của node, có thể sử dụng bất kỳ ip nào trong cluster. Chú ý cần sử dụng giao thức https và cổng 31000 theo cấu hình trong file yaml ở trên. Ví dụ: https://192.168.59.100:31000/
    - Tạo user và nhập token
      - Tạo file admin-user.yaml có nội dung:
      - 
      - kubectl apply -f admin-user.yaml: chạy service account admin-user
      - kubectl get secreate -n kubenertes-dashboard: xem danh sách các servicem, copy tên của service admin-user vừa tạo (admin-user-token-xpwdc)
      - kubectl describe secret/admin-user-token-xpwdc -n kubernetes-dashboard: Xem thông tin cụ thể của secret admin-user và copy token. Sử dụng token này để đăng nhập vào kubernetes-dashboard
## 3. Kubectl
  - Cấu trúc chung: 
    - kubectl [command] [type] [name] [flags]
    - command: là lênh, hành động như get, apply , delete, describe
    - type: kiểu tài nguyên như: ns, no, po, svc. Lệnh kubectl api-resources để xem thông tin các loại tài nguyên
    - name: tên đối tượng tác động
    - flags: các thiết lập tùy chỉnh
  - kubectl get no -o wide: xem thống tin của các node dạng cụ thể
## 4. Pod, node trong k8s
  - k8s bọc các containers với nhau trong một cấu trúc là pod. Các container cùng pod sẽ chia sẻ với nhau tài nguyên và mạng cục bộ của pod
  - pod là đơn vị nhỏ nhất để k8s thực hiện việc nhân bản
  - pod có nhiều container mà pod là đơn vị để scale nên nếu có thể thì cấu hình ứng dụng sao cho một pod có ít container nhất càng tốt
    - Cách sử dụng hiệu quả và thông dụng nhất là 1 pod chứa 1 container
    - pod loại chạy nhiều container trong đó thường đóng gói 1 ứng dụng xây dựng với sự phối hợp chặt chẽ từ nhiều container trong một khu vực cách ly, chúng chia sẻ tài nguyên ổ đĩa, mạng cho nhau
  - file manifest.yaml:
    - Là nơi khai báo các thành phần của container như pod, nodeport, service,...
    - Ví dụ:
      - Tạo file 1-swarmtest-node.yaml có nội dung
      - ```
        apiVersion: v1 #
        kind: Pod
        metadata:
          labels:
            app: app1
            ungdung: ungdung1
          name: ungdungnode
        spec:
          containers:
          - name: c1
            image: ichte/swarmtest:node
            resources:
              limits:
                memory: "150M" # sử dụng 150MB bộ nhớ
                cpu: "100m" # 1 core tương ứng với 1000m
            ports:
              - containerPort: 8085
        ```
      - apiVersion: version
      - kind: đại diện cho loại tài nguyên
      - metadata: 
      - spec: mô tả thông tin của pod
  - Xem mô tả của pod: kubectl describe po/[pod name]
  - Xem các sự kiện xảy ra trên cluster: kubectl get events
  - Xem thông tin file yaml của pod: kubectl get po/[pod name] -o yaml
  - Để sửa thông tin của pod ví dụ sửa image, ta sử dụng lệnh: kubectl edit po/[pod_name], sau đó sửa nội dung file yaml và lưu lại. Cũng có thể sửa trên giao diện dashboard
  - xem log của pod: kubectl logs po/[pod_name]
  - Thực thi một lệnh trong po: kubectl exec po/[pod_name] -- [command]. Ex: kubectl exec po/ungdungnode -- ls /
  - Truy cập vào giao diện dòng lệnh của po: kubectl exec -it [pod_name] -- bash. Trong trường hợp pod có nhiều container thì cần chỉ định rõ: kubectl exec -it [pod_name] -c [container] bash. Để thoát ra nhập exit và ấn enter
  - Để truy cập vào ứng dụng, cần thông qua proxy: kubctl proxy. Nhập địa chỉ trên vào browser
    - Để xem đường dẫn của ứng dụng: kubectl get po/[pod_name] -o yaml
## 5. Pod có nhiều container
- Khi chạy lệnh kubectl exec, thì mặc định sẽ chạy ở container được khai báo đầu tiên
- Muốn chạy ở container được chỉ định: kubectl exec [pod_name] -c [container_name] -- command
- Khi muốn chỉ đinh node cụ thể chạy pod, sử dụng thuộc tính nodeSelector, chỉ cần gán 
  - xem mô tả của một node chỉ đinh: kubectl describe node/[node_name]
  - Thông tin labels có dạng: kubernetes.io/hostname=minikube
  - Gán gía trị trên cho thuộc tính nodeSelector:
  - ```
    spec:
      nodeSelector:
        kubernetes.io/hostname: minikube
    ```
- Xóa 1 loạt các pod: kubectl delete -f [folder chứa nhiều pod| file pod]

## 6 Replicaset
- Xem thông tin tất cả các loại dịch vụ: kubectl get all -o wide
- Xem thông tin của replicaset: kubectl get rs -o wide
- Xem manifest của rs: kubctl get rs -o yaml
- Xem  chi tiết 1 replicaset: kubectl describe rs/[replicase_name]
- Xem thông tin các pod theo nhãn: kubectl get po -l "app=rsapp"
  - Xuất hiện thêm mục Controlled By: ReplicaSet/rsapp. 
- Khi thực hiện delete 1 trong 2 pod của replicasSet, sẽ tự động tạo thêm replicas khác
- Khi xóa tất cả pod cũng sẽ tự động tạo lại pod mới
- Khi xóa replicaset thì các pod bên trong cũng sẽ bị xóa theo
- Khi xóa nhãn của một pod, pod đó không còn sự quản lý của replicaset, nên nó sẽ tạo thêm 1 pod mới 
  - Xóa label của pod: kubectl label pod/[pod_name] [tên nhãn]-
  - Khi xóa replicaset, các pod nó quản lý sẽ bị xóa theo, nhưng cái pod đã xóa label vẫn tồn tại do không còn dưới sự quản lý của replicaset cũ nữa
- Khi một pod đã chạy từ trước có nhãn mà replicas quản lý, thì khi replicaset được triển khai, pod đó sẽ được replicaset quản lý và chỉ tạo thêm n-1 pod còn lại. Và khi xóa replicaset thì tất cả các pod do nó quản lý sẽ bị xóa theo
#### 6.1 Horizontal Pod AutoScaler (HPA): 
- Cần chạy replicaset trước, sau đó HPA sẽ tham chiếu đến replicaset đó thông qua metadata là name
- Cho phép thiết lập số lượng pod tối đa và tối thiểu của replicaset. Việc điều chỉnh số lượng pod sẽ dựa và traffic, lượng chịu tải của pod. Nếu traffic nhỏ thì tạo ít, traffic nhiều thì tạo đến tối đa
- Tạo ra replicaset trước, sau đó là HPA
- Khi muốn sửa HPA: sửa file yaml của hpa -> chạy apply để cập nhật lại
## 7. Deployment
- Xem liên tục: watch -n 1 kubectl get all -o wide
- Deploy tạo ra các replicaset
- Khi thực hiện sửa file yaml, chỉ cần chạy lại lệnh apply
- Sau khi sửa và chạy lại, deployment sẽ tạo ra replicaset mới, và scale replicaset cũ về 0, và vẫn giữ replicaset này nhằm phục vụ cho việc rollback lại phiên bản cũ khi cần thiết
- Kiểm tra các lần cập nhật: kubectl rollout history  deploy/[deploy_name]
- Xem thông tin chi tiết của lần cập nhật thứ n: kubectl rollout history  deploy/[deploy_name] --revision=n
- Muốn quay lại bản cập nhật thứ n: kubectl rollout undo deploy/deployapp --to-revision=n
- Scale deployment: kubectl scale deploy/deployapp --replicas=3
- Scale tự đông, scale trong một khoảng: kubectl autoscale deploy/deployapp --min=4 --max=7
- Lưu file yaml: kubectl get hpa/deployapp -o yaml > 2.hpa.yaml
## 8. Service
### metrics server
- Giám sát tài nguyên của các pod trên  hệ thống
- Tải về: https://github.com/kubernetes-sigs/metrics-server/releases/download/metrics-server-helm-chart-3.8.2/components.yaml
- Sửa đối tham số args:
- ```
  args:
    - --cert-dir=/tmp
    - --secure-port=4443
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-use-node-status-port
    - --kubelet-insecure-tls
    - --metric-resolution=15s
  ```
- Apply file yaml
- Kiểm tra tài nguyên các pod: kubectl top pod
- Kiểm tra tài nguyên các node: kubectl top node
### services:
- Service là một đối tượng trừu tượng, nó xác đinh ra một nhóm các pod và chính sách để truy cập đến pod đó. Nhóm các pod mà service xác định thường dùng kỹ thuật selector (Chọn các pod của service theo label của pod)
- Có thể hiểu service là dịch vụ mạng, tạo cơ chế cân bằng tải truy cập đến điểm cuối mà service đó phục vụ
- Khi client gửi request đến service theo ip thì nó sẽ tự điều phối tới các pod tương ứng
- Khi trên hệ thống có cùng tên vs service thì serivce sẽ lấy endpoint đó làm của nó.
- Service gần giống proxy.
### Secret tls
- openssl req -nodes -newkey rsa:2048 -keyout tls.key  -out ca.csr -subj "/CN=xuanthulab.net"
- openssl x509 -req -sha256 -days 365 -in ca.csr -signkey tls.key -out tls.crt
- kubectl create secret tls secret-nginx-cert --cert=certs/tls.crt  --key=certs/tls.key
## DeamonSet
- Đảm bảo chạy trên mỗi node một bản copy của pod. Triển khai DeamonSet khi cần ở mỗi máy (node) một pod, thường dùng cho các ứng dụng như thu thập log, tạo ổ đĩa trên mỗi node
- Bình thường node master sẽ không được phép chạy các pod
- Để xóa: kubetl taint node [node_name] node-role.kubernetes.io/master-
## Job
- Có chức năng tạo pod đảm bảo nó chạy và kết thúc thành công. Khi các pod do job tạo và kết thúc thành công thì job hoàn thành. 
- Khi xóa job thì các pod tạo ra cũng xóa theo. 
- Một job có thể tạo ra các pod chạy tuần tự hoặc song song. 
- Sử dụng job khi muốn thi hành một vài chức năng hoàn thành xong thì dừng (ví dụ backup, kiểm tra,...)
- Khi Job tạo pod, Pod chưa hoàn thành nếu Pod bị xóa, lỗi node,.. sẽ thực hiện tạo Pod khác để thi hành tác vụ
```
  # Số lần chạy POD thành công
  completions: 10
  # Số lần tạo chạy lại POD bị lỗi, trước khi đánh dấu job thất bại
  backoffLimit: 3
  # Số POD chạy song song
  parallelism: 2
  # Số giây tối đa của JOB, quá thời hạn trên hệ thống ngắt JOB
  activeDeadlineSeconds: 120

```
## cronjob
- Chạy các job theo một lịch định sẵn. Việc khai báo giống Cron của linux