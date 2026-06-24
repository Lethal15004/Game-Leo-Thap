# Prompt mô tả dự án — Grapple Pack (Mobile Port)

> Dán toàn bộ nội dung dưới đây cho bất kỳ AI nào để nó hiểu trọn vẹn dự án này:
> bối cảnh, kiến trúc, mọi tính năng, mọi file, mọi quyết định kỹ thuật.

---

## 0. Vai trò & bối cảnh

Bạn là một kỹ sư game Godot. Tôi đang làm một đồ án thực tập: **port game platformer 2D
"Grapple Pack" từ PC sang mobile (Android)** bằng Godot, đồng thời mở rộng gameplay. Dưới đây
là toàn bộ mô tả dự án để bạn nắm ngữ cảnh trước khi hỗ trợ tôi. Hãy trả lời bằng tiếng Việt.

**Game gốc:** "Grapple Pack" — thắng hạng Overall #3 và Gameplay #1 trong GitHub Game Off 2023
(chủ đề "scale"), gốc Godot 4 + GDScript của Diego Escalante & GaboDBabo. Lối chơi: nhân vật
dùng **súng móc (grappling hook)** để đu, leo lên đỉnh một cái tháp dài, vừa né bẫy vừa giải đố
vật lý. Bản fork này giữ nguyên lõi đó và thêm: điều khiển cảm ứng, hệ thống kẻ thù, song ngữ.

## 1. Môi trường kỹ thuật

- **Engine:** Godot **4.6.2-stable** (bản standard, không phải .NET). Ngôn ngữ: **GDScript**.
- **Renderer:** **GL Compatibility** (OpenGL ES — tương thích mobile rộng).
- **Viewport gốc:** **180×320 px** (dọc/portrait), pixel-art. Window override 360×640 (PC).
  Stretch mode = `canvas_items`. Khoá orientation = Portrait. **Mọi UI/HUD phải tính theo
  toạ độ viewport 180×320**, không theo pixel cửa sổ.
- **Nền tảng đích:** Android (đã build APK chạy được trên thiết bị thật). iOS để ngỏ.
- **Tilemap:** dùng `TileMap` legacy (format=2), tile **16×16 px** (lưu ý: KHÔNG phải 8px).

## 2. Cấu trúc & tài liệu

- `IDEA.md` — kế hoạch + trạng thái các tính năng (đã hoàn thành).
- `PROGRESS.md` — nhật ký phát triển chi tiết theo ngày (bắt buộc cập nhật mỗi phiên).
- `BUILD.md` — hướng dẫn build APK/IPA.
- `HISTORY_PROMPT.md` — lịch sử các yêu cầu theo dòng thời gian.
- `.claude/CLAUDE.md` — quy tắc dự án (luôn cập nhật PROGRESS.md, dùng ngày hiện tại...).

## 3. Cấu trúc autoload (singleton — `project.godot`)

Theo thứ tự nạp: `ScreenFade`, `TimeController`, `GameConsts`, `GameState`,
`DialogueController`, `MusicPlayer`, `SoundController`.

- **GameConsts** (`common/game_consts.gd`): hằng `PIXELS_PER_UNIT = 16`.
- **GameState** (`common/game_state.gd`): trạng thái toàn cục. Gồm:
  - Cờ trợ giúp (Assist): `slow_mode`, `invinsible` (bất tử), `long_grapple` (móc dài).
  - `user_locale` (mặc định `"vi"`), lưu/đọc `user://settings.cfg`, hàm `set_locale()` phát
    signal `locale_changed(new_locale)`.
  - `elapsed_time`, `deaths` (đếm số lần được cứu).
  - Checkpoint: `set_checkpoint()`, `move_player_to_checkpoint()` (đặt player về `_spawn_position`
    = vị trí checkpoint + lệch xuống 6.5px), `is_checkpoint_set()`, `reset_for_new_level()`.
- **SoundController** (`common/sound_controller.gd`): `play(stream, volume_db, pitch)`.
- **TimeController** (`common/time_controller.gd`): scale tốc độ thời gian (hiệu ứng slow-mo
  khi chết); signal `time_scaling_done`.
- **ScreenFade** (`screen_fade/`): hiệu ứng fade vòng tròn (shader) khi chuyển/chết.
- **MusicPlayer** (`music/`): nhạc nền nhiều lớp (layer), `set_volumes(...)` cho từng tầng.
- **DialogueController** (`dialogue/dialogue_controller/`): xem mục 7.

## 4. Nhân vật người chơi (`player/player.gd`, `class_name Player`)

- CharacterBody2D. Di chuyển chạy/nhảy với gravity nhiều giai đoạn (jump/fall/min gravity),
  coyote time, jump buffer. Có thể thả người qua sàn one-way (giữ Down + Jump).
- **Súng móc** là node con `Grapple` (xem mục 5). Khi đang móc thì physics chuyển sang chế độ
  kéo theo dây.
- Anim: idle/walk/jump/fall/land/crouch; có 2 AnimatedSprite2D (bản có grapple và không).
- **Chết:** `_on_hit()` (chạm hazard như Saw) và `hit_by_enemy()` (chạm/đánh bởi quái). Khi
  chết: phát âm thanh, **freeze input + nhấp nháy đỏ (hit-stop)** rồi gọi `owner.respawn()`.
  Cờ `_dead` chặn chết 2 lần. `_physics_process` return sớm khi `_dead` (đứng im lúc flash).
- Thuộc group `"player"` (để quái định vị). Hitbox: hình chữ nhật 7×15 px, lệch (-0.5, 1.5).
- Collision: player ở layer 2, mask 9 (solid + oneway) — KHÔNG va chạm layer quái (3).

## 5. Súng móc (`player/grapple/grapple.gd`, `class_name Grapple`)

- State machine: IDLE → EXTENDING → HOOKED → RETRACTING. Bắn ra theo hướng ngắm, raycast dò
  trúng gì: **Enemy** (gây sát thương + thu về), **GrappleArea** (bám/đu nếu hookable), hoặc
  tường (thu về). `grapple_length` ~5 đơn vị (×16px). Có cờ trợ giúp `long_grapple`.
- **Input cảm ứng:** chỉ phản ứng `InputEventScreenTouch` thật (KHÔNG phản ứng sự kiện chuột,
  để tránh chuột-giả-từ-touch bắn nhầm). Nhớ `_grapple_finger` (index ngón đã bắn) → chỉ ngón
  ĐÓ nhấc lên mới nhả dây (đu dây mà nhấc ngón khác không bị rớt). Trên PC dùng emulate touch
  from mouse để test.

## 6. Điều khiển cảm ứng (`ui/touch_controls/touch_controls.gd` + `.tscn`)

- CanvasLayer HUD. 5 nút: Trái `<`, Phải `>`, Xuống `v` (góc dưới trái, 26×26px), Nhảy
  `JUMP/NHẢY` (góc dưới phải), Pause `II` (góc trên phải). Tap vùng trống = bắn móc.
- **Đa chạm (multi-touch) theo từng ngón:** các Button chỉ là HÌNH (mouse_filter = ignore);
  toàn bộ input xử lý thủ công từ `InputEventScreenTouch`/`Drag`, mỗi ngón có `index` riêng,
  lưu trong `_finger_actions = {index: action}`. Nhờ vậy giữ NHIỀU nút cùng lúc (chạy + nhảy,
  về sau + móc). Ngón chạm nút → gửi `InputEventAction` (pressed); nhấc → released; trượt giữa
  các nút xử lý đúng. Khi pause → tự nhả hết nút (tránh kẹt phím).
- `force_show_on_desktop` để test HUD trên PC. `emulate_mouse_from_touch=true` (cần cho pause
  menu Control bấm được trên điện thoại).

## 7. Hội thoại & hướng dẫn (`dialogue/dialogue_controller/dialogue_controller.gd`)

- Autoload CanvasLayer. Hàng đợi thoại (`queue_up`), mỗi dòng hiện rồi tự mờ dần (tween).
- **Song ngữ EN/VI:** dict `VI_TRANSLATIONS` map text Anh → Việt. Khi locale = "vi", hiển thị
  bản VI bằng SystemFont Arial (font pixel gốc không có dấu). Đổi ngôn ngữ giữa chừng thì dòng
  đang hiện cũng dịch lại ngay (`locale_changed`).
- **Prompt hướng dẫn** (`dialogue/tutorial/*.tres`) kích hoạt bằng `LocationTrigger` (Area2D
  theo vị trí). Đã đổi từ ngôn ngữ PC sang touch: "Chạm nút < và > để di chuyển", "Chạm nút
  NHẢY", "Chạm vào màn hình để ngắm và bắn móc", "Chạm nút II để tạm dừng", "Giữ nút v và chạm
  NHẢY để leo xuống".
