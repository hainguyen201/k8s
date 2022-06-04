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
  - Chạy lệnh sau để triển khai dashboard trên 
  - kiểm tra pod trên namespace kubenertes-dashboard
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
      - 
