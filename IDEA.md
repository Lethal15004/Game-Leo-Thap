# Grapple Pack — Mobile Conversion (Đã hoàn thành)

## Tổng quan

Chuyển game Grapple Pack (PC) sang nền tảng mobile (Android) bằng Godot 4, đồng thời mở rộng
gameplay với hệ thống kẻ thù.

> **Trạng thái (cập nhật 2026-06-15):** đã hoàn thành phần lõi — touch controls multi-touch,
> hệ thống 4 quái + cơ chế đánh/feedback, nhúng quái vào màn chính, i18n EN/VI, và **build
> APK chạy được trên thiết bị Android thật**. Xem [PROGRESS.md](PROGRESS.md) cho nhật ký chi tiết.

---

## 1. Chuyển đổi sang Mobile ✅

### Input Touch Controls ✅

- HUD overlay nút cảm ứng (CanvasLayer `ui/touch_controls/`): Left/Right + Down (góc dưới
  trái), Jump (góc dưới phải), Pause (góc trên phải). **Tap vùng trống** để bắn grapple về
  hướng chạm.
- `grapple.gd` dùng vị trí touch thật (`InputEventScreenTouch`), fallback mouse khi test PC.
- **Multi-touch theo từng ngón** (`index`): giữ được nhiều nút cùng lúc (di chuyển + nhảy +
  grapple). Tự nhả nút khi pause để không bị kẹt phím.

### UI/UX ✅

- Nút thiết kế theo viewport 180×320; 3 nút trái 26×26px; khoá orientation Portrait.
- Pause menu chỉnh lại cho màn dọc + i18n EN/VI.
- Prompt hướng dẫn đổi từ ngôn ngữ PC (A/D, Spacebar, chuột) sang touch (Chạm nút < / > / v...).

### Export Android ✅

- Export **Android APK** qua Godot Export Templates (preset `com.huy.grapplepack`, arm64-v8a),
  build chạy được trên thiết bị thật. Toolchain: JDK 17 + Android SDK cmdline-tools. Xem [BUILD.md](BUILD.md).
- GL Compatibility renderer hoạt động tốt trên thiết bị.

---

## 2. Hệ thống Kẻ thù (Enemy System) ✅

> 4 loại quái dùng chung script `objects/enemies/enemy.gd` (`class_name Enemy`), sprite từ
> asset pack "Monsters_Creatures_Fantasy". Cơ chế tiêu diệt theo loại (stomp vs số lần móc).

### 4 loại quái ✅

| Tên            | Cách tiêu diệt        | Ghi chú                          |
| -------------- | --------------------- | -------------------------------- |
| 🍄 Mushroom    | Nhảy lên đầu (stomp)  | Quái duy nhất stompable          |
| 👁 Flying Eye  | Móc 1 phát            | Bay ngang, ping-pong patrol      |
| 👺 Goblin      | Móc 2 phát            | Đi bộ tuần tra                   |
| 💀 Skeleton    | Móc 3 phát            | Khó nhất, dồn về gần đỉnh tháp   |

- Patrol đi bộ (đổi hướng khi chạm tường / hết mép sàn) hoặc bay (ping-pong theo `patrol_range`).
- Chạm thân quái (không stomp) → player chết/respawn (trừ khi bật trợ giúp Bất tử).
- **Anim tấn công** (`Attack.png`): quái dừng + quay mặt + vung đánh khi player vào vùng đánh
  (hộp AABB ôm thân + `attack_reach`); trúng đúng frame vung → player chết.
- **Feedback damage**: quái flash đỏ + anim `Take Hit` mỗi lần trúng móc; player flash đỏ
  (hit-stop) trước khi respawn.
- Nhúng 10 quái vào `scenes/main.tscn` (độ khó tăng dần khi leo tháp).

### Cơ chế Stomp ✅

- Phát hiện stomp: `velocity.y > 0` (đang rơi) VÀ player ở rõ phía trên tâm quái.
- Gộp damage + stomp vào **1 Area2D sensor** (`StompZone`) phủ cả thân để tránh race condition;
  handler tự quyết stomp hay giết player.
