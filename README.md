🧰 TỔNG QUAN LAB

Pipeline flow:
```
[GitHub/GitLab] 
      ↓
   Jenkins (Docker)
      ↓
   Build + Push image → Local Registry
      ↓
   ArgoCD (trên k3s) auto sync YAML từ Git
      ↓
   Deploy app lên k3s
```

⚙️ 1️⃣ CÀI MÔI TRƯỜNG CƠ BẢN
✅ 1. Cài Rancher Desktop

Trang chủ: https://rancherdesktop.io/

Container engine: dockerd (moby)

Enable Kubernetes (k3s)

Resource limit:

CPU: 2 cores

RAM: 2GB

Tự động cài kubectl cho bạn

Sau khi cài:
```
kubectl get nodes
```
→ Nếu thấy Ready là xong.

✅ 2. Tạo thư mục dự án
```
mkdir C:\lab-ci-cd
cd C:\lab-ci-cd
```

🐳 2️⃣ TẠO FILE docker-compose.yml
Tạo file C:\lab-ci-cd\docker-compose.yml:
```
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - ./jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Xmx512m
    restart: unless-stopped

  registry:
    image: registry:2
    container_name: registry
    ports:
      - "5000:5000"
    restart: unless-stopped
```

Chạy:
```
docker compose up -d
```
🟢 Jenkins chạy tại http://localhost:8080
🟢 Local Docker registry tại localhost:5000

🧩 ArgoCD là gì?

ArgoCD (Argo Continuous Delivery) là một công cụ triển khai ứng dụng (CD tool) dành cho Kubernetes, được xây dựng theo nguyên tắc GitOps.

💡 Nói đơn giản:

ArgoCD tự động đồng bộ (sync) trạng thái của ứng dụng trong Kubernetes với trạng thái được định nghĩa trong Git repository.

🔁 “Git là nguồn sự thật (source of truth)” — nghĩa là mọi cấu hình (YAML, Helm chart, Kustomize...) của ứng dụng đều nằm trong Git.
ArgoCD sẽ:

Liên tục theo dõi Git repo đó

Nếu phát hiện có thay đổi (commit mới), nó sẽ tự động triển khai (apply) lên cluster

Và đảm bảo trạng thái thực tế (K8s) luôn khớp với Git

📘 Tóm tắt chức năng chính:
Tính năng	Mô tả
GitOps CD	Tự động triển khai ứng dụng từ Git.
Sync trạng thái	Đảm bảo cluster luôn giống với YAML trong Git.
Web UI / CLI / API	Có giao diện web đẹp để xem trạng thái ứng dụng.
Rollback dễ dàng	Có thể rollback về phiên bản trước chỉ bằng một cú nhấp.
Multi-cluster support	Quản lý và deploy đến nhiều cluster từ một nơi.

🚀 CÀI ARGOCD TRÊN k3s
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Password ArgoCD
Lấy mật khẩu mặc định sinh ngẫu nhiên của ArgoCD
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
hCxr5Y357Of14VEP
```

Sau đó expose ArgoCD:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Truy cập tại:
```
👉 https://localhost:8080
```

🔹 Bước 5 — Khai báo ArgoCD Application (CD tự động)

File application.yaml trong GitOps repo:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  project: default
  source:
    repoURL: https://gitlab.com/your-org/infra-deploy.git
    targetRevision: main
    path: k8s/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
✅ ArgoCD sẽ theo dõi repo infra-deploy, và tự động cập nhật K8s mỗi khi Jenkins commit tag image mới.

Sonarqube host cloud
https://sonarcloud.io/projects/create
