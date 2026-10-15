# Website giới thiệu sản phẩm WordPress — Dự án DevOps

Dự án sử dụng Docker Compose để triển khai: WordPress + MySQL + phpMyAdmin + Nginx làm reverse proxy HTTPS + Prometheus/Grafana + Loki/Promtail.

## Yêu cầu
- Docker Desktop (Windows/macOS) hoặc Docker Engine + Compose plugin (Linux)
- Git
- Có OpenSSL để tạo chứng chỉ tự ký cục bộ

## 1. Cấu hình thông tin bí mật
```bash
cp .env.example .env
```
Chỉnh sửa `.env` và thay mọi giá trị `REPLACE_WITH...` bằng mật khẩu dài, riêng biệt. Không bao giờ commit tệp `.env`.

Tài khoản MySQL exporter được tạo bởi `mysql/init/01-exporter-user.sh`, sử dụng `MYSQL_EXPORTER_PASSWORD` trong `.env`; mật khẩu không được lưu trong script. Các script khởi tạo MySQL chỉ chạy khi volume cơ sở dữ liệu còn trống. Nếu volume đã tồn tại, hãy chạy script cập nhật tài khoản một lần bằng lệnh `docker compose exec db bash /docker-entrypoint-initdb.d/01-exporter-user.sh`.

## 2. Tạo chứng chỉ HTTPS tự ký
Linux/macOS/Git Bash:
```bash
chmod +x scripts/generate-cert.sh
./scripts/generate-cert.sh
```
Windows PowerShell (tại thư mục gốc của dự án):
```powershell
New-Item -ItemType Directory -Force nginx/certs | Out-Null
openssl req -x509 -nodes -days 365 -newkey rsa:3072 `
  -keyout nginx/certs/localhost.key `
  -out nginx/certs/localhost.crt `
  -subj "/CN=localhost" `
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```
Trình duyệt sẽ hiển thị cảnh báo chứng chỉ vì chứng chỉ này được tự ký. Đây là điều bình thường trong môi trường thử nghiệm cục bộ, nhưng không phù hợp cho website production công khai.

## 3. Khởi động hệ thống
```bash
docker compose config
docker compose up -d
docker compose ps
```
Nếu dùng lệnh cũ, `docker-compose up -d` có tác dụng tương đương khi đã cài Docker Compose v1.

## 4. Các địa chỉ truy cập
- Website: https://localhost:8443/
- Kiểm tra chuyển hướng HTTP: http://localhost:8081/
- phpMyAdmin: https://localhost:8443/dbadmin/
- Grafana: http://localhost:3001/ (thông tin đăng nhập trong `.env`)
- Prometheus: có thể truy cập nội bộ tại `prometheus:9090`; chỉ mở cổng 9090 khi cần gỡ lỗi cục bộ.
- Loki: endpoint nội bộ `loki:3100`, được truy cập thông qua datasource Loki trong Grafana.

## 5. Kiểm tra
```bash
docker compose ps
docker compose logs --tail=100 nginx wordpress db
curl -k -I https://localhost:8443/
curl -I http://localhost:8081/
```
Có thể tạm thời mở giao diện Prometheus bằng cách thêm `ports: ["9090:9090"]` vào service, sau đó tạo lại service. Không mở trực tiếp Prometheus/Loki trên máy chủ công khai nếu không có biện pháp kiểm soát truy cập.

Trong Grafana, mở **Connections → Data sources** và xác nhận Prometheus cùng Loki đã được cấu hình. Nếu tạm thời mở cổng, hãy kiểm tra các target của Prometheus tại `http://localhost:9090/targets`.

## 6. Ví dụ truy vấn LogQL
Trong Grafana → Explore → chọn Loki:
```logql
{container="wp-nginx"}
{container="wp-nginx"} |= " 500 "
{container="wp-app"} |= "error"
```
Các nhãn container phụ thuộc vào metadata Docker discovery. Nếu nhãn của bạn khác, hãy dùng trình duyệt nhãn trong Explore và điều chỉnh selector. Trước tiên, hãy tạo lưu lượng truy cập vào website để có access log.

## 7. Các commit Git theo yêu cầu bài tập
Khởi tạo repository và commit hệ thống cơ bản (Commit 1):
```bash
git init
git add .gitignore .env.example docker-compose.yml nginx mysql scripts README.md
git commit -m "Commit 1: deploy WordPress MySQL phpMyAdmin and HTTPS Nginx"
```
Thêm hệ thống giám sát (Commit 2):
```bash
git add prometheus grafana
git add docker-compose.yml
git commit -m "Commit 2: add Prometheus Grafana and exporters"
```
Thêm hệ thống log tập trung (Commit 3):
```bash
git add loki promtail docker-compose.yml README.md
git commit -m "Commit 3: add Loki Promtail and LogQL examples"
```
Sau đó tạo repository trên GitHub với tên đáp ứng yêu cầu về mã sinh viên của giảng viên:
```bash
git branch -M main
git remote add origin https://github.com/YOUR-ACCOUNT/YOUR-REPOSITORY.git
git push -u origin main
```
Không push `.env`, khóa riêng tư hoặc chứng chỉ. `.gitignore` đã loại trừ các tệp chứng chỉ được tạo ra.

## 8. Bảo mật và giới hạn
- Các Docker network tách biệt proxy hướng ra bên ngoài, ứng dụng/cơ sở dữ liệu và các dịch vụ giám sát. `backend-net` và `monitoring-net` được đánh dấu là internal; proxy là service duy nhất công bố cổng web.
- Nginx hỗ trợ HTTPS, chuyển hướng HTTP→HTTPS, các security header cơ bản và ẩn phiên bản.
- Đã tắt tính năng đăng ký tài khoản Grafana; mật khẩu quản trị được lấy từ `.env`.
- `no-new-privileges` được bật cho hầu hết service. Service cAdvisor cần quyền truy cập host ở chế độ privileged để thu thập chỉ số container; node-exporter cũng sử dụng host mount và quyền truy cập PID. Đây là các ngoại lệ phục vụ giám sát, không nên để người dùng không đáng tin cậy truy cập.
- Image Apache chính thức của WordPress và image MySQL có thể cần quyền root trong quá trình khởi tạo. Ép dùng `user: 1000:1000` có thể khiến hệ thống không khởi động; nếu bắt buộc chạy non-root nghiêm ngặt, hãy tự build và kiểm thử image riêng.
- Script SQL khởi tạo exporter chỉ nhằm tiện cho môi trường thử nghiệm; cần đặt mật khẩu trước lần khởi động đầu tiên. Nếu volume cơ sở dữ liệu đã tồn tại, script sẽ không tự chạy.
- Content-Security-Policy hiện là cấu hình cơ bản, cho phép tài nguyên inline để tương thích với WordPress. Hãy kiểm tra giao diện và plugin, sau đó siết chặt chính sách trước khi đưa vào production.
- HTTPS tự ký chỉ dùng để minh họa. Khi triển khai công khai, hãy dùng chứng chỉ đáng tin cậy, firewall, secret manager, bản sao lưu và hạn chế quyền truy cập quản trị.

## 9. Khắc phục sự cố
- `docker compose config`: phát hiện biến còn thiếu và lỗi YAML.
- `docker compose logs -f db`: kiểm tra quá trình khởi động MySQL và thông tin đăng nhập.
- `docker compose logs -f wordpress`: kiểm tra kết nối cơ sở dữ liệu.
- `docker compose logs -f nginx`: kiểm tra đường dẫn chứng chỉ và lỗi proxy.
- Nếu bạn sửa SQL của exporter sau khi đã khởi tạo `db_data`, hãy tạo tài khoản exporter thủ công. Chỉ khi chấp nhận mất dữ liệu cục bộ, bạn mới nên xóa volume bằng `docker compose down -v` rồi khởi động lại. **Không chạy `down -v` nếu bạn cần giữ dữ liệu WordPress.**
