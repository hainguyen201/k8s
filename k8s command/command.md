Lệnh cơ bản trong k8s

- kubectl kết nối đến các cluster thông qua config
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
- k8s dashboard:
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
- Kubectl
  - Cấu trúc chung: 
    - kubectl [command] [type] [name] [flags]
    - command: là lênh, hành động như get, apply , delete, describe
    - type: kiểu tài nguyên như: ns, no, po, svc. Lệnh kubectl api-resources để xem thông tin các loại tài nguyên
    - name: tên đối tượng tác động
    - flags: các thiết lập tùy chỉnh
  - kubectl get no -o wide: xem thống tin của các node dạng cụ thể
- Pod, node trong k8s
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
