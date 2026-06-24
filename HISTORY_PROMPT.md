# Lịch sử Prompt — Grapple Pack (Mobile Port)

> Tổng hợp lại các yêu cầu (prompt) chính trong quá trình port Grapple Pack từ PC sang
> mobile + mở rộng gameplay, theo dòng thời gian **13/04/2026 → 15/06/2026**.
> File mang tính tái dựng để lưu hồ sơ đồ án; nhật ký kỹ thuật chi tiết xem [PROGRESS.md](PROGRESS.md).

---

## Tháng 4 — Khởi động & Touch Controls

### 13/04/2026
- Phân tích cấu trúc dự án gốc Grapple Pack (Godot 4, GDScript). Mục tiêu: port sang
  Android/iOS. Xác định các điểm phải đổi: input chuột/bàn phím → cảm ứng.
- Lập kế hoạch tổng thể, tạo `IDEA.md` và `PROGRESS.md`.

### 15/04/2026
- "Làm touch controls đi" — thêm HUD nút cảm ứng (Left/Right/Jump/Down/Pause), thêm
  `InputEventScreenTouch` cho action grapple, sửa `grapple.gd` để ngắm bằng vị trí chạm.

### 18/04/2026
- "Nút HUD không thấy / quá to" — thay TouchScreenButton bằng Button + StyleBoxFlat, bố
  cục lại theo viewport 180×320, thêm cờ `force_show_on_desktop` để test trên PC.

### 23/04/2026
- "Bố cục D-pad chưa trực quan, chỉnh lại" — D-pad dạng tam giác, ẩn HUD khi pause, visual
  feedback khi nhấn phím, đồng bộ style nút Pause/Close.
- "Viết tài liệu build APK/IPA" — tạo `BUILD.md`.

### 28/04/2026
- "Grapple trên mobile làm cho giống PC" — bỏ vùng tap riêng, chạm bất kỳ đâu (ngoài nút)
  để bắn móc, dùng chung logic với PC.

---

## Tháng 5 — Pause menu, i18n & Hệ thống kẻ thù

### 02/05/2026
- "Sửa pause menu + dịch tutorial sang tiếng Việt" — viết lại `pause.gd`, thêm nút ngôn ngữ
  EN/VI, dùng SystemFont cho tiếng Việt (tránh vỡ font KiwiSoda).

### 06/05/2026
- "Pause menu căn chỉnh xấu, lệch hàng khi tiếng Việt" — refactor Volume/Assist sang
  GridContainer 2 cột để label & control thẳng hàng.
- "Lưu lựa chọn ngôn ngữ, mặc định tiếng Việt" — persist locale vào `user://settings.cfg`,
  thêm signal `locale_changed`.

### 12/05/2026
- "Dịch cho hết text còn sót" — audit toàn bộ `text = ` trong tscn/script, bổ sung bản VI
  cho dialogue cuối game, fullscreen prompt, end screen, nút JUMP.

### 20/05/2026
- "Gỡ block Created By trong pause menu, căn lại cho gọn" — xoá credits, thêm spacer co giãn.

### 24/05/2026
- "Làm hệ thống kẻ thù" — thiết kế lại thành 4 loại quái dùng chung script `enemy.gd`
  (Mushroom/Goblin/Skeleton/Flying Eye) từ asset pack Monsters_Creatures_Fantasy. Cơ chế:
  Mushroom dậm đầu, các con khác giết bằng móc (1/2/3 phát). Tạo màn demo `enemy_demo.tscn`.

### 28/05/2026
- "Fix font lỗi khi đổi ngôn ngữ giữa chừng" — giữ font làm member, luôn gán font (không
  remove override) để tránh lỗi `Parameter fd is null`.

---

## Tháng 6 — Nhúng quái, fix bug gameplay & Build APK

### 31/05/2026 (nhiều phiên trong ngày)
- "Đọc NEXT_SESSION.md + PROGRESS.md rồi nhúng 4 quái vào màn chính `main.tscn`" — quét
  TileMap tìm sàn phẳng bằng raycast trong tree, đặt quái ở x≈0 (tháp leo thật).
- "Số lượng quái khoảng bao nhiêu con?" — tăng từ 4 lên **10 con**, rải đều theo độ khó.
- "Có đoạn hướng dẫn chưa dịch (nút S + nhảy để xuống)" — fix key 2 dòng trong VI_TRANSLATIONS.
- "Quái không có hoạt ảnh đánh + flash đỏ lúc có lúc không" — thêm anim Attack/Take Hit,
  fix flash đỏ luôn hiện (kể cả đòn kết liễu).
- "Đòn đánh không trúng (chạm mới chết)" — cho đòn gây sát thương đúng frame vung.
- "Kiểm tra kỹ logic chết, tôi lười test" — review code, fix player không hit-stop khi chết.
- "Đánh khi player chưa vào tầm / đánh trúng mà lần 2 mới chết" — thiết kế lại thành **1 vùng
  đánh AABB duy nhất** (hộp ôm thân + `attack_reach`), dùng chung cho cả kích anim lẫn tính trúng.

### 02/06/2026
- "Build APK kiểu gì?" — hướng dẫn toolchain. Cài JDK 17, tải Export Templates, cài Android
  SDK command-line tools vào ổ D (không đụng ổ C đầy).

### 05/06/2026
- "Báo lỗi Invalid Android SDK path" — chạy `sdkmanager` cài platform-tools + build-tools +
  android-34, accept licenses.
- "Bấm Export Project là xong à?" — khoá orientation Portrait, set package name
  `com.huy.grapplepack`, build ra `GO2026.apk` chạy được trên điện thoại.

### 08/06/2026
- "Cài chơi thử mà nút touch không ăn?" — fix `emulate_mouse_from_touch=true` để Button
  nhận được cú chạm trên thiết bị thật.

### 10/06/2026
- "Lời hướng dẫn vẫn là cho PC, sửa lại cho mobile, đừng sót cái nào" — đổi cả 5 prompt
  tutorial (EN + VI) sang ngôn ngữ touch (Chạm nút < > v, JUMP, II...).

### 13/06/2026
- "Nhấn 2 nút cùng lúc không được, code phải linh hoạt chứ" — viết lại touch controls thành
  **multi-touch theo từng ngón** (`index`); fix grapple chỉ bắn bằng touch thật + nhớ ngón đã bắn.

### 15/06/2026
- "Tăng nhẹ 3 nút trái + kiểm tra kỹ logic, đừng để bug" — tăng nút 22→26px, fix bug nút
  di chuyển kẹt sau khi pause (tự nhả nút khi paused).
- "Cập nhật hết file md (IDEA, PROGRESS), xoá NEXT_SESSION, tạo HISTORY_PROMPT, sửa README" —
  hoàn thiện tài liệu đồ án.

---

> **Tổng kết:** từ một game jam PC, dự án đã port thành công sang Android với touch controls
> đa chạm, hệ thống 4 loại kẻ thù có hoạt ảnh đánh & phản hồi sát thương, giao diện song ngữ
> EN/VI, và build được APK chạy trên thiết bị thật.
