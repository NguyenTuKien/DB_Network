# Hướng dẫn Cấu hình và Thực hiện Giao dịch Phân tán (Distributed Transaction)

Dự án này cung cấp mã nguồn SQL để thiết lập cơ sở dữ liệu cho Hệ thống Rạp chiếu phim, đồng thời hướng dẫn cách cấu hình kết nối và thực hiện các giao dịch phân tán (distributed transaction) giữa các máy khác nhau (ví dụ: máy Master ở Hà Nội và máy Branch ở TP.HCM).

## Cấu trúc các tệp mã nguồn

1. **`init.sql`**: Kịch bản khởi tạo cơ sở dữ liệu `CineplexDB`, tạo bảng `BranchRevenue` (quản lý doanh thu chi nhánh) và chèn dữ liệu mẫu cho 6 chi nhánh rạp chiếu phim.
2. **`link.sql`**: Kịch bản cấu hình Linked Server trên máy Master. Cho phép máy Master kết nối đến máy Branch thông qua địa chỉ IP mạng LAN hoặc Tailscale. Bao gồm cấu hình tài khoản truy cập và thiết lập tùy chọn tắt `remote proc transaction promotion` nhằm tránh lỗi timeout của Distributed Transaction Coordinator (DTC).
3. **`transaction.sql`**: Kịch bản thực thi giao dịch phân tán. Mô phỏng việc chuyển 50 triệu VNĐ từ rạp chi nhánh (TP.HCM) về rạp tổng (Hà Nội). Sử dụng `BEGIN TRY...CATCH` và `BEGIN TRANSACTION` để đảm bảo tính toàn vẹn (ACID): một là thành công tất cả, hai là hoàn tác toàn bộ khi có sự cố mạng hoặc lỗi logic để bảo vệ dữ liệu.
4. **`docker-compose.yml`**: Tệp cấu hình hỗ trợ chạy Microsoft SQL Server (phiên bản 2022) trên môi trường Linux thông qua Docker.

---

## Hướng dẫn cài đặt và chạy trên Linux

Do Linux không hỗ trợ cài đặt SQL Server trực tiếp (native) giống như trên Windows, bạn cần sử dụng Docker để khởi chạy môi trường cơ sở dữ liệu.

1. **Cài đặt Docker và Docker Compose** trên máy tính Linux của bạn (nếu chưa có).
2. Mở Terminal (Command Line) tại thư mục chứa tệp `docker-compose.yml` (chính là thư mục dự án này).
3. Chạy lệnh sau để tải image và khởi động SQL Server dưới dạng nền (daemon):
   ```bash
   docker-compose up -d
   ```
4. Sau khi container khởi chạy thành công, bạn có thể kết nối vào SQL Server (sử dụng các công cụ như Azure Data Studio, DBeaver, hoặc sqlcmd) bằng thông tin sau:
   - **Server/Host:** `localhost` (hoặc IP của máy Linux)
   - **Username:** `sa`
   - **Password:** `KienPassword123!`
   - **Port:** Mặc định `1433` (do cấu hình đang dùng `network_mode: "host"`).

---

## Hướng dẫn cài đặt và chạy trên Windows

Trên Windows, bạn có thể cài đặt SQL Server trực tiếp (ví dụ: bản Developer hoặc Express Edition) và sử dụng SQL Server Management Studio (SSMS) để làm việc với mã nguồn.

### Cách kiểm tra và mở Port của SQL Server trên Windows
Để thực hiện giao dịch phân tán, các máy tính phải nhìn thấy nhau qua mạng. Cần đảm bảo cổng (Port) TCP/IP của SQL Server (mặc định là 1433) đã được kích hoạt.

1. Nhấn phím `Windows` và tìm kiếm công cụ **SQL Server Configuration Manager**, sau đó mở lên.
2. Ở menu bên trái, mở rộng phần **SQL Server Network Configuration**.
3. Nhấp chọn **Protocols for [Tên_Instance]** (thường tên instance mặc định là `MSSQLSERVER` hoặc `SQLEXPRESS`).
4. Ở khung bên phải, tìm đến giao thức **TCP/IP**. Nhấp chuột phải vào nó và chọn **Enable** (nếu đang ở trạng thái Disabled).
5. Nhấp chuột phải vào **TCP/IP** một lần nữa, chọn **Properties**.
6. Chuyển sang thẻ **IP Addresses**, cuộn xuống dưới cùng tới mục **IPAll**.
7. Kiểm tra giá trị: 
   - Xóa trống ở mục **TCP Dynamic Ports**.
   - Nhập `1433` vào mục **TCP Port**.
   - Nhấn **OK** để lưu lại.
