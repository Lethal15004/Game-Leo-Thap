# BÁO CÁO BÀN GIAO SẢN PHẨM

## 1. Thông tin dự án

- **Tên dự án:** Leo Tháp (Grapple Pack Mobile)
- **Sinh viên thực hiện:** Phạm Lê Văn Huy
- **Mã sinh viên:** [… điền MSSV …]
- **Đề tài:** Ứng dụng AI để phát triển và chuyển đổi game 2D từ nền tảng PC sang điện thoại di động (Android)

### Nền tảng phát triển

- **Godot Engine 4.6.2** (GL Compatibility renderer — tối ưu cho thiết bị di động)
- **GDScript** (ngôn ngữ lập trình của Godot)
- **Visual Studio Code** (kèm tiện ích mở rộng Claude Code)
- **Claude (Anthropic)** — AI Agent hỗ trợ phát triển

### Mô tả sản phẩm

Leo Tháp là trò chơi 2D thể loại platformer sử dụng cơ chế **dây móc (grappling hook)**, được
phát triển dựa trên mã nguồn mở của dự án **Grapple Pack** (tác giả Diego Escalante và Gabriel
Páez — entry đạt giải GitHub Game Off 2023, hạng 3 Tổng thể và hạng 1 Gameplay). Người chơi
điều khiển nhân vật leo lên đỉnh một tòa tháp, dùng dây móc để đu qua các vực, vượt chướng ngại
vật (lưỡi cưa, gai), né và tiêu diệt kẻ thù, với mục tiêu thoát ra ngoài trong thời gian ngắn nhất.

Đề tài tập trung vào việc **chuyển đổi trò chơi từ nền tảng PC (điều khiển bàn phím + chuột)
sang nền tảng di động Android (điều khiển cảm ứng đa điểm)**, đồng thời mở rộng nội dung
gameplay và Việt hóa toàn bộ trò chơi.

Trong quá trình thực hiện, công cụ AI được sử dụng để hỗ trợ phân tích mã nguồn, đề xuất giải
pháp kỹ thuật, chỉnh sửa giao diện, phát triển tính năng mới và khắc phục lỗi phát sinh.

### Các tính năng đã được bổ sung / cải tiến

- **Hệ thống điều khiển cảm ứng đa điểm (multi-touch):** nút di chuyển trái/phải/xuống, nhảy,
  tạm dừng; chạm vùng trống để ngắm và bắn dây móc. Giữ nhiều nút cùng lúc (di chuyển + nhảy +
  móc) theo từng ngón tay.
- **Hệ thống kẻ thù 4 loại** (Nấm, Mắt bay, Quỷ lùn, Bộ xương) với cơ chế tiêu diệt riêng:
  dẫm lên đầu (stomp) hoặc bắn dây móc nhiều lần; có hoạt ảnh tấn công và phản hồi khi trúng đòn.
- **Hệ thống gợi ý (hint) lần đầu:** hướng dẫn cách tiêu diệt từng loại quái và cách dùng điểm lưu.
- **Thay đổi nhân vật mặc định** bằng nhân vật mới có hoạt ảnh (Geralt — bộ sprite CC0).
- **Việt hóa toàn bộ trò chơi:** lời thoại hướng dẫn, menu tạm dừng, màn hình kết thúc.
- **Tinh giản nội dung:** loại bỏ các đoạn hội thoại cốt truyện, chỉ giữ lại hướng dẫn cần thiết.
- **Cải tiến luồng vào game:** bỏ đoạn intro rơi từ trên cao, người chơi điều khiển được ngay.
- **Đổi tên trò chơi** thành "Leo Tháp".
- **Hệ thống âm thanh** cho các sự kiện trong trò chơi (bước chân, bắn móc, trúng đòn, lưu điểm).
- **Tối ưu và sửa lỗi gameplay** (xử lý kẹt nút khi tạm dừng, vị trí spawn kẻ thù, va chạm).
- **Đóng gói sản phẩm** thành bản cài đặt Android (APK) chạy được trên thiết bị thật.

---

## 2. Công cụ và tài nguyên sử dụng

1. **Godot Engine 4.6.2** — game engine mã nguồn mở, miễn phí. Dùng để phát triển trò chơi và
   tạo bản build (Android APK).
2. **Visual Studio Code** — trình soạn thảo mã nguồn miễn phí, dùng để chỉnh sửa mã GDScript.
3. **Claude (Anthropic) — Claude Code AI Agent** — công cụ AI hỗ trợ phân tích mã nguồn, đề
   xuất giải pháp và phát triển tính năng.
