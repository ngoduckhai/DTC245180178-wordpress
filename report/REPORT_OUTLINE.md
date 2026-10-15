# Dàn ý báo cáo tổng hợp DevOps (tối thiểu 10 trang)

## Trang bìa
- Trường, khoa/bộ môn, học phần, tên đề tài: Website quảng bá sản phẩm bằng WordPress triển khai với Docker Compose.
- Sinh viên, mã sinh viên, lớp, giảng viên, năm học.
- Chèn logo trường theo mẫu báo cáo thực tập của khoa.

## Gợi ý phân bổ trang
1. **Trang bìa** — thông tin sinh viên và đề tài.
2. **Mục lục + danh mục hình/bảng**.
3. **Chương 1. Tổng quan đề tài** — mục tiêu, phạm vi, lý do chọn WordPress; yêu cầu đầu vào/đầu ra.
4. **Chương 2. Kiến trúc hệ thống** — sơ đồ WordPress → MySQL; Nginx HTTPS; phpMyAdmin; Prometheus/exporters → Grafana; Docker logs → Promtail → Loki → Grafana.
   - Hình 2.1: sơ đồ kiến trúc tổng thể.
   - Hình 2.2: sơ đồ 3 mạng Docker (`frontend-net`, `backend-net`, `monitoring-net`).
5. **Chương 3. Công nghệ sử dụng** — Docker Compose, WordPress, MySQL, phpMyAdmin, Nginx, Prometheus, Grafana, cAdvisor, exporters, Loki, Promtail.
6. **Chương 4. Triển khai Commit 1** — cấu trúc thư mục, `.env`, tạo chứng chỉ, Nginx reverse proxy, database và website.
   - Hình 4.1: `docker compose ps`.
   - Hình 4.2: trang WordPress mở tại `https://localhost`.
   - Hình 4.3: HTTP chuyển hướng HTTPS.
   - Hình 4.4: phpMyAdmin truy cập qua `/dbadmin/`.
   - Hình 4.5: Git commit 1.
7. **Chương 5. Triển khai Commit 2** — Prometheus scrape targets, exporters, datasource Grafana.
   - Hình 5.1: Prometheus targets đều UP.
   - Hình 5.2: dashboard container CPU/memory.
   - Hình 5.3: biểu đồ Nginx/MySQL metrics.
   - Hình 5.4: Git commit 2.
8. **Chương 6. Triển khai Commit 3** — log pipeline, labels, LogQL.
   - Hình 6.1: log truy cập Nginx trong Grafana Explore.
   - Hình 6.2: kết quả truy vấn lỗi HTTP 500.
   - Hình 6.3: truy vấn lỗi WordPress.
   - Hình 6.4: Git commit 3.
9. **Chương 7. Bảo mật và hardening** — secrets qua `.env`, không commit secrets, network isolation, security headers, non-root khả thi/ngoại lệ, giới hạn truy cập admin, chứng chỉ tự ký và hạn chế.
10. **Chương 8. Kiểm thử và đánh giá** — test HTTPS, redirect, website/database, dashboard, log queries, restart policy, khôi phục dữ liệu. Ghi kết quả thực tế, không tự khai báo PASS nếu chưa kiểm tra.
11. **Kết luận và hướng phát triển** — backup tự động, TLS tin cậy, cảnh báo Grafana, giới hạn tài nguyên, triển khai cloud.
12. **Tài liệu tham khảo + phụ lục** — README, cấu hình chính, lệnh chạy, bảng kiểm thử.

## Bảng kiểm thử gợi ý
| ID | Nội dung | Cách kiểm tra | Kết quả cần ghi |
|---|---|---|---|
| T01 | Container chạy | `docker compose ps` | Trạng thái từng service |
| T02 | Website HTTPS | `curl -k -I https://localhost:8443/` | HTTP status và security headers |
| T03 | Redirect HTTP | `curl -I http://localhost:8081/` | 301 sang `https://localhost:8443/` |
| T04 | Kết nối DB | `docker compose logs db` và WordPress setup | DB healthy, trang mở được |
| T05 | Metrics | Prometheus targets | Các target UP |
| T06 | Dashboard | Grafana datasource + Explore | Có dữ liệu metrics |
| T07 | Loki | Grafana Explore / LogQL | Có log và query trả về |
| T08 | Bảo mật | `docker compose config`, kiểm tra `.gitignore` | Không lộ secrets, ports phù hợp |

## Lưu ý khi chụp ảnh
Chụp ảnh thật từ máy của bạn sau khi chạy thành công. Mỗi hình có số thứ tự, chú thích và 1–3 câu giải thích; không dùng ảnh minh họa giả làm kết quả thực tế.
