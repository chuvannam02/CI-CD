# Thêm Helm repo Bitnami
```
helm repo add bitnami https://charts.bitnami.com/bitnam
helm repo update  
helm search repo bitnami
```

### Cài đặt PostgreSQL (bản thường)
Nếu bạn chỉ cần một instance PostgreSQL đơn giản (lab, dev):
```
helm install my-postgres bitnami/postgresql \
  --set auth.postgresPassword=mysecretpassword \
  --set primary.persistence.enabled=false
```

⚙️ Giải thích:

- my-postgres là tên release bạn đặt (tùy chỉnh được)

- auth.postgresPassword là mật khẩu của user postgres

- persistence.enabled=false để tắt volume khi chỉ test tạm thời trên Rancher Desktop (không ghi ổ đĩa)

- Nếu bạn muốn lưu dữ liệu vĩnh viễn, bỏ dòng persistence.enabled=false

### Lấy mật khẩu PostgreSQL
```
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default my-postgres -o jsonpath="{.data.postgres-password}" | base64 --decode)
echo $POSTGRES_PASSWORD
```

### Kết nối từ máy bạn (Windows)
Chạy port-forward:
```
kubectl port-forward svc/my-postgres 5432:5432
```

Sau đó mở DBeaver / TablePlus / psql:

- Host: 127.0.0.1

- Port: 5432

- User: postgres

- Password: mysecretpassword (hoặc giá trị bạn lấy ở bước trên)

- Database: postgres

### Mở và custom values.yaml
Bạn mở file postgresql/values.yaml, và có thể sửa các mục chính:

🔹 Thông tin truy cập
```
auth:
  enablePostgresUser: true
  postgresPassword: "myStrongPassword123"
  username: "myuser"
  password: "myuserpass"
  database: "mydb"
```

🔹 Bật volume (hoặc tắt nếu test)
```
primary:
  persistence:
    enabled: false  # nếu test, để tránh chiếm ổ cứng
```

🔹 Mở port ra ngoài (nếu cần kết nối từ host)
```
service:
  type: NodePort
  nodePorts:
    postgresql: 32432
```
Khi đó bạn có thể kết nối từ Windows qua localhost:32432.

### Deploy chart đã custom lên Rancher Desktop
Từ thư mục chứa chart (ví dụ postgresql/):
```
helm install my-postgres ./postgresql
```
Xem log:
```
kubectl get pods
```

Nếu muốn debug khi lỗi:
```
helm install my-postgres ./postgresql --debug
```

### Cập nhật khi thay đổi values.yaml
Sau khi bạn sửa cấu hình (ví dụ đổi password hoặc bật volume), chỉ cần:
```
helm upgrade my-postgres ./postgresql -f postgresql/values.yaml
```

🧩 5️⃣ Kiểm tra truy cập
Port-forward nhanh:
```
kubectl port-forward svc/my-postgres-postgresql 5432:5432
```

Rồi kết nối từ DBeaver hoặc psql:
```
Host: 127.0.0.1
Port: 5432
User: myuser
Password: myuserpass
Database: mydb
```

### (Tuỳ chọn) Cài bản PostgreSQL HA (High Availability)
Nếu bạn muốn thử cluster PostgreSQL có failover:
```
helm install my-postgres-ha bitnami/postgresql-ha \
  --set postgresql.password=mysecretpassword \
  --set persistence.storageClass="local-path"
```

Bản ha dùng Patroni, etcd, và pgpool → khá nặng (RAM > 2 GB).
Nếu Rancher Desktop của bạn có <4GB RAM thì không nên dùng HA.

# Gỡ cài đặt khi không cần
```
helm uninstall my-postgres
```

# Tải Helm chart Bitnami PostgreSQL về local
```
helm pull bitnami/postgresql --untar
```

Lệnh này sẽ:

- Tải chart mới nhất từ repo Bitnami.

- Giải nén ra thư mục ./postgresql.

Bạn sẽ thấy cấu trúc thư mục như sau:

```
postgresql/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── secrets.yaml
│   ├── svc.yaml
│   └── ...
└── README.md
```