4. **Android SDK + JDK 17** — bộ công cụ biên dịch, ký và đóng gói file APK.
5. **GitHub** — nền tảng quản lý và lưu trữ mã nguồn.
6. **Git** — công cụ quản lý phiên bản mã nguồn.

### Tài nguyên (asset) sử dụng

- **Mã nguồn gốc:** Grapple Pack (mã nguồn mở, GitHub Game Off 2023).
- **Sprite nhân vật mới:** "Sprite Pack 3" của GrafxKid — giấy phép **CC0 1.0** (miễn phí, không
  cần ghi công).
- **Sprite kẻ thù:** "Monsters Creatures Fantasy" của LuizMelo — miễn phí.

---

## 3. Mã nguồn sản phẩm

**Kho mã nguồn GitHub:**
[… điền link GitHub fork của sinh viên …]

Mã nguồn bao gồm toàn bộ project Godot và các tài nguyên phục vụ quá trình phát triển sản phẩm.

> *Ghi chú: dự án được phát triển trên nhánh fork từ kho gốc*
> *https://github.com/diego-escalante/GO2023-GrapplePack*

---

## 4. Bản build sản phẩm

**File bàn giao:** [… điền link Google Drive …]

Bản build là file cài đặt Android (**.apk**), đã được kiểm thử và chạy trực tiếp trên thiết bị
Android mà không cần cài đặt Godot.

- Tên gói ứng dụng: `com.huy.grapplepack`
- Phiên bản: 1.0.0
- Kiến trúc: arm64-v8a
- Hướng màn hình: dọc (Portrait)

---

## 5. Tài liệu Prompt AI

**File Prompt:** [… điền link Google Drive …]

Tài liệu bao gồm toàn bộ nội dung trao đổi giữa sinh viên và AI trong quá trình phát triển sản
phẩm: từ giai đoạn nghiên cứu mã nguồn, xây dựng ý tưởng, chỉnh sửa giao diện, bổ sung tính
năng, cho đến sửa lỗi và hoàn thiện sản phẩm.

---

## 6. Video hướng dẫn biên dịch game

**Link video:** [… điền link …]

Nội dung video:
- Mở project bằng Godot Engine.
- Kiểm tra scene chính và cấu hình xuất bản (Export Preset Android).
- Thực hiện build sản phẩm ra file APK.
- Cài đặt và chạy thử bản build trên thiết bị Android.

---

## 7. Video hướng dẫn chỉnh sửa hoặc phát triển thêm

**Link video:** [… điền link …]

Nội dung video:
- Sử dụng AI (Claude Code) để phân tích mã nguồn.
- Thực hiện chỉnh sửa hoặc bổ sung tính năng.
- Kiểm tra kết quả sau khi AI hỗ trợ chỉnh sửa.
- Chạy thử sản phẩm sau khi hoàn thành.

---

## 8. Hướng dẫn cài đặt

### Yêu cầu hệ thống

- Hệ điều hành Android 7.0 trở lên.
- RAM tối thiểu 2 GB.
- Dung lượng trống tối thiểu 150 MB.

### Các bước cài đặt

- **Bước 1:** Sao chép file `Leo-Thap.apk` vào thiết bị Android.
- **Bước 2:** Mở file APK, cho phép cài đặt từ "Nguồn không xác định" nếu được hỏi.
- **Bước 3:** Nhấn Cài đặt, sau đó mở ứng dụng "Leo Tháp" để chơi.

> **Lưu ý:**
> - Trò chơi khóa hướng màn hình dọc (Portrait).
> - Trò chơi không yêu cầu kết nối mạng và không cài đặt thêm phần mềm hỗ trợ.

---

## 9. Video hướng dẫn chơi thử

**Link video:** [… điền link …]

Nội dung video:
- Khởi động trò chơi.
- Giới thiệu giao diện và các nút điều khiển cảm ứng.
- Điều khiển nhân vật di chuyển, nhảy, bắn dây móc để leo tháp.
- Né lưỡi cưa/gai và tiêu diệt kẻ thù (dẫm đầu / bắn móc).
- Cơ chế điểm lưu (checkpoint) và hồi sinh.
- Minh họa màn hình kết thúc (thời gian hoàn thành và số lần chết).

---

## 10. Kết luận

Đề tài đã hoàn thành việc ứng dụng AI vào quá trình phát triển phần mềm thông qua việc cải tiến,
Việt hóa và chuyển đổi một trò chơi mã nguồn mở từ nền tảng PC sang nền tảng di động Android bằng
Godot Engine. Sản phẩm cuối cùng hoạt động ổn định, đóng gói thành file APK chạy độc lập trên
thiết bị Android, và đáp ứng đầy đủ các yêu cầu được giao trong quá trình thực tập.