8. Khởi động lại dịch vụ SQL Server: Chuyển lên mục **SQL Server Services** (menu trái), nhấp chuột phải vào **SQL Server ([Tên_Instance])** và chọn **Restart**.

*(Lưu ý: Bạn cũng cần cấu hình Windows Firewall để cho phép Inbound Traffic qua port 1433 thì máy khác mới truy cập được).*

---

## Hướng dẫn cài đặt và sử dụng Tailscale (Tạo mạng LAN ảo)

Để thực hiện giao dịch phân tán giữa các máy ở xa nhau (ví dụ: Hà Nội và TP.HCM) mà không cần cấu hình Router phức tạp, dự án sử dụng **Tailscale** để tạo mạng riêng ảo (VPN), giúp các máy tính có thể kết nối với nhau thông qua IP ảo y hệt như đang ở chung một mạng LAN.

### Cài đặt trên Windows
1. Truy cập trang chủ [Tailscale Download](https://tailscale.com/download/windows) và tải bộ cài đặt cho Windows.
2. Chạy file cài đặt (.exe) và tiến hành cài đặt như các phần mềm thông thường.
3. Sau khi cài xong, mở ứng dụng Tailscale. Một tab trình duyệt sẽ xuất hiện yêu cầu bạn đăng nhập (có thể dùng tài khoản Google, Microsoft, v.v.).
4. Đăng nhập thành công, bạn tìm biểu tượng Tailscale ở khay hệ thống (góc dưới bên phải Taskbar).
5. Nhấp chuột trái vào biểu tượng, bạn sẽ thấy địa chỉ IP Tailscale của máy tính mình (có dạng `100.x.x.x`). Bạn có thể nhấp vào đó để sao chép địa chỉ IP này.

### Cài đặt trên Linux
1. Mở Terminal và chạy lệnh cài đặt tự động của Tailscale:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   ```
2. Sau khi quá trình cài đặt hoàn tất, chạy lệnh sau để khởi động Tailscale và xác thực:
   ```bash
   sudo tailscale up
   ```
3. Lệnh trên sẽ in ra một đường link xác thực trên Terminal. Bạn hãy sao chép đường link đó, dán vào trình duyệt web và tiến hành đăng nhập.
4. Sau khi đăng nhập thành công, bạn có thể kiểm tra địa chỉ IP Tailscale của máy Linux bằng lệnh:
   ```bash
   tailscale ip -4
   ```

*(**Lưu ý cực kỳ quan trọng**: Bạn bắt buộc phải đăng nhập **cùng một tài khoản Tailscale** trên cả hai máy Master và Branch. Khi đó, cả hai máy mới nằm trong cùng một mạng và có thể "nhìn thấy" SQL Server của nhau).*

---

## Hướng dẫn thực thi quy trình Transaction

Để mô phỏng thành công giao dịch phân tán, bạn thực hiện theo các bước sau:

### Bước 1: Khởi tạo Database (Thực hiện trên CẢ HAI máy Master và Branch)
- Kết nối vào SQL Server của từng máy.
- Mở tệp `init.sql` và ấn **Execute** (hoặc chạy toàn bộ lệnh) để tạo cơ sở dữ liệu `CineplexDB` và dữ liệu mẫu.

### Bước 2: Cấu hình Linked Server (Chỉ thực hiện trên máy Master)
- Mở tệp `link.sql` trên máy Master.
- Ở dòng cấu hình `@datasrc`, thay địa chỉ IP `100.75.76.66` bằng địa chỉ IP (hoặc IP Tailscale) thực tế của máy Branch.
- Ở dòng `@rmtpassword`, đảm bảo mật khẩu khớp với mật khẩu tài khoản `sa` trên máy Branch.
- Bôi đen và chạy toàn bộ mã trong file để thiết lập kết nối liên kết từ máy Master sang máy Branch.

### Bước 3: Chạy giao dịch phân tán (Chỉ thực hiện trên máy Master)
- Mở tệp `transaction.sql` trên máy Master.
- Thực thi toàn bộ nội dung mã.
- Bạn sẽ thấy kết quả in ra cửa sổ **Messages** hiển thị trạng thái doanh thu trước khi giao dịch.
- Nếu mạng ổn định và kết nối thông suốt, 50 triệu VNĐ sẽ được trừ đi ở chi nhánh TP.HCM (tại máy Branch) và cộng thêm ở Hà Nội (tại máy Master), kết thúc bằng thông báo `"GIAO TÁC THÀNH CÔNG!"`.
- Nếu có lỗi xảy ra giữa chừng (như rớt mạng máy nhánh), transaction sẽ lập tức vào khối CATCH và thông báo `"XẢY RA LỖI - HỆ THỐNG ĐÃ HOÀN TÁC (ROLLBACK)..."` để đảm bảo an toàn số tiền hiện tại.