- **Hint cách giết quái (lần đầu):** một `HintLabel` riêng (góc trên, chữ vàng). Khi player lần
  đầu lại gần quái: hiện hint theo loại — Mushroom → "Nhảy lên đầu quái nấm để dẫm chết nó!",
  quái khác → "Bắn dây móc vào các quái khác để tiêu diệt chúng!". **Giết được 1 con loại đó →
  hint loại đó tắt vĩnh viễn** (đã học). Cơ chế đếm tham chiếu số quái đang gần theo loại
  (`notify_enemy_nearby/left/killed`), ưu tiên hiện hint Mushroom. Cả EN + VI.

## 8. Hệ thống kẻ thù (`objects/enemies/enemy.gd`, `class_name Enemy`)

Một script chung cho **4 loại quái** (sprite từ asset pack "Monsters_Creatures_Fantasy" của
LuizMelo, free), mỗi loại là 1 scene set `@export` riêng:

| Quái          | File                | Cách giết           | Đặc điểm            |
| ------------- | ------------------- | ------------------- | ------------------- |
| 🍄 Mushroom   | `mushroom.tscn`     | Nhảy lên đầu (stomp)| `stompable=true`    |
| 👁 Flying Eye | `flying_eye.tscn`   | Móc 1 phát          | Bay, ping-pong      |
| 👺 Goblin     | `goblin.tscn`       | Móc 2 phát          | Đi bộ tuần tra      |
| 💀 Skeleton   | `skeleton.tscn`     | Móc 3 phát          | Khó nhất            |

- **SpriteFrames build bằng code** từ sheet `@export` (idle/walk/attack/hit/death), frame 150px.
- **Patrol:** đi bộ (gravity + đổi hướng khi chạm tường hoặc hết mép sàn nhờ RayCast `LedgeCheck`)
  hoặc bay (ping-pong theo `patrol_range`). `_face()` lật sprite theo hướng.
- **Tấn công:** khi player vào **vùng đánh** (1 hộp AABB ôm sát thân quái + `attack_reach`),
  quái dừng + quay mặt + chơi anim `attack`; sát thương xảy ra đúng `attack_hit_frame` nếu player
  còn trong vùng → `player.hit_by_enemy()`. Một vùng duy nhất cho cả "khi nào vung" lẫn "khi nào
  trúng" (đã vung là trúng nếu player không né). Tôn trọng cờ `invinsible`.
- **Bị giết:**
  - Stomp (chỉ Mushroom): player rơi từ trên xuống → quái chết, player nảy lên (`stomp_bounce`).
  - Móc: `take_grapple_hit()` trừ máu (`grapple_hits`), **flash đỏ + anim Take Hit** mỗi đòn,
    chết khi hết máu.
- **Phát hiện stomp vs damage gộp vào 1 Area2D `StompZone`** phủ cả thân (mask layer 2 = player)
  để tránh race condition; handler tự quyết. Quái ở **collision layer 3 (grappleables)** để
  raycast móc bắt trúng; player mask không gồm layer 3 nên xuyên qua quái (không đứng lên được).
- **Hint:** `_player_in_radius(hint_range~80px)` edge-trigger gọi DialogueController; `_die()`
  báo killed; `_exit_tree()` trả counter khi bị free (chống kẹt hint).
- **@export chính:** sheet + count từng anim, `frame_size`(150), `sprite_scale`, `sprite_offset`,
  `visual_height`, `body_width`, `flying`, `move_speed`, `patrol_range`, `gravity`, `stomp_bounce`,
  `attack_reach`, `attack_hit_frame`, `stompable`, `grapple_hits`, `hint_range`, `stomp_sound`.

## 9. Màn chơi chính (`scenes/main.tscn`)

- Root là `GameController` (`common/game_controller.gd`). Tháp dùng TileMap; player spawn ở gờ
  intro `(-192,-1873)` rồi đi sang phải vào **tháp leo thật ở x≈0 (khoảng -76..76)**, leo lên
  (y giảm dần) tới End ở `(-120,-8245)`. Camera có script ghi đè limit (đừng tin limit trong tscn).
- Có sẵn: nhiều Checkpoint (máy tính "puter" save game), GrappleArea (điểm bám móc), Saw (cưa,
  hazard chết), hệ Powerable (Switch → RetractablePlatform/Hook/Wall, MovingPlatform/Saw),
  GrapplePack collectible, dialogue voice lines suốt đường leo.
- **10 quái** trong group node `Enemies`, độ khó tăng dần khi leo (Mushroom/Flying Eye ở dưới,
  3 Skeleton dồn gần đỉnh). Toạ độ Y sàn lấy bằng raycast trong tree. Lưu ý đặt quái cách
  checkpoint đủ xa (đã dời Goblin2 ra xa Checkpoint6 để không bị chém ngay khi hồi sinh).
- **Chết → hồi sinh:** `player.hit_by_enemy()` → `GameController.respawn()` (fade + slow-mo) →
  `reload_current_scene()` → `_ready()` đưa player về checkpoint (GameState lưu vị trí). Quái
  reload về điểm spawn ban đầu trong tscn.

## 10. Các đối tượng khác

- **Checkpoint** (`objects/checkpoint/`): Area2D, player chạm → `GameState.set_checkpoint()`.
- **GrappleArea** (`objects/grapple_area/`, `class_name GrappleArea`): điểm cho móc bám; shape
  capsule (đu dọc đường tâm) hoặc circle (bám tâm). `is_hookable` quyết định đu được hay chỉ chạm.
- **Powerable** (`objects/powerables/powerable.gd`, `class_name Powerable`): hệ tín hiệu năng
  lượng dây chuyền (Switch bật → lan truyền qua `_upstream`, có `_negate_upstream`, `_signal_delay`).
  Con: MovingPlatform, MovingSaw, RetractableHook/Platform/Wall, Switch.
- **Saw** (cưa): hazard, chạm = chết (đường chết riêng có thoại "Saw that coming").
- **GrapplePack** (collectible): vật phẩm súng móc, có shader `colorize.gdshader`.

## 11. Pause menu & i18n (`pause/pause.gd` + `.tscn`)

- Bấm nút Pause (hoặc phím P) → menu. GridContainer 2 cột cho **Volume** (Master/Music/SFX/
  Voice slider) và **Assist** (Móc dài / Chậm lại / Bất tử — checkbox map vào cờ GameState).
- Nút chuyển **ngôn ngữ EN ▸ VI** (góc trên trái), nút đóng X (góc trên phải). Đổi ngôn ngữ →
  `GameState.set_locale()` (lưu config + phát signal, mọi UI cập nhật). Tiếng Việt dùng SystemFont
  Arial. Tiêu đề "Grapple Pack" giữ nguyên (tên game).

## 12. Màn hình phụ

- `scenes/fullscreen_prompt/` — màn đầu khi mở app, hỏi bật toàn màn hình (song ngữ). Trên PC
  tự fit cửa sổ giữ tỉ lệ 9:16.
- `title/` — title card. `scenes/levels/enemy_demo.tscn` — màn test 4 quái (sàn phẳng + tường +
  bệ + player + camera + HUD), điều khiển: A/D di chuyển, W/Space nhảy, chuột trái móc, P pause,
  R reload.

## 13. Build Android (đã chạy được)

- Toolchain: **JDK 17** + **Android SDK command-line tools** (platform-tools, build-tools;34.0.0,
  platforms;android-34) + Godot Export Templates 4.6.2.
- Preset Android trong `export_presets.cfg`: package `com.huy.grapplepack`, tên "Grapple Pack",
  arm64-v8a, Export APK, `use_gradle_build=false` (dùng template dựng sẵn — không cần Install
  Android Build Template). Khoá Portrait. APK debug tự ký, cài thẳng lên máy test được.

## 14. Collision layers (`project.godot`)

1 = solid, 2 = player, 3 = grappleables, 4 = oneway, 5 = hazards, 6 = grapple.

## 15. Trạng thái hiện tại (đã hoàn thành)

✅ Touch controls đa chạm · ✅ Build APK Android chạy thiết bị thật · ✅ 4 loại quái + anim
đánh + feedback sát thương + cơ chế stomp/móc · ✅ Nhúng 10 quái vào màn chính · ✅ Hint cách
giết quái lần đầu (EN+VI) · ✅ Prompt hướng dẫn theo touch (EN+VI) · ✅ Pause menu song ngữ +
lưu locale. (Cửa chuyển màn / Level 2 / Haptic / Leaderboard: chưa làm, để dành mở rộng sau.)

---

**Khi tôi nhờ bạn sửa/thêm tính năng:** hãy tôn trọng kiến trúc trên (autoload, group "player",
collision layers, cơ chế signal Powerable, song ngữ qua VI_TRANSLATIONS, HUD theo viewport
180×320). Sau khi sửa code, validate bằng `Godot --headless --editor --quit` và chạy thử bằng
`Godot --path . res://scenes/main.tscn` (hoặc enemy_demo). Trả lời tiếng Việt.
