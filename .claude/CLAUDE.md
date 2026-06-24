# Grapple Pack — Project Rules for Claude

## Quy tắc bắt buộc

### 1. Luôn cập nhật PROGRESS.md sau mỗi lần thay đổi

Sau **mỗi phiên làm việc** có chỉnh sửa code/scene/asset hoặc đưa ra quyết định thiết kế, bạn **bắt buộc** phải cập nhật file `PROGRESS.md` ở root project:

- Ghi **ngày tháng hiện tại** theo format `YYYY-MM-DD` (kèm session nếu cùng ngày, ví dụ `2026-04-23 (session 2)`)
- Tóm tắt ngắn gọn **đã làm gì** trong session đó (1 gạch đầu dòng cho mỗi thay đổi đáng kể)
- Cập nhật bảng "Trạng thái tổng quan" nếu hạng mục chuyển trạng thái (⬜ → ✅ hoặc tương tự)
- Tick các checkbox trong "Chi tiết từng hạng mục" nếu task con đã xong

**Khi nào ghi:**
- Sau khi sửa file `.gd`, `.tscn`, `.tres`, `.gdshader`
- Sau khi thay đổi `project.godot`, `export_presets.cfg`
- Sau khi đưa ra quyết định thiết kế hoặc kiến trúc

**Khi nào KHÔNG cần ghi:**
- Chỉ đọc file để trả lời câu hỏi
- Sửa lỗi typo nhỏ trong comment / docs
- Sửa chính file `PROGRESS.md`

### 2. Lấy ngày hiện tại như thế nào

Dùng ngày trong `currentDate` ở context system (được inject mỗi turn). KHÔNG đoán ngày.

## Bối cảnh dự án ngắn gọn

- **Grapple Pack** — game platformer 2D dùng grappling hook, gốc Godot 4 + GDScript (GitHub Game Off 2023, Overall #3, Gameplay #1)
- Fork hiện tại đang **port từ PC sang mobile (Android/iOS)** + mở rộng gameplay (kẻ thù, cửa chuyển màn)
- Engine: **Godot 4.6.2-stable** tại `D:/SafeHorizonInternShip/Godot_v4.6.2-stable_win64.exe`
- Viewport base: **180×320** (portrait), window override: **720×1280**, stretch mode: `canvas_items`
- Renderer: **GL Compatibility** (cho mobile)

## Tài liệu chính

- [IDEA.md](../IDEA.md) — kế hoạch tổng thể port mobile + features mới
- [PROGRESS.md](../PROGRESS.md) — tracker tiến độ (file BẮT BUỘC cập nhật)
- [BUILD.md](../BUILD.md) — hướng dẫn build APK/IPA

## Lưu ý kỹ thuật

- Mọi UI/HUD cần thiết kế theo **viewport 180×320 base**, không theo pixel của window 720×1280. Nút quá to là vì quên nhân với scale (1px viewport = 4px window).
- Touch HUD ở `ui/touch_controls/`. Có flag `force_show_on_desktop` để test trên PC.
- Input bắn grapple: ưu tiên touch (`InputEventScreenTouch`), fallback mouse cho PC.
