✅ Cách chạy kubectl port-forward với nohup
Cách 1 – Dùng nohup trực tiếp
```
nohup kubectl port-forward svc/argocd-server -n argocd 8081:443 > argocd.log 2>&1 &
```

- nohup: giúp tiến trình không bị kill khi bạn thoát terminal.
- > argocd.log 2>&1: ghi log vào file argocd.log.
- &: chạy nền.

👉 Kiểm tra tiến trình:
```
ps aux | grep port-forward
```

👉 Dừng lại khi không cần nữa:
```
pkill -f "kubectl port-forward svc/argocd-server"
```
Cách 2 – Dùng screen hoặc tmux
Nếu bạn hay SSH, tốt nhất dùng screen hoặc tmux để giữ session:
```
screen -S argocd
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

Sau đó nhấn:
Ctrl + A + D → tách (detach)

screen -r argocd → nối lại (reattach)

Cách 3 – Dùng systemd (ổn định lâu dài)
Nếu bạn muốn ArgoCD port-forward tự chạy khi khởi động máy, bạn có thể tạo service:
Tạo file /etc/systemd/system/argocd-portforward.service:
```
[Unit]
Description=ArgoCD Port Forward
After=network.target

[Service]
ExecStart=/usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8081:443
Restart=always
User=<your-user>

[Install]
WantedBy=multi-user.target
```

Kích hoạt:
```
sudo systemctl daemon-reload
sudo systemctl enable argocd-portforward
sudo systemctl start argocd-portforward
```
⚠️ Lưu ý

kubectl port-forward chỉ mở cổng nội bộ (localhost) → không thể truy cập từ máy khác.

Nếu bạn muốn truy cập từ xa, nên tạo ingress hoặc NodePort thay vì port-forward.
Ví dụ:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc -n argocd argocd-server
```

👉 Tóm lại:

Mục đích	Cách khuyên dùng
Chạy tạm, thử lab	nohup ✅
SSH server, lâu dài	screen / tmux ✅✅
Dịch vụ cố định	systemd service ✅✅✅

Bạn đang định chạy lab này trong WSL2 hay Windows PowerShell vậy?
→ Mình sẽ hướng dẫn cụ thể cách chạy nền phù hợp với môi trường của bạn (vì nohup chỉ dùng được trong Linux shell).