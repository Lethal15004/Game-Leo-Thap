# Leo Tháp (fork Grapple Pack) — Progress Tracker

## Trạng thái tổng quan

> Cập nhật lần cuối: 2026-06-13

| Hạng mục                 | Trạng thái                        |
| ------------------------ | --------------------------------- |
| Touch Controls           | ✅ Hoàn thành (multi-touch theo ngón) |
| Export Android (APK)     | ✅ Build thành công, chạy thiết bị thật |
| Hệ thống kẻ thù (4 loại) | ✅ Làm lại (Mushroom/Goblin/Skeleton/Flying Eye) |
| Anim đánh + feedback dmg  | ✅ Attack/Take Hit + vùng đánh AABB + flash đỏ player |
| Cơ chế Stomp             | ✅ Hoàn thành (sensor 1 Area2D)   |
| Màn demo enemy           | ✅ enemy_demo.tscn                |
| Nhúng quái vào main.tscn | ✅ 10 quái (x≈0, Y sàn raycast)   |
| Prompt hướng dẫn (touch)  | ✅ Full tiếng Việt                |
| Pause menu layout        | ✅ Hoàn thành (GridContainer)     |
| Bỏ i18n — full tiếng Việt | ✅ Xoá toggle EN/VI, text VI thẳng |
| Bỏ thoại cốt truyện      | ✅ Chỉ giữ 5 prompt + 2 hint quái |
| Đổi tên game "Leo Tháp"  | ✅ project/export/pause/title/end |
| Bỏ intro rơi từ trên cao | ✅ Spawn đứng đáy tháp, chơi ngay |
| Tái cấu trúc map         | ⏪ Đã hoàn nguyên map gốc theo yêu cầu user (backup bản lật: docs/main_tai_cau_truc.tscn.bak) |
| Thay nhân vật            | ✅ Geralt (GrafxKid Sprite Pack 3, CC0) |

---

## Nhật ký phát triển

### 2026-06-13 (session 4) — Hint checkpoint + đồng nhất style hint với prompt tutorial

User chốt giữ map gốc, yêu cầu thêm:
1. **Hint checkpoint**: tới gần máy tính lưu đầu tiên hiện "Những máy tính là điểm lưu
   của bạn." — lưu xong thì hint biến mất vĩnh viễn (giống cơ chế hint quái).
   - `checkpoint.gd`: thêm `hint_range` (70px), edge-trigger vào/ra vùng (chỉ khi máy
     CHƯA kích hoạt), `_exit_tree` trả counter chống kẹt khi reload;
     `_on_body_entered` (lưu) → `notify_checkpoint_saved()`.
   - `dialogue_controller.gd`: thêm `HINT_CHECKPOINT` + ref-count `_checkpoint_near` +
     cờ `_checkpoint_hint_done` (persist qua reload vì autoload). Ưu tiên hint:
     quái dẫm > quái móc > checkpoint.
2. **Đồng nhất style hint** (user thấy hint quái màu vàng nằm TRÊN khác hẳn prompt):
   `dialogue_controller.tscn` — HintLabel chuyển xuống ĐÁY (margin_bottom 88, ngay trên
   slot prompt margin_bottom 56 nên không đè nhau), màu kem trắng (0.96,0.91,0.75) =
   đúng màu prompt, font_size 12, bỏ outline vàng. Validate: import + chạy main sạch.

User chơi thử và muốn quay lại map cũ (trước tái cấu trúc lật gương + hoán đổi S6↔S8).
- Khôi phục từ file trung gian `/tmp/main_p3.tscn` (bản ĐÃ bỏ thoại + bỏ intro nhưng
  map còn nguyên gốc) — KHÔNG dùng git checkout hay backup cũ của user vì sẽ mất luôn
  phần bỏ thoại/Việt hoá.
- Áp lại các sửa đổi sau-p3: spawn player `(-192,-44)`, xoá GrapplePack2, 3 text VI
  màn end. Tức là: **map gốc 100% + tất cả thay đổi khác (thoại, tên, spawn, nhân vật
  Geralt) giữ nguyên**.
- Bản map tái cấu trúc lưu backup tại `docs/main_tai_cau_truc.tscn.bak` (đổi tên thành
  .tscn rồi thay vào scenes/ nếu muốn dùng lại).
- Verify: import sạch, probe 150 frame — player đứng đáy (-192,-41), 10/10 quái đứng
  đúng vị trí gốc (khớp các vị trí tinh chỉnh session 5-7 trước đây). map_dump.txt đã
  tạo lại theo map gốc.

### 2026-06-13 (session 2) — Thay nhân vật: Geralt (GrafxKid Sprite Pack 3, CC0)

User tải "Sprite Pack 3" của GrafxKid (license **CC0 1.0** — file LICENSE.txt trong pack),
ban đầu thích Tommy. Đo content thật từng nhân vật (scan alpha qua PowerShell):
Tommy 17×28px (cao gấp 1.75 nhân vật cũ ~16px → phải scale 0.6 làm méo pixel),
Twiggy 19×25, Gum Bot 16×18, **Geralt 13×16 = vừa khít hitbox 7×15, không cần scale**.
User chọn Geralt (pixel-perfect 1:1).

- Copy 6 sheet vào `aseprite/geralt/` (idle/run/jump/fall/land/hurt, frame 32×32,
  đổi tên bỏ dấu cách). `geralt_hurt.png` chưa dùng — để dành.
- `player/player.tscn` viết lại phần sprite: 1 SpriteFrames chung cho cả 2 node
  (AnimatedSprite2D + NoGrapple — Geralt không có bản đeo balo riêng; muốn phân biệt
  thì vẽ thêm balo vào sheet sau). Map anim: idle←Idle 2f (speed 2), walk←Running 3f
  (speed 8 × speed_scale 1.5), jump/fall←1f, land←Touch_Ground 1f (loop=false để
  `is_playing()` kết thúc đúng), crouch←dùng lại frame land (pose khuỵu gối).
  Bỏ các anim phụ của cáo cũ (idle_blink/ear_flop/tail — chỉ tscn tham chiếu).
- **Offset sprite (0,-7)**: chân Geralt chạm đáy frame (y=31); hitbox 7×15 tại
  (-0.5,1.5) có đáy y=+9 → 16(nửa frame) − 32(đáy) + offset = 9 ⟹ offset −7.
- Geralt mặc định quay mặt PHẢI (soi frame phóng 8×) → logic `flip_h = velocity.x < 0`
  giữ nguyên. Giữ nguyên: hitbox, dissolve shader, timers, mọi thông số vật lý.
- player.png / player_no_grapple.png cũ vẫn nằm trong repo (không còn được tham chiếu).
- Validate: import sạch, chạy main.tscn + enemy_demo.tscn headless không lỗi.
→ Cần build lại APK để thấy nhân vật mới.

### 2026-06-13 — Việt hoá toàn bộ + bỏ thoại + đổi tên "Leo Tháp" + bỏ intro + tái cấu trúc map

**4 nhiệm vụ lớn theo yêu cầu user (làm 4→3→2, nhiệm vụ 1 chờ chọn asset):**

**NV4 — Bỏ i18n, full tiếng Việt:**
- `game_state.gd`: xoá `user_locale`/`set_locale`/`locale_changed`/persist settings.cfg.
- `dialogue_controller.gd`: viết lại — xoá `VI_TRANSLATIONS` (dict tra theo text EN, điểm dễ
  vỡ nhất), text VI nằm thẳng trong resource; label + hint LUÔN dùng SystemFont Arial.
- `touch_controls.gd`: nút luôn "NHẢY"; `pause.gd`: label VI cố định, xoá nút BtnLang
  (cả node trong `pause.tscn`); `fullscreen_prompt.gd`: luôn VI.
- 5 file `dialogue/tutorial/*.tres`: text đổi thẳng sang tiếng Việt.

**NV3 — Bỏ thoại cốt truyện + đổi tên:**
- `scenes/main.tscn`: xoá 22 LocationTrigger voice-line (66 node) + 54 sub_resource Dialogue
  + ext_resource wav mồ côi (script awk lọc theo block, 2 pass quét tham chiếu). Node 308→241.
- `player.tscn/gd`: xoá `saw_dialogue`; `grapple_pack.tscn`: chỉ giữ 2 prompt tutorial;
  `retractable_wall.tscn/gd`: xoá thoại đùa. Giữ: 5 prompt + 2 hint giết quái (walk prompt
  chuyển sang queue qua `GameController._dialogues` ngay khi vào game).
- Đổi tên: `project.godot config/name`, `export_presets.cfg` (preset + package/name),
  tiêu đề pause, `title.tscn` (SystemFont vì KiwiSoda không có dấu), end screen
  ("Số lần chết" thay "Super Duper Puter Saves"). Giữ `package/unique_name` cũ.

**NV2a — Bỏ intro rơi:** probe xác nhận spawn cũ (-192,-1944) rơi ~6s xuống đáy y≈0.
`game_controller.gd`: xoá `_on_intro_player_just_grounded` + 11s khoá input + respawn
dialogues; nhạc bật ngay khi vào. Player spawn mới `(-192,-44)` đứng đất ngay đáy tháp
(probe settle: (-192,-41)), `_input_enabled=true`, grapple vẫn chờ nhặt GrapplePack.
Xoá GrapplePack2 (-192,-2144) — vật trang trí của intro cũ, không thể với tới.

**NV2b — Tái cấu trúc map (đảm bảo chơi được — mọi khoảng cách nhảy/móc bảo toàn):**
- Dump map ASCII (`tools/dump_map.gd` → `docs/map_dump.txt`): tháp = đáy tutorial
  (y 0..-2192) + 8 phân đoạn (mỗi đoạn có sàn oneway riêng) + đỉnh cố định (y<-7552).
- **Lật gương toàn tháp** (hàng tile ≤ -138, object y < -2192) quanh trục px x=16:
  tile c→1-c kèm cờ `TRANSFORM_FLIP_H` (physics lật theo; riêng tile scene-collection
  source 2 không có cờ lật, giữ nguyên), object x→32-x, Curve2D đường ray cưa/platform
  đảo dấu x (13 curve, dedupe vì nhiều platform dùng chung), shape con GrappleArea/
  MusicTrigger/EndArea đảo x + rotation.
- **Hoán đổi phân đoạn S6 (mê cung platform bay, 33 hàng) ↔ S8 (thang grapple, 35 hàng)**,
  S7 dồn 2 hàng — an toàn vì sàn 2 đoạn giống hệt nhau (oneway full-width) nên mọi mối
  nối giữ nguyên hình học gốc; đã soát từng seam trên dump.
- Pipeline: script GDScript tính toán → xuất patch text → awk áp vào tscn (không
  round-trip pack/save để khỏi mất instance overrides). Verify: import sạch, player
  đứng đất, **10/10 quái đứng vững bệ mới** (probe 150 frame), chạy scene 15s sạch lỗi.
- Script tạm đã xoá, giữ `tools/dump_map.gd` (tiện chỉnh map sau).

**Lưu ý:** cần build lại APK. README còn tên cũ (chưa đụng — chờ user quyết).
**Chờ user:** playtest map mới (nhất là 2 seam quanh y≈-4980 và -7050) + chọn asset
nhân vật mới (NV1 — đã gửi shortlist itch.io trong chat).

### 2026-06-15 (session 7) — Tách 2 Skeleton (hết dính chùm Goblin + hết rớt)

User (ảnh): khu giữa thấy 2 skeleton + 1 goblin dồn cục. Probe sau settle: Goblin3(19,-5136)
+ Skeleton2(28,-5136) đứng sát nhau, và Skeleton đặt (88,-6920) **bị rớt** xuống -6252 (mỏm
phải quá hẹp → walker đi ra mép là rơi).

Yêu cầu: giữ nguyên các Goblin + Skeleton cao nhất (Skeleton3 -8224), chỉ chỉnh 2 con
Skeleton còn lại, mỗi con 1 bệ RỘNG riêng (không rớt, tách xa nhau & xa Goblin).
- Skeleton2 → `(-24,-7568)` (bệ rộng 15 ô).
- Skeleton → `(64,-5504)` (bệ riêng, trên Goblin3 nhưng cách >120px).
- Skeleton3 giữ `(40,-8224)`.

Quét bệ bằng raycast (chỉ chọn bệ ≥5 ô, sạch gai, có khoảng trống) để walker không rớt.
Probe 90 frame: cả 3 đứng đúng spawn (không rớt), không cặp nào trong 120px. Validate sạch.



### 2026-06-15 (session 6) — Dời 1 Skeleton xuống góc phải điểm save cuối

User: đoạn cuối có 2 con (1 trên -8224, 1 dưới -8160). Chuyển con DƯỚI xuống **điểm save
cuối cùng** (Checkpoint11 ở (0,-7024)), đặt **góc phải sát tường**.

Raycast khu final checkpoint: sàn thật ở y=-6912, có 2 mỏm — trái (x -96..-80) và **phải
(x 80..96) sát tường phải (x≈72-80)**; giữa là khoảng trống (player tới bằng dây móc). Đặt
Skeleton `(88,-6920)` = mỏm phải sát tường. Verify: sàn cứng, không gai → an toàn.
Skeleton3 vẫn ở `(40,-8224)` gần End. Validate import sạch.



### 2026-06-15 (session 5) — Phân bố lại 3 Skeleton (hết stuck chồng nhau)

**Vấn đề (user gửi ảnh):** session trước dồn 3 Skeleton cùng dải -8160 quá sát nhau → đứng
chồng lên nhau → kẹt (stuck). User muốn rải ra 3 chỗ: 1 gần điểm save, 1 sau cụm lưỡi cưa,
1 gần kết thúc.

**Cách làm:** raycast quét bệ an toàn (sàn cứng, sạch gai, trống phía trên) + đối chiếu vị
trí Checkpoint & Saw. Phân bố:
- Skeleton2 `(40,-5136)` — gần Checkpoint9 (-56,-4992) / Checkpoint10 (56,-5520) = "gần save".
- Skeleton `(-8,-8160)` — sau cụm cưa dày (Saw10-16 ~-5700, Saw17/18 -7640/-7752).
- Skeleton3 `(40,-8224)` — gần End (-8245), không dính cưa/gai.

3 vị trí cách xa nhau (Y -5136 / -8160 / -8224) → không thể chồng/kẹt. Verify raycast: cả 3
đứng sàn cứng, không gai trên/dưới. Validate import sạch.



### 2026-06-15 (session 4) — Dời 3 Skeleton khỏi vùng gai (sàn răng cưa = hazard)

**Vấn đề (user phát hiện qua ảnh chụp khi chơi):** viền răng cưa trắng của sàn ở khu đỉnh
tháp THỰC SỰ là gai sát thương (hazard), không phải trang trí như mình tưởng lúc đầu. 3 con
Skeleton (cũ: -7298/-7394/-7858) đứng ngay cạnh/dưới các dải gai → player tới gần để bắn móc
là đụng gai chết → không thể giết quái như thiết kế.

**Cách tìm chỗ an toàn (script headless tạm, đã xoá):** đọc `TileSet` để xác định physics
layer hazard (collision_layer=16, là physics_layer index 2; solid=layer 1, index 0). Dùng
**raycast** quét từng cột ở khu đỉnh, phân biệt mặt sàn SPIKE vs SOLID + kiểm tra khoảng trống
phía trên (không gai trong ~40px nơi player đứng). → Dải **y=-8160** sạch gai, rộng.

**Fix:** dời 3 Skeleton về dải -8160: Skeleton2 `(8,-8160)`, Skeleton `(40,-8160)`,
Skeleton3 `(-24,-8160)`. Verify raycast: cả 3 đứng trên sàn SOLID, không gai dưới chân,
không gai trên đầu → player tiếp cận & bắn móc an toàn. (Tránh dải -8224 vì sát End -8245.)
Validate import: sạch.



### 2026-06-15 (session 3) — Hint "cách giết quái" lần đầu (EN + VI)

Yêu cầu: lần ĐẦU gặp Mushroom → hiện "Nhảy lên đầu quái nấm"; lần đầu gặp quái khác → hiện
"Bắn dây móc". Giết được quái loại đó thì hint mất, không hiện lại.

**Thiết kế (dùng DialogueController autoload — hiện trên mọi scene, có sẵn cơ chế dịch VI):**
- Thêm `HintLabel` riêng vào `dialogue_controller.tscn` (góc trên, vàng, không đè dialogue
  ở đáy). 2 text hint EN + VI trong VI_TRANSLATIONS (`HINT_STOMP`, `HINT_GRAPPLE`).
- API: `notify_enemy_nearby(stompable)` / `notify_enemy_left(stompable)` / `notify_enemy_killed
  (stompable)`. **Reference-count** số quái đang gần theo loại (`_stomp_near`/`_grapple_near`)
  → hiện hint khi ≥1 con loại đó ở gần & CHƯA học; cờ `_stomp_hint_done`/`_grapple_hint_done`
  = đã giết 1 con loại đó → hint loại đó tắt VĨNH VIỄN. Ưu tiên Mushroom (bài học sớm).
  Re-render theo locale khi đổi ngôn ngữ giữa chừng.
- `enemy.gd`: cờ `stompable` quyết định loại hint. `_physics_process` edge-trigger vào/ra
  `hint_range` (mặc định 80px) → gọi nearby/left. `_die()` gọi killed. `_exit_tree()` trả
  counter khi quái bị free (giết / reload scene) → không kẹt/leak hint.

**Edge case đã rà:** 2 quái cùng loại gần nhau (ref-count), đi xa rồi quay lại (hiện lại nếu
chưa học), chết-reload scene (state "đã học" giữ qua autoload — hợp lý), đổi ngôn ngữ khi
hint đang hiện. Validate parse + chạy enemy_demo & main.tscn headless: sạch.
**Lưu ý fix kèm:** trước đó `_player_within` đã bị xoá khi làm vùng đánh AABB → thêm helper
mới `_player_in_radius(radius)` cho hint (khoảng cách tâm, rộng hơn vùng đánh).

### 2026-06-15 (session 2) — Fix quái spawn sát checkpoint + dọn file md

**Fix Goblin2 chém chết liên tục ở điểm save:** respawn = `reload_current_scene` nên quái
ĐÃ về điểm spawn ban đầu, nhưng điểm spawn của Goblin2 `(-8,-3202)` vốn nằm sát Checkpoint6
`(-40,-3216)` (~32px) → vừa hồi sinh đã bị chém. **KHÔNG dùng grace period** (user không
thích). Cách fix: dời điểm spawn Goblin2 sang `(24,-3202)` — cách Checkpoint6 **64px**, vẫn
trên cùng bệ sàn (x[-76..28]), đủ khoảng để người chơi phản ứng khi hồi sinh. Đã rà các quái
khác: chỉ Goblin2 dính sát checkpoint.

**Dọn file md (chỉ giữ phần đã xong ✅):** bỏ các hạng mục ⬜ chưa làm khỏi PROGRESS bảng
tổng quan (Cửa chuyển màn, Level 2, Tính năng phụ), viết lại IDEA.md gọn chỉ còn mục 1 (Mobile)
+ mục 2 (Enemy) đã hoàn thành, rút gọn câu tổng kết HISTORY_PROMPT.md.



### 2026-05-31 (session 4) — Multi-touch HUD (nhấn nhiều nút cùng lúc)

**Vấn đề:** không nhấn được 2 nút cùng lúc (vd > + JUMP). Do hướng "Button + emulate_mouse_
from_touch": mỗi touch thành 1 con chuột giả, mà chuột chỉ có 1 con trỏ → 1 thời điểm chỉ
1 nút nhận. Không bao giờ multi-touch được (về sau dây móc + di chuyển + nhảy càng kẹt).

**Fix triệt để — tự xử lý touch thật theo từng ngón** (`touch_controls.gd` viết lại):
- Button giờ CHỈ là hình (set `mouse_filter = IGNORE`), không xử lý input.
- `_input()` bắt `InputEventScreenTouch`/`Drag`, mỗi ngón có `index` riêng → theo dõi độc
  lập trong `_finger_actions = {index: action}`. Ngón chạm trúng nút nào → gửi
  `InputEventAction` nút đó (pressed); nhấc ngón → released. Nhiều ngón = nhiều nút cùng lúc.
- `_button_at(pos)` tìm nút theo `get_global_rect().has_point`. Drag giữa các nút: nhả nút cũ,
  nhấn nút mới. Nút Pause là one-shot (không track ngón). Touch trúng nút → `set_input_as_handled`
  (không rớt xuống grapple); touch trượt khỏi nút → để grapple xử lý.
- Visual: `_process` đồng bộ stylebox normal/pressed theo `Input.is_action_pressed`.

**Fix kèm 2 bug do emulate_mouse_from_touch (PHẢI giữ true cho pause menu Control bấm được):**
- `grapple.gd`: CHỈ bắn móc bằng `InputEventScreenTouch` thật, KHÔNG react mouse-button event
  (chuột giả từ touch sẽ bắn móc nhầm khi chạm nút). Touch trúng nút đã bị touch_controls nuốt
  nên không tới grapple.
- Nhớ `_grapple_finger` (index ngón đã bắn): chỉ ngón ĐÓ nhấc lên mới nhả dây → đu dây mà
  nhấc ngón nhảy/di chuyển không bị rớt móc.

→ Cần build lại APK (project + script). Validate parse + chạy demo: sạch.

**Audit logic (session 4b) — tìm & fix bug nút kẹt + tăng size nút trái:**
- **BUG nút di chuyển KẸT sau pause:** đang giữ `>` → mở pause → nhả tay trong menu → resume.
  Vì `_input()` `return` khi paused nên sự kiện nhả ngón bị bỏ qua → action kẹt `pressed`
  mãi (nhân vật tự chạy). Fix: `_process` khi `paused` gọi `_release_all()` (gửi released
  cho mọi ngón đang giữ + clear `_finger_actions`).
- Đã rà các case khác, OK: pause one-shot không track ngón; drag chuyển nút nhả-nút-cũ/nhấn-
  nút-mới đúng; grapple nhớ `_grapple_finger` nên nhả ngón khác không rớt dây.
- **Tăng 3 nút trái** 22×22 → **26×26** (theo yêu cầu): Left 8..34, Right 38..64 (gap 4),
  Down 23..49 căn giữa (tâm x=36 thẳng cặp L/R), lề đáy 4px, gap hàng 4px.

### 2026-05-31 (session 3) — Sửa hết prompt hướng dẫn từ PC → touch (EN + VI)

Game chơi mobile nhưng 5 prompt tutorial vẫn hướng dẫn kiểu PC. Sửa **cả bản EN** (5 file
`dialogue/tutorial/*.tres`) **lẫn key+value VI** (`dialogue_controller.gd VI_TRANSLATIONS`).
Dùng đúng ký hiệu nút trên HUD (`<` `>` `v` `JUMP`/`NHẢY` `II`):
- walk: "Use A and D..." → "Tap the < and > buttons to move." / "Chạm nút < và > để di chuyển."
- jump: "Use the Spacebar..." → "Tap the JUMP button to jump." / "Chạm nút NHẢY để nhảy lên."
- grapple: "Aim with the cursor + left mouse..." → "Tap anywhere to aim and fire your grapple."
  / "Chạm vào màn hình để ngắm và bắn móc."
- pause: "Press P..." → "Tap the II button to pause..." / "Chạm nút II để tạm dừng..."
- drop: "...S + Spacebar." → "Hold v and tap JUMP\nto climb down platforms." / "Giữ nút v
  và chạm NHẢY\nđể leo xuống các sàn."

**Quan trọng:** key trong VI_TRANSLATIONS phải khớp CHÍNH XÁC text EN mới (so khớp theo
`dialogue.text`) — đã đối chiếu từng cặp (kể cả `\n` ở drop). Grep xác nhận không còn prompt
PC nào sót. Parse sạch. → Cần build lại APK (text nằm trong .tres + script).

### 2026-05-31 (session 2) — FIX nút touch không ăn trên thiết bị thật

**Triệu chứng:** cài APK lên điện thoại, nút HUD (Left/Right/Jump/Down) hiện nhưng nhấn
không phản hồi. Trên PC test bằng chuột thì OK nên không lộ.

**Nguyên nhân:** `project.godot [input_devices] pointing/emulate_mouse_from_touch=false`.
Các nút HUD là `Button` (Control) — chỉ phản hồi sự kiện CHUỘT, không tự nhận touch. Cần
cờ này = true để Godot phiên dịch cú chạm → click chuột cho Button hiểu. (Mặc định Godot
là true nhưng dự án để false.) Bắn móc vào vùng trống vẫn chạy vì dùng `InputEventScreenTouch`
trực tiếp trong grapple.gd, không qua Button → vì vậy lỗi chỉ ảnh hưởng các NÚT.

**Fix:** đổi `emulate_mouse_from_touch=false` → `true`. Đã cân nhắc: chạm nút KHÔNG bị bắn
móc nhầm vì Button nhận & nuốt sự kiện trước khi tới `_unhandled_input` của grapple.
→ **Cần build lại APK** để áp dụng (setting nằm trong project.godot).

### 2026-05-31 — Setup build Android (toolchain + preset + khóa orientation)

**Toolchain máy dev (Windows):** cài JDK 17 (`C:\Program Files\Java\jdk-17`), tải Export
Templates 4.6.2 (1.16GB), cài Android SDK command-line tools vào **ổ D** (`D:\android-sdk`,
584MB — ổ C đầy 99%): `platform-tools` + `build-tools;34.0.0` + `platforms;android-34`,
accept licenses. Trong Godot trỏ Editor Settings → Android: SDK Path=`D:\android-sdk`,
Java SDK Path=`C:\Program Files\Java\jdk-17`.

**project.godot:** thêm `window/handheld/orientation=1` (khóa Portrait — game dọc 180×320,
không khóa sẽ bị xoay ngang trên thiết bị).

**export_presets.cfg:** preset Android "Grapple Pack" (arm64-v8a, Export APK, Use Gradle
Build=Off → dùng template dựng sẵn, không cần Install Android Build Template). Set
`package/unique_name="com.huy.grapplepack"`, `package/name="Grapple Pack"`,
`version/name="1.0.0"`. → bấm Export Project ra APK debug (tự ký).


### 2026-05-30 (session 4) — Nhúng quái + anim đánh/damage + 3 fix bug playtest + i18n

**Hoạt ảnh tấn công (Attack.png) + phản ứng trúng đòn (Take Hit.png):** asset pack có sẵn
`Attack.png` (8 frame) và `Take Hit.png` (4 frame) cho cả 4 con — trước chưa dùng.
- `enemy.gd`: thêm @export `attack_sheet/attack_count`, `hit_sheet/hit_count`, `attack_range`
  (mặc định 36px). Build thêm anim `attack` (loop) + `hit` (one-shot).
- Khi player vào tầm `attack_range` (dx & dy ≤ range): quái **dừng** (walker `velocity.x=0`,
  flyer `velocity=0`), **quay mặt về player**, chơi anim `attack`. Ra khỏi tầm → walk lại.
  Tìm player qua group `"player"` (thêm `add_to_group("player")` vào `player.gd._ready`).
- Helper `_set_anim()` chỉ `play()` khi khác anim hiện tại (không restart mỗi frame). Anim
  một-lần `hit` ưu tiên hơn loop (cờ `_reacting`).
- **Fix: đòn đánh không gây sát thương** (player chỉ chết khi chạm hẳn vào quái). Trước đây
  `attack_range` chỉ kích anim chứ không trừ máu. Thêm `@export attack_hit_frame` (mặc định 4)
  + connect `_sprite.frame_changed`: khi anim `attack` chạm đúng frame vung VÀ player còn trong
  tầm → `player.hit_by_enemy()`. Vẫn chừa stomp cho quái `stompable` (helper `_is_player_stomping`
  dùng chung với `StompZone`) và tôn trọng `GameState.invinsible`.

**Fix flash đỏ "lúc có lúc không":** `_flash_hit()` trước chỉ chạy ở nhánh chưa-chết → đòn
kết liễu (và stomp) không flash; Bat 1-móc chết ngay nên không bao giờ flash. Sửa:
`take_grapple_hit()` **luôn** gọi `_flash_hit()` (trước khi check chết) + chơi anim `hit`
nếu còn sống; `_die_from_stomp()` cũng flash. `_flash_hit()` nay `kill()` tween cũ trước khi
tạo mới (rapid hit luôn re-show đỏ).

**Fix 3 bug playtest (session 4b):**
1. **Thoại đang hiện không đổi ngôn ngữ khi toggle giữa chừng** (dòng đang hiện giữ nguyên
   ngôn ngữ cũ, các dòng sau mới đổi). `_display_dialogue` chỉ set text 1 lần lúc hiện.
   Fix `dialogue_controller.gd`: lưu `_current` (dòng đang hiện), tách `_apply_text()` set
   text+font theo locale, connect `GameState.locale_changed` → nếu đang hiện thì render lại
   ngay. `_current=null` khi tween ẩn xong.
2. **Player chết khi đòn quái còn xa / chưa vung hết.** Trước dùng chung `attack_range`=36px
   cho cả kích anim lẫn tính damage (36px = rất xa trong viewport 180px). Tách: thêm
   `@export attack_hit_range`=20px (nhỏ hơn) — chỉ trúng khi player CÒN trong tầm này lúc
   chạm `attack_hit_frame`. Đổi `_player_in_attack_range()` → `_player_within(range)` nhận
   tham số: physics dùng `attack_range`, đòn trúng dùng `attack_hit_range`.
3. **Player flash đỏ rồi mới chết (dễ nhận biết hơn).** `player.gd hit_by_enemy()`: freeze
   input + giữ nguyên sprite hiện tại (KHÔNG `set_input_enabled` để tránh swap sprite
   grapple↔no-grapple gây giật), tween modulate đỏ (0.06s) → trắng (0.12s) rồi mới
   `owner.respawn()`.

**Thiết kế lại tầm đánh — 1 vùng duy nhất (session 4d, theo ảnh playtest user):**
- **Bug gốc:** trước tách `attack_range`=36 (kích anim) ≠ `attack_hit_range`=20 (trúng đòn).
  Hậu quả: (1) quái đánh khi player còn xa (36px đo hình vuông từ tâm = rất rộng); (2) anim
  vung trông như trúng nhưng player ở 20–36px → KHÔNG dính → phải đợi vòng sau player nhích
  gần mới chết ("đánh trúng nhưng lần 2 mới chết").
- **Fix chỉn chu:** bỏ 2 export trên, thay bằng **1 export `attack_reach`** (mặc định 10px =
  tầm với của đòn TÍNH TỪ MÉP thân). Vùng đánh = hộp ôm sát thân quái (`body_width` ×
  `visual_height`) nới thêm `attack_reach` mỗi phía. Phát hiện bằng **AABB-vs-AABB overlap**
  với hộp va chạm THẬT của player (7×15 tại offset (-0.5,1.5), lấy từ player.tscn) qua tổng
  Minkowski — chính xác hơn so-sánh-khoảng-cách-từ-tâm. Cùng 1 vùng cho cả "khi nào vung" lẫn
  "khi nào trúng" → **đã vung là trúng** (trừ khi player né khỏi vùng), và chỉ vung khi player
  thật sự sát bên. `_player_within(radius)` → `_player_in_attack_zone()`.
- Mobile: các trị đo theo px viewport 180×320 (đồng nhất toàn dự án), không phụ thuộc input
  bàn phím/chuột nên hành vi quái giống hệt trên touch. Hiệu năng: chỉ 1 AABB check khi frame
  sprite đổi (signal `frame_changed`), không tốn.

**Review lại luồng chết (session 4c, theo yêu cầu user kiểm tra logic):**
- **Bug thật phát hiện được:** `hit_by_enemy()` set `velocity=ZERO` + comment "freeze" NHƯNG
  `player._physics_process` không check `_dead` → gravity + `move_and_slide` vẫn chạy trong
  0.18s flash → player vẫn rơi/trượt lúc "đang chết" (bị đánh trên không thấy rơi tự do rồi
  mới respawn). Fix: `_physics_process` return sớm khi `freeze_position or _dead` (hit-stop).
- Đổi tên tham số `_player_within(range)` → `(radius)` (tránh shadow built-in `range()` của
  GDScript → hết warning).
- Xác nhận ĐÚNG (không sửa): chạm thân quái vẫn chết (`StompZone` phủ thân → `_on_player_touched`
  → `hit_by_enemy`); đòn đánh chỉ trúng đúng `attack_hit_frame` + trong `attack_hit_range`;
  stomp luôn ưu tiên hơn đòn đánh (cả 2 handler check `_is_player_stomping`); double-respawn
  bị chặn bởi cờ `_dead` (cả player lẫn enemy); attack loop bắn damage mỗi vòng nhưng sau
  hit đầu player đã respawn về checkpoint (ngoài tầm) nên không chết liên hoàn.

**Fix prompt hướng dẫn "Climb down" không dịch:** `drop_prompt.tres` có text **2 dòng**
(`"Climb down some platforms\nwith S + Spacebar."`) nhưng key trong `VI_TRANSLATIONS`
(`dialogue_controller.gd`) chỉ là dòng đầu → `dialogue.text` không khớp → hiện tiếng Anh.
Sửa key thành đủ 2 dòng, value VI = "Leo xuống vài sàn\nbằng phím S + Spacebar.". Đã đối
chiếu 4 prompt còn lại (walk/jump/grapple/pause) — đều 1 dòng, khớp key sẵn.


**Tìm toạ độ sàn (2 script headless tạm, đã xoá):**
- `find_floors.gd`: `instantiate()` main.tscn (không vào tree) + `tilemap.get_used_cells`
  để liệt kê đoạn sàn phẳng. **Cảnh báo:** TileMap dùng `format=2` (legacy) + tile **16×16**
  (không phải 8), camera có script ghi đè limit → toạ độ scan offline chỉ gần đúng.
- `probe_floors.gd`: load main.tscn **VÀO tree** (full `_ready`, physics chạy), settle 30
  frame, rồi **raycast xuống** (mask=1 solid) lấy Y sàn thật + đọc vị trí nghỉ của player.
  → Phát hiện: **tháp leo thật nằm ở x≈0 (khoảng -76..76)**, khớp các Checkpoint
  (-32, 24, -40). Player spawn/nghỉ ở **(-192, -1873)** là gờ intro riêng, rồi đi sang phải
  vào tháp. (Camera limit -282..-102 trong tscn bị script camera ghi đè, đừng tin.)

**Đặt 4 quái** (group `Enemies` Node2D trong `scenes/main.tscn`, Y sàn xác nhận bằng raycast,
độ khó tăng dần khi leo lên — spawn y≈-1873 → End y=-8245):
- 🍄 **Mushroom** (stomp) `(-16, -2210)` — bệ rộng y≈-2208 (x -72..40), platform đầu tiên.
- 👁 **Flying Eye** (móc 1 phát, bay) `(-8, -2750)`, `patrol_range=40` — lượn trong khoảng
  trống giữa bệ -2208 và cụm -2976.
- 👺 **Goblin** (móc 2 phát) `(-24, -4082)` — bệ rộng y≈-4080.
- 💀 **Skeleton** (móc 3 phát) `(-8, -7394)` — bệ cao y≈-7392, gần cuối màn.

**Tăng mật độ lên 10 con** (user chọn ~8–10): thêm 6 con nữa rải đều lên tháp (~1 con/2 màn
hình), lặp loại với độ khó tăng dần. Thứ tự từ dưới lên: Mushroom(-16,-2210) ·
FlyingEye(-8,-2750) · Mushroom2(-24,-2978) · Goblin2(-8,-3202) · Goblin(-24,-4082) ·
FlyingEye2(8,-4550) · Goblin3(-8,-5138) · Skeleton2(40,-7298) · Skeleton(-8,-7394) ·
Skeleton3(-40,-7858). 3 Skeleton dồn về gần đỉnh làm climax. Y sàn đều từ raycast.

**tscn:** thêm 4 `ext_resource` (path-only, theo style `touch_controls`), group node `Enemies`.
Header `main.tscn` KHÔNG có `load_steps` → không sửa. Quái dùng `respawn()` của root
(GameController) sẵn có nên không cần sửa script.

**Validate:** import headless (`--editor --quit`) sạch + chạy `main.tscn` headless OK (các
dòng "Unreferenced static string"/"Pages in use" chỉ là noise teardown khi `timeout` kill
tiến trình, không phải lỗi scene).
**Chờ user playtest:** vị trí/độ khó từng con trên màn thật — chỉ cần sửa `position` node
trong group `Enemies`, hoặc @export trong 4 file `objects/enemies/*.tscn`.

### 2026-05-30 (session 3) — Cơ chế quái theo loại (stomp vs grapple) + fix layout pause + fix font

**Đổi cơ chế tiêu diệt quái theo loại (theo ý tưởng user):**
- `enemy.gd`: thêm `@export stompable: bool` + `@export grapple_hits: int` (máu theo số
  lần trúng móc), biến `_hp`. Stomp giờ CHỈ giết quái khi `stompable=true`. Quái khác chạm
  vào (kể cả từ trên) → player chết (trừ khi Bất tử).
- Thêm `take_grapple_hit()` (móc gọi): trừ 1 máu, `_flash_hit()` (modulate đỏ rồi về
  trắng) khi chưa chết, `_die()` khi hết máu. Gộp `_die()` chung cho stomp + grapple.
- Quái đặt lên **collision_layer 3 (grappleables)** để hook raycast (mask=5, layers 1+3,
  collide_with_areas) bắt trúng. Player mask=9 không gồm layer 3 → vẫn xuyên qua, không
  đứng lên được.
- `player/grapple/grapple.gd` `_extend_process`: thêm nhánh `if collider is Enemy` →
  `take_grapple_hit()` + RETRACTING (không hook). Đặt TRƯỚC nhánh GrappleArea/tường.
- Cấu hình: **Mushroom** stomp (grapple_hits=0), **Bat** móc 1 lần, **Goblin** 2 lần,
  **Skeleton** 3 lần.
- Mushroom thu nhỏ (scale 0.8→0.62, visual_height 30→22, body_width 16→12) cho dễ nhảy
  lên đầu.

**Fix layout pause menu (user thấy cấu trúc xấu):**
- `pause/pause.tscn`: tiêu đề "Grapple Pack" font 32→24, outline 20→12 (đỡ tràn 2 mép).
- Thêm `TopSpacer` + `BottomSpacer` (Control, `size_flags_vertical=3` expand) bọc 2 đầu
  khối cài đặt → phần Âm lượng/Hỗ trợ dồn xuống GIỮA vùng dưới tiêu đề, không còn dính
  sát/đè 2 nút VI▸EN và X ở góc trên, hết khoảng trống lớn ở đáy. Thêm `SectionSpacer`
  (h=10) giữa Volume và Assist.

**Fix lỗi font khi đổi ngôn ngữ (`ui/touch_controls/touch_controls.gd`):**
- Lỗi `Parameter "fd" is null` khi toggle VI→EN: do SystemFont tạo LOCAL bị giải phóng
  giữa lúc reshape text. Fix: giữ `_vi_font` + `_en_font` (lấy từ theme) làm member, và
  `_apply_jump_label()` LUÔN gán font hợp lệ (không bao giờ `remove_theme_font_override`).
  EN dùng lại PearSoda của theme (giữ style pixel).

**Validate:** import + chạy headless 7s — không lỗi.
**Chờ user xem thực tế:** layout menu mới, độ khó stomp mushroom, tầm/độ nhạy móc giết quái.

### 2026-05-30 (session 2) — Hệ thống kẻ thù 4 loại + stomp + màn demo

**Asset:** copy pack "Monsters_Creatures_Fantasy" (LuizMelo, free) từ
`D:\SafeHorizonInternShip\Monsters_Creatures_Fantasy` vào `aseprite/enemies/<tên>/`
(mushroom, goblin, skeleton, flying_eye). Mỗi frame 150×150, hàng ngang. Đã phân tích
vùng pixel thật (Idle/Flight frame 0) để căn chân chạm đất + scale: content chỉ ~31–51px
trong frame 150px → scale ~0.78–0.85 cho cao ~26–40px.

**Script chung `objects/enemies/enemy.gd`** (`class_name Enemy`, CharacterBody2D):
- Build SpriteFrames bằng code từ @export sheet + frame count (khỏi tạo ~60 AtlasTexture
  trong tscn). Anim: idle/walk/death.
- Patrol đi bộ: gravity + move_and_slide, đổi hướng khi `is_on_wall()` hoặc RayCast
  `LedgeCheck` không thấy đất (mép platform). `flying=true` → bay ngang, ping-pong theo
  `patrol_range`.
- **Damage + stomp gộp vào 1 Area2D sensor** (`StompZone`, mask layer 2 = player) phủ cả
  thân → tránh race condition. Handler: player đang rơi (`velocity.y>0`) + ở rõ phía trên
  tâm → STOMP (enemy chơi anim death, `queue_free`, player nảy `-stomp_bounce`); ngược lại
  → `player.hit_by_enemy()` trừ khi `GameState.invinsible` (tôn trọng nút trợ giúp Bất tử).
- Body CharacterBody2D: `collision_layer=0`, mask=1 (solid) để đi trên sàn; KHÔNG dùng
  layer hazards nữa (khác cơ chế Saw — chuyển sang sensor cho tất định).

**`player/player.gd`:** thêm `hit_by_enemy()` (public) — mirror đường chết của Saw
(play `_hit_sound` + `owner.respawn()`), có cờ `_dead` chống respawn 2 lần.

**4 scene quái** `objects/enemies/{mushroom,goblin,skeleton,flying_eye}.tscn` — instance
`enemy.gd` + set @export riêng (sheet, scale, offset, visual_height, body_width, speed,
flying). Skeleton dùng `Walk.png` (4 frame), số còn lại `Run.png`/`Flight.png` (8 frame).

**Màn demo `scenes/levels/enemy_demo.tscn` + `.gd`:** arena sàn phẳng + 2 tường + 1 bệ,
Player + Camera2D + 4 quái + TouchControls(force_show) + Pause. `enemy_demo.gd` làm owner
của player → có `respawn()` (fade + reload). Phím R reload nhanh. Chạy thử bằng F6 trong
Godot hoặc `Godot --path . res://scenes/levels/enemy_demo.tscn`.

**Validate:** import headless + chạy scene headless 7s — không lỗi script/null.
**Còn cần tinh chỉnh sau khi xem thực tế:** hướng quay mặt sprite (flip_h), scale/độ cao
va chạm từng con, tốc độ. Chưa nhúng quái vào `main.tscn` (level tilemap, cần toạ độ sàn).

### 2026-05-30 — Gỡ credits pause menu + đồng bộ căn chỉnh Volume/Assist + i18n hoàn thiện

**Pause menu — gỡ block "Created By":**
- `pause/pause.tscn`: xoá toàn bộ block credits trong `Control/VBoxContainer`:
  `Label` (Created By), `HBoxContainer` (Diego Escalante | GaboDBabo), `HBoxContainer2`
  (Design/Code/Graphics | Music/Sounds/Voice Acting). Xoá người thì vai trò mồ côi nên
  gỡ cả cụm. VBox còn: RichTextLabel (Grapple Pack) → Label3 (Volume) → VolumeGrid →
  Label4 (Assist) → AssistGrid.
- `pause/pause.gd`: xoá 3 key tương ứng khỏi `UI_LABELS`, xoá const `MULTILINE_LABEL_PATHS`
  + vòng lặp line_spacing (không còn label nhiều dòng), bỏ `"Label"` khỏi `TITLE_LABEL_PATHS`.

**Đồng bộ căn chỉnh 2 section (cho thẳng cột, không lệch):**
- VolumeGrid: nhãn `custom_minimum_size` 55→**85** (bằng AssistGrid). Cột nhãn 85 + h_sep 6 +
  control 85 = tổng **176px**, cả 2 grid `size_flags_horizontal=4` → canh giữa giống nhau.
- AssistGrid: `v_separation` 2→**4** (nhịp dọc bằng Volume); 3 checkbox thêm
  `custom_minimum_size = (85,0)` → cột control rộng 85 như slider, checkbox canh trái cùng
  toạ độ x với slider → slider và checkbox thẳng một hàng dọc.

**i18n — toggle EN/VI hoạt động đầy đủ:**
- Audit `text = "` toàn bộ tscn. Phát hiện 4 dòng thoại thiếu bản VI → bổ sung vào
  `dialogue_controller.gd` `VI_TRANSLATIONS`: "Did you get it?"/"I got it." (grapple_pack),
  "I thought you were going to get stuck there."/"Must have caught it in playtesting."
  (retractable_wall).
- Nút **JUMP/NHẢY** touch HUD trước đây set 1 lần trong `_ready()` → toggle lúc chơi không
  đổi. Fix: thêm signal `locale_changed(new_locale)` vào `game_state.gd` (emit trong
  `set_locale`); `touch_controls.gd` tách `_apply_jump_label()` (VI="NHẢY" Arial 8, EN="JUMP"
  size 9 default) gọi trong `_ready()` + connect `GameState.locale_changed`.
- Xác nhận: dialogue dịch theo locale tại thời điểm hiển thị mỗi dòng (`get_locale()` runtime);
  end screen + fullscreen_prompt set theo locale lúc load scene; title card chỉ hiện
  "Grapple Pack" (tên game giữ nguyên), label "Created By" trong title đã `visible=false`.
- Validate: import project headless (nạp autoload) — không lỗi parse.

### 2026-05-20 (session 8) — Audit & dịch hết text còn sót sang VI (trừ sound)

**Audit:** grep `text = "` toàn bộ tscn + script để liệt kê text user-visible. Phát hiện
còn sót ở 4 chỗ:

1. **Dialogue cuối game (12 dòng) trong main.tscn**: My regular puter says, Yeah
   three-quarters, You don't talk much, I'm busy, Ok that's a bit excessive, This is it,
   You're right below the surface, One last set of maneuvers, You got it, You made it
   out with the grapple pack, You're home free, We'll see you back at our base.
   → bổ sung vào `dialogue/dialogue_controller/dialogue_controller.gd` `VI_TRANSLATIONS`
   (chú ý dùng curly quote `’` đúng như trong tscn để key match).

2. **Fullscreen prompt scene** (`scenes/fullscreen_prompt/fullscreen_prompt.tscn` — màn
   đầu tiên khi mở app). 3 text: tiêu đề + 2 nút.
   → `fullscreen_prompt.gd`: thêm `_apply_locale()` chạy trong `_ready()` trước
   `_start_ui()`. Nếu `GameState.user_locale == "vi"` thì set:
   - Label: "Nên dùng toàn màn hình.\nBật chế độ toàn màn hình?"
   - NoButton: " Không cần "
   - YesButton: " Có chứ! "
   - Override SystemFont Arial size 12 cho 3 control (KiwiSoda không có dấu).

3. **End screen** (kết quả game) trong `game_controller.gd._on_end_area_body_entered`:
   - Label: "Bạn đã thoát ra cùng\nGrapple Pack!\n\nCảm ơn đã chơi!"
   - TimeLabel format: `"Thời gian: %d phút %02d giây"` (thay vì `"Duration: %dm %ds"`)
   - DeathsLabel format: `"Số lần được cứu: %d"` (thay vì `"Super Duper Puter Saves: %d"`)
   - Override font Arial cho 3 label khi VI.

4. **Touch HUD nút JUMP** (`ui/touch_controls/touch_controls.gd`):
   - Khi `GameState.user_locale == "vi"` → text "NHẢY", font Arial size 8 (button 36×36).
   - Các nút khác giữ ký hiệu (`<`, `>`, `v`, `II`) — không phải chữ.

Touch left/right/down/pause dùng ký hiệu nên không cần dịch. Tên người (Diego Escalante,
GaboDBabo) và tên game (Grapple Pack) giữ nguyên.

### 2026-05-20 (session 7) — Chuyển nút Language sang vị trí cố định top-left

**Vấn đề:** Pause menu content (Grapple Pack + Created By + Credits + Volume 4 sliders +
Assist 3 checks + LangBtn) tổng height vượt viewport portrait 180×320. Language button
nằm cuối VBoxContainer → bị clip khỏi màn hình → user không thấy để toggle.

**Fix:**
- `pause/pause.tscn`: thêm `BtnLang` Button làm node static trong `Control` (KHÔNG nằm
  trong VBoxContainer), anchor top-left (offset_left=6, offset_top=44, offset_right=60,
  offset_bottom=64). Reuse `sb_close` / `sb_close_pressed` style của BtnClose. Text mặc
  định "EN/VI", font_color vàng `(1, 0.8, 0.2)`, font_size 10. Mirror cấu trúc BtnClose
  (top-right) để 2 nút đối xứng góc trên màn hình.
- Connection signal `pressed` từ `Control/BtnLang` → `_on_lang_btn_pressed`.
- `pause/pause.gd`: xoá `_add_language_button()` (dynamic HBoxContainer + Button cũ).
  `_lang_btn_text()` đổi format thành "VI ▸ EN" / "EN ▸ VI" cho gọn (button nhỏ 54×20).
  `_refresh_ui_language()` chỉ cần update text của `$Control/BtnLang` (font không cần
  override vì button luôn dùng default ascii text — không có ký tự VN cần Arial).

Effect: nút Language luôn nhìn thấy ở góc trên-trái pause menu, đối xứng với nút X
góc trên-phải. Content phía dưới có thể overflow nhưng nút quan trọng nhất luôn truy
cập được.

### 2026-05-20 (session 6) — Gỡ cửa/level 2 + refactor pause menu (GridContainer) + persist locale

**Gỡ cửa + màn 2 + enemy theo yêu cầu (focus UI menu trước):**
- `scenes/main.tscn`: xoá `LevelExitDoor` instance + 2 ext_resources `door_scene`,
  `door_sound`.
- `common/game_controller.gd`: xoá `DEBUG_DOOR_*` constants, hàm `_spawn_debug_door()`
  và call trong `_on_intro_player_just_grounded`. Khôi phục về intro thuần.
- Xoá file: `objects/level_exit/`, `objects/enemies/`, `scenes/levels/`.

**Pause menu — refactor cấu trúc Volume + Assist sang GridContainer:**

Vấn đề gốc: 2 cột riêng biệt (VBoxContainer cho labels + VBoxContainer2 cho controls).
Khi VI dùng Arial 11 thì height/row khác KiwiSoda → 2 cột mis-align → slider/checkbox
lệch dòng so với label tương ứng.

Fix bằng cấu trúc GridContainer 2 cột:
- `pause/pause.tscn`: thay `HBoxContainer3 > VBoxContainer + VBoxContainer2` (volume)
  bằng **`VolumeGrid` GridContainer columns=2**. Mỗi cặp `MasterLabel / master_slider`,
  `MusicLabel / music_slider`, ... nằm cạnh nhau trong cùng row → GridContainer tự
  align vertically. Tương tự `AssistGrid` cho `LongGrappleLabel / long_grapple_check`...
- Update toàn bộ connection paths trong tscn từ `HBoxContainer3/VBoxContainer2/*` →
  `VolumeGrid/*`, `HBoxContainer4/VBoxContainer2/*` → `AssistGrid/*`.
- `pause/pause.gd`: update `UI_LABELS` paths, `_ready()` access paths cho slider/check.
  Xoá `ROW_LABEL_PATHS` + logic `custom_minimum_size.y` ép row height — không cần nữa
  vì GridContainer auto-align.

**Persist locale + default VI:**

Vấn đề user phàn nàn: "Use A and D to move left and right." không dịch khi switch VI
vì tutorial dialogue trigger NGAY KHI VÀO GAME, trước khi user kịp mở pause toggle.

Fix:
- `common/game_state.gd`: thêm `user_locale := "vi"`, `SETTINGS_PATH := "user://settings.cfg"`,
  hàm `set_locale()`, `_load_settings()`, `_save_settings()`. Trong `_ready()` load
  config rồi `TranslationServer.set_locale(user_locale)` ngay. Default VI cho user VN.
- `pause/pause.gd._on_lang_btn_pressed`: gọi `GameState.set_locale(new_locale)` thay vì
  `TranslationServer.set_locale` trực tiếp → tự động save vào config.

Effect: lần đầu vào game = VI (vì default), tutorial dialogue dịch ngay; toggle trong
pause menu = save persist sang lần mở app tiếp theo.

### 2026-05-20 (session 5) — Fix cửa debug lơ lửng + thêm click trực tiếp lên cửa

**Cửa debug lơ lửng trên không khí:**
- `common/game_controller.gd`: `DEBUG_DOOR_OFFSET` từ `Vector2(40, -7)` → `Vector2(40, -2)`.
  Tính lại: player feet = y + 9, door half = 32 × 0.7 / 2 = 11.2 → để door bottom chạm
  feet: door_center = player_y - 2.2 ≈ -2. (Số -7 cũ là comment sai trong code gốc).

**Click chuột phải mở cửa trực tiếp (không cần player overlap):**
- `objects/level_exit/level_exit_door.gd`: thêm cơ chế thứ 2 — đăng ký
  `input_event` signal của Area2D (set `input_pickable = true`). Click/tap TRỰC TIẾP
  lên sprite cửa sẽ mở luôn, không cần player phải đứng trong vùng cửa. Vẫn giữ
  fallback cũ (player overlap + tap anywhere) cho ergonomics.
- Refactor: tách `_is_open_event(event)` helper để chia sẻ giữa `_on_input_event`
  (click direct) và `_unhandled_input` (player overlap + tap anywhere).

### 2026-05-20 (session 4) — Fix vỡ chữ + lệch hàng pause menu khi VI

**Vấn đề:**
1. Section Hỗ trợ (VI): "Móc dài / Chậm lại / Bất tử" co cụm, 3 checkbox bên phải bị lệch
   xuống không thẳng hàng với label (label Arial 13 có line height nhỏ hơn KiwiSoda
   → cột label ngắn hơn cột checkbox).
2. Section Credits (VI): chữ "Lập trình", "Đồ hoạ" bị vỡ descender — tscn gốc set
   `line_spacing = -4` cho KiwiSoda pixel font; Arial dùng số âm đó sẽ clip phần dưới
   của ký tự "p", "Đ".

**Fix trong `pause/pause.gd`:**
- Giảm `VI_FONT_SIZE` 13 → 11, thêm `VI_TITLE_FONT_SIZE = 12` cho tiêu đề section.
- `MULTILINE_LABEL_PATHS` (Design/Code/Graphics, Music/Sounds/Voice Acting): khi VI
  override `line_spacing = 0` (KO clip), khi EN remove override (trở về -4 gốc).
- `ROW_LABEL_PATHS` (4 volume label + 3 assist label): khi VI ép
  `custom_minimum_size.y = 22` (= chiều cao CheckBox/HSlider) và
  `vertical_alignment = CENTER` → mỗi row label cao bằng mỗi row control → cột label
  thẳng hàng cột checkbox/slider.
- `TITLE_LABEL_PATHS` (Created By, Volume Settings, Assist Settings): font size 12
  thay vì 11 để tiêu đề nổi hơn.

### 2026-05-20 (session 3) — Fix cửa test không hiện + dịch full pause/dialogue VI + pause overlay

**Cửa debug không thấy ở màn 1:**
- Xoá `DebugDoor` static ở `(-152, -1946)` và `LevelExitDoor2` cũ ở `(-240, -1936)` trong
  `scenes/main.tscn` — vị trí đoán mò không khớp với landing y của player.
- `common/game_controller.gd`: thêm `_spawn_debug_door()`, gọi trong
  `_on_intro_player_just_grounded()` ngay sau khi player chạm đất. Instance
  `level_exit_door.tscn` tại `_player.global_position + Vector2(40, -7)` (theo công thức
  cũ đã test thành công: x+40, y-7 để chân cửa chạm đất). Scale 0.7, z_index 50,
  next_scene = level_2.tscn, sound = DoorOpening. Guard `if get_node_or_null("DebugDoor")`
  để không spawn 2 lần khi respawn.

**Pause menu — dịch full VI:**
- `pause/pause.gd`: mở rộng `UI_LABELS` thêm 3 mục:
  - `Label` (Created By) → "Tạo bởi"
  - `HBoxContainer2/Label2` (Design/Code/Graphics) → "Thiết kế / Lập trình / Đồ hoạ"
  - `HBoxContainer2/Label3` (Music/Sounds/Voice Acting) → "Nhạc / Âm thanh / Lồng tiếng"

**Pause menu — background overlay (fix game scene chiếu xuyên qua):**
- `pause/pause.tscn`: `Control/ColorRect` đang `visible = false` → đổi thành `visible = true`
  với `color = Color(0.215686, 0.164706, 0.223529, 0.95)` (nền tím đậm semi-opaque, khớp
  màu theme). Khi pause, scene game bên dưới sẽ bị che gần hết, chỉ còn loé qua 5% alpha.

**Dialogue — dịch hết các voice line:**
- `dialogue/dialogue_controller/dialogue_controller.gd`: mở rộng `VI_TRANSLATIONS` từ
  5 dòng (chỉ tutorial) lên **~45 dòng** — bao gồm tutorial, intro 5 dòng, 3 dòng respawn,
  ~30 dòng voice line trên đường leo tower, và 2 dòng saw death. Khi locale = `vi`, dialogue
  hiện text VI bằng SystemFont (Arial/Segoe UI) để không vỡ ký tự dấu.

### 2026-05-20 (session 2) — Cửa test cạnh spawn + intro "player bước ra từ cửa" cho level 2

- `scenes/main.tscn`: thêm `DebugDoor` (instance level_exit_door) tại `(-152, -1946)` —
  cạnh vị trí spawn player `(-192, -1944)`, tap nhanh để test chuyển màn không cần leo
  hết level. Cùng `next_scene_path = "res://scenes/levels/level_2.tscn"`.
- `scenes/levels/level_2.tscn`: thêm `EntryDoor` (Sprite2D thuần, không Area2D) ở `(-90, 8)`
  scale 0.8, dùng `door.png` hframes=4 frame=3 (đã mở sẵn). Player spawn ở `(-90, 14)`
  ngay trước cửa, set `_input_enabled = false`, `_grapple_enabled = false`,
  `freeze_position = true` ngay từ tscn để gravity không kéo xuống trước intro.
  Thêm property `door_sound = DoorOpening.wav` cho root Level2 node.
- `scenes/levels/level_2.gd`: intro animation:
  1. Fade in từ đen (0.5s)
  2. Player play "walk" + phát DoorOpening sound
  3. Tween song song: cửa frame 3 → 0 (đóng dần trong 0.5s) đồng thời player tween
     position.x += 28 (bước ra ngoài cửa trong 0.7s)
  4. Player play "idle", unfreeze, enable input
  - `respawn()` skip intro (chỉ fade + reload) để khi chết khỏi xem intro lặp lại.

### 2026-05-20 — Refactor cửa chuyển màn + tạo level 2 thực sự + patrol enemy

**Vấn đề gốc:** `level_2.tscn` đang là clone gần toàn bộ `main.tscn` (1896 dòng,
dùng chính `game_controller.gd` làm script) — vào level 2 thấy y hệt level 1.
Logic cửa cũng đang có 2 cơ chế chồng nhau (auto-trigger trong `level_exit_door.gd`
+ tap/click tự tạo bằng code trong `game_controller.gd`).

**Cửa chuyển màn — gộp về một cơ chế tap-to-open:**
- `objects/level_exit/level_exit_door.gd`: viết lại — player phải overlap cửa (body_entered)
  rồi tap/click mới mở. Hỗ trợ cả `InputEventScreenTouch` lẫn `InputEventMouseButton`.
  Khi `next_scene_path == ""` thì coi là cuối game → quay về fullscreen_prompt.
- `common/game_controller.gd`: bỏ toàn bộ logic tự tạo cửa bằng code
  (`_ensure_test_level_exit_door`, `_create_exit_door`, `_open_test_level_exit_and_transition`,
  `_set_test_level_exit_frame`, các biến `_test_*`, đoạn xử lý click trong `_unhandled_input`,
  spawn TestExitDoor trong `_on_intro_player_just_grounded`). Bỏ cả việc preload door scene/sound
  vì giờ door là node thực trong scene.
- `scenes/main.tscn`: thêm `LevelExitDoor` node thực ở `(-116, -8200)` (vị trí ngay dưới
  EndArea — không chồng vùng kích hoạt end screen), scale 0.7, gán `next_scene_path` =
  `level_2.tscn` và `door_sound` = DoorOpening.wav qua Inspector property của instance.

**Level 2 thực sự — overwrite hoàn toàn:**
- `scenes/levels/level_2.tscn`: xoá bản clone 1896 dòng, viết mới ~120 dòng. Có
  Player + ShakingCamera2D + RemoteTransform2D follower + 4 tường (Floor/Ceiling/LeftWall/RightWall)
  + 2 Platform nổi để swing grapple + 2 Enemy patrol + LevelExitDoor cuối + TouchControls + Pause.
  Geometry dùng StaticBody2D + Polygon2D visual (không tilemap để khỏi cần Godot editor).
- `scenes/levels/level_2.gd`: viết lại làm `Level2Controller` riêng — chỉ fade-in
  + `respawn()` (reload current scene) + debug keys (ESC quit, R reload, F11 fullscreen).
  KHÔNG dùng `game_controller.gd` nữa.

**Patrol Enemy + Stomp (theo IDEA.md):**
- `objects/enemies/patrol_enemy.gd`: CharacterBody2D, đi ngang ở `_speed = 30`,
  đổi hướng khi GroundCheck raycast không thấy đất hoặc WallCheck thấy tường.
  Có `DamageHitbox` Area2D (collision_layer = 5 hazards) → Player.Hitbox tự detect
  và gọi `owner.respawn()` (cơ chế chết của player đã có sẵn). `StompZone` Area2D
  ở phía trên đầu (layer=0, mask=2=player) → khi player chạm với `velocity.y > 0`
  thì kill enemy + player bounce lên `-220 px/s`, tween fade sprite rồi `queue_free`.
- `objects/enemies/patrol_enemy.tscn`: sprite tạm bằng Polygon2D đỏ + Polygon2D mắt
  (không cần aseprite). User có thể thay sau.

### 2026-05-02 — Sửa pause menu + dịch tutorial sang tiếng Việt

- `pause/pause.gd`: viết lại hoàn toàn (file cũ bị hỏng mã UTF-8). Ẩn label "Kiwi Soda" (`$Control/Label2.visible = false`). Thêm nút ngôn ngữ EN/VI bằng code (`_add_language_button`). Thêm `UI_LABELS` dict + `_refresh_ui_language()` dịch toàn bộ label pause menu (Volume, Nhạc, Tiếng, Giọng, Hỗ trợ chơi, Móc dài, Chậm lại, Bất tử). Dùng `SystemFont` (Arial/Segoe UI) để tránh vỡ font KiwiSoda khi hiển thị tiếng Việt.
- `dialogue/dialogue_controller/dialogue_controller.gd`: thêm `VI_TRANSLATIONS` dict, dùng `SystemFont` (Arial/Segoe UI) cho tiếng Việt để tránh font KiwiSoda không có dấu. Khi EN, khôi phục lại font gốc.

### 2026-05-01 (session 2) — Responsive window (tự điều chỉnh theo màn hình)

- `project.godot`: `resizable=true`, window default `360×640`, thêm `stretch/aspect="keep"`
- `fullscreen_prompt.gd`: thêm `_fit_window_to_screen()` — tính kích thước cửa sổ tối đa giữ tỉ lệ 9:16
  theo `screen_get_usable_rect()`, rồi canh giữa màn hình. Chỉ chạy trên PC, mobile bỏ qua.

### 2026-05-01 (session 3) — Ép cửa test hiện ngay cạnh spawn

- `level_exit_door.tscn`: thêm `z_index = 50` để cửa render trên TileMap khi test
- `main.tscn`: dời `LevelExitDoor` về gần spawn (`-240, -1936`), scale `1.5x`, thêm `z_index = 50`
- Mục tiêu của session này là loại trừ hoàn toàn khả năng cửa bị chôn trong geometry hoặc bị TileMap che

### 2026-05-01 (session 4) — Fallback spawn cửa bằng code

- `game_controller.gd`: preload `level_exit_door.tscn` + `DoorOpening.wav`, rồi `_ensure_test_level_exit_door()` trong `_ready()`
- Nếu scene tree hiện tại chưa có `LevelExitDoor` (ví dụ Godot editor đang giữ bản `main.tscn` cũ trong memory), root sẽ tự spawn cửa test ở `(-240, -1936)`
- Mục tiêu: bypass hoàn toàn việc `.tscn` ngoài đĩa chưa được Godot reload

### 2026-05-01 (session 5) — Tạo cửa test trực tiếp bằng code để loại trừ scene cache

- Bỏ phụ thuộc runtime vào `level_exit_door.tscn` trong lúc debug; `GameController` tự tạo `Area2D + Sprite2D + CollisionShape2D`
- Thêm `Polygon2D` nền hồng bán trong suốt phía sau cửa để khi chạy game phải nhìn thấy ngay nếu node thật sự render
- Giữ nguyên hành vi test: chạm cửa → animate 4 frame → phát `DoorOpening.wav` → fade → qua `level_2.tscn`

### 2026-05-01 — Hệ thống cửa chuyển màn (Level Exit Door)

- Tạo `objects/level_exit/level_exit_door.gd` — Area2D phát hiện player, animate sprite 4 frame, fade out rồi `change_scene_to_file`
- Tạo `objects/level_exit/level_exit_door.tscn` — Sprite2D (`hframes=4`) + CollisionShape2D (20×30)
- Tạo `scenes/levels/level_2.gd` + `level_2.tscn` — màn test đơn giản, fade in khi load
- Sửa `common/game_state.gd`: thêm `reset_for_new_level()` để reset checkpoint khi chuyển màn
- Sound: dùng `sounds/DoorOpening.wav` (gán qua Inspector)
- Sprite: `aseprite/door_spritesheet_32x32.png` (4 frame, 128×32 tổng)
- **Bước tiếp theo:** Mở Godot editor → kéo `level_exit_door.tscn` vào `main.tscn`, gán `next_scene_path` và `door_sound` qua Inspector

### 2026-04-20

- Phân tích cấu trúc dự án gốc (Grapple Pack — Godot 4, GDScript)
- Xác định các điểm cần thay đổi để port sang mobile:
  - Input dùng `get_global_mouse_position()` trong `player/grapple/grapple.gd` cần thay bằng touch
  - Tất cả input keyboard trong `project.godot` cần thêm `InputEventScreenTouch` / `InputEventScreenDrag`
- Lên ý tưởng trong `IDEA.md`
- Tạo file `PROGRESS.md` để theo dõi tiến độ

### 2026-04-20 (session 2) — Touch Controls hoàn thành

- Thêm `InputEventScreenTouch` vào action `grapple` trong `project.godot`
- Sửa `player/grapple/grapple.gd`:
  - Thêm biến `_last_touch_position` lưu vị trí ngón tay
  - `_unhandled_input` bắt `InputEventScreenTouch` để cập nhật vị trí aim
  - `_set_target()` ưu tiên dùng touch position, fallback về mouse khi chạy PC
- Tạo `ui/touch_controls/touch_controls.gd` — HUD với TouchScreenButton Left/Right/Jump/Down/Pause
- Tạo `ui/touch_controls/touch_controls.tscn` — scene HUD CanvasLayer layer=10
- Thêm `TouchControls` vào `scenes/main.tscn`
- HUD tự ẩn khi chạy trên desktop (kiểm tra `OS.has_feature("mobile")`)

### 2026-04-20 (session 3) — Sửa lỗi tscn + tài liệu build

- Sửa lỗi `touch_controls.tscn`: bỏ `uid` sai format, bỏ `size`/`shape` không hợp lệ
  trên `TouchScreenButton`, bỏ comment `;` không hợp lệ trong Godot 4 tscn format
- Tạo `BUILD.md` — hướng dẫn build APK (Android) và IPA (iOS) đầy đủ

### 2026-04-23 (session 7) — Cleanup logic grapple touch (giữ y hệt PC)

- Bỏ `GRAPPLE_TAP_ZONE_RATIO` và toàn bộ `_unhandled_input` synth grapple
  trong `touch_controls.gd` — không còn chia "upper 55% mới bắn grapple"
- Grapple aim 100% dựa vào binding `InputEventScreenTouch` trong `project.godot`
  - logic `_set_target` đã có sẵn trong `grapple.gd`
- Hành vi mobile giờ giống y PC: chạm bất kỳ đâu (ngoài nút) = bắn grapple
- TouchControls chỉ còn nhiệm vụ render nút HUD + visual feedback bàn phím

### 2026-04-23 (session 6) — Căn chỉnh hình học chính xác (OCD pass)

**Hình học (viewport 180×320):**

- BtnLeft: x=8..30, y=-50..-28 → 22×22 ✓
- BtnRight: x=34..56, y=-50..-28 → 22×22 ✓ (gap 4px với Left)
- BtnDown: x=21..43, y=-26..-4 → 22×22 ✓ (trước là 22×18)
- L+R combined center x = (19+45)/2 = **32** = D center x = (21+43)/2 = **32** ✓
- BtnJump: x=-44..-8, y=-44..-8 → **36×36** với corner_radius=18 → tròn hoàn hảo
  (trước là 32×32 với radius 16, sai bán kính)
- Margin từ mép màn hình đều 4px (D bottom -4, L/R/D bên trái 8 từ rìa)

**Style:**

- Tất cả nút (kể cả D-pad) thêm `font_color` kem + `font_outline` tím đậm
  để đồng bộ với nút Pause/Close
- BtnJump tăng font 8 → 9 + outline_size 3 cho text "JUMP" rõ hơn
- Tất cả nút thêm `focus_mode = 0` (tắt focus rectangle khi click)

### 2026-04-23 (session 5) — Đồng bộ style + vị trí nút Pause / Close

- Đẩy `BtnClose` (X) trong pause menu xuống ngang hàng "Created By"
  (offset_top 6 → 44) để không bị tiêu đề "Grapple Pack" che một nửa
- Đồng bộ kích thước cả 2 nút: 20×20 px, font_size 12
- Style chung: StyleBoxFlat trắng bán trong suốt + viền trắng (giống nút D-pad),
  text màu kem có outline tím đậm — 2 nút giờ "ăn" với nhau về visual
- Bỏ `sb_pause` cũ (rect đen đặc) trong `touch_controls.tscn`

### 2026-04-23 (session 4) — Sửa nút X pause bị che

- `BtnClose` trong `pause.tscn` đang nằm trước `VBoxContainer` (chứa tiêu đề
  "Grapple Pack") → bị render đè khuất. Di chuyển xuống cuối cây Control
  để render trên cùng, thêm `z_index = 100` để chắc chắn
- Tăng kích thước nút X 18×18 → 22×22, thêm font outline cho dễ nhìn

### 2026-04-23 (session 3) — Visual feedback bàn phím + nút thoát pause cho touch

- Touch HUD: khi nhấn phím di chuyển/jump/down từ bàn phím, nút tương ứng
  trên HUD sáng lên (swap stylebox normal ↔ pressed trong `_process`)
- Logic chỉ override style khi `button_pressed = false` để không đè lên
  visual khi user thực sự nhấn touch
- Thêm `BtnClose` (X) ở góc trên phải pause menu (`pause.tscn`)
- Handler `_on_btn_close_pressed` trong `pause.gd` synth action "pause"
  để dùng lại logic toggle có sẵn → người chơi mobile thoát pause được
  mà không cần bàn phím

### 2026-04-23 (session 2) — UX HUD: D-pad tam giác + ẩn khi pause + sửa dialogue

- Đổi bố cục D-pad sang dạng tam giác: Left + Right ở hàng trên,
  Down ở hàng dưới căn giữa (trước đó Down nằm bên phải, không trực quan)
- Thêm logic ẩn `Control` của HUD khi `get_tree().paused == true`
  (set `process_mode = PROCESS_MODE_ALWAYS` để chạy được khi paused)
- Bỏ qua input grapple khi paused (tránh bắn xuyên qua menu)
- Sửa `dialogue_controller.tscn`:
  - Tăng `margin_bottom` 8 → 56 để text dialogue đẩy lên trên vùng nút HUD
  - Giảm font_size dialogue 16 → 12 cho gọn hơn
  - Chỉnh `line_spacing` -4 → -3 cho cân với font nhỏ

### 2026-04-23 — HUD nhìn được + setup Godot MCP + rule project

- Thay `TouchScreenButton` (vô hình do thiếu texture/shape) bằng `Button` thường
  với `StyleBoxFlat` bán trong suốt → nhìn thấy + click được ngay trên PC lẫn mobile
- Thêm flag `force_show_on_desktop` trong `touch_controls.gd` để bật HUD trên desktop khi test
- Bố cục lại nút theo viewport gốc 180×320 (trước đó dùng 100px → chiếm hơn nửa màn hình):
  - BtnLeft/Right: 26×26 px (góc dưới trái)
  - BtnDown: 24×14 px (giữa, nhỏ)
  - BtnJump: 36×36 px tròn (góc dưới phải)
  - BtnPause: 14×14 px (góc trên phải)
- Cài MCP `@coding-solo/godot-mcp` qua `claude mcp add godot` với env `GODOT_PATH`
  trỏ tới `D:/SafeHorizonInternShip/Godot_v4.6.2-stable_win64.exe`
- Tạo `.claude/CLAUDE.md` — rule bắt buộc cập nhật `PROGRESS.md` mỗi session,
  ghi rõ bối cảnh project (viewport 180×320, engine 4.6.2, renderer GL Compatibility)

---

## Chi tiết từng hạng mục

### Touch Controls

- [x] Tạo scene `ui/touch_controls/touch_controls.tscn` với các nút Left, Right, Jump, Down, Pause
- [x] Thêm vùng tap bắn grapple (55% trên màn hình)
- [x] Sửa `grapple.gd`: dùng touch position khi mobile, fallback mouse khi PC
- [x] Thêm `InputEventScreenTouch` vào action `grapple` trong `project.godot`
- [x] Thêm `TouchControls` node vào `scenes/main.tscn`
- [x] Sửa lỗi parse tscn (uid sai, property không hợp lệ)
- [x] Thay TouchScreenButton bằng Button có StyleBoxFlat (không cần gán texture)
- [x] Bố cục lại nút theo tỉ lệ viewport 180×320
- [ ] Test trên Android emulator hoặc thiết bị thật

### Export Android

- [ ] Cài đặt Android Export Template trong Godot
- [ ] Cấu hình `export_presets.cfg` cho Android
- [ ] Build APK thử nghiệm
- [ ] Kiểm tra GL Compatibility renderer trên thiết bị

### Hệ thống kẻ thù — Patrol Enemy

- [x] Tạo scene `objects/enemies/patrol_enemy.tscn`
- [x] Script `patrol_enemy.gd`: di chuyển qua lại, đổi hướng khi chạm tường/mép (RayCast2D)
- [x] Stomp hitbox (`StompZone` Area2D phía trên đầu) → kẻ thù chết, player bounce
- [x] Damage hitbox (`DamageHitbox` Area2D layer 5 hazards) → tận dụng Player.Hitbox sẵn có để respawn
- [ ] Animation: idle, walk, death (hiện tạm bằng Polygon2D đỏ + tween fade)
- [ ] Sound effect khi bị stomp

### Cơ chế Stomp

- [x] Phát hiện stomp: `velocity.y > 0` và va chạm từ phía trên (qua StompZone Area2D)
- [x] Player bounce sau stomp (`velocity.y = -220`)
- [ ] Tích hợp với `GameState.deaths` hoặc thêm biến `enemies_killed`

### Cửa chuyển màn

- [x] Tạo scene `objects/level_exit/level_exit_door.tscn`
- [x] Script `level_exit_door.gd`: phát hiện player vào vùng cửa + chờ tap/click mới mở
- [x] Animation mở cửa + ScreenFade
- [x] Load màn tiếp theo theo `next_scene_path` exported, `""` = về fullscreen prompt
- [ ] (Optional) Cửa khóa — chỉ mở khi điều kiện thỏa mãn

### Level 2

- [x] Tạo scene `scenes/levels/level_2.tscn` không clone main (Player + Camera + platforms + enemy + exit door)
- [x] Script `level_2.gd` riêng (`Level2Controller`) — không dùng `game_controller.gd`
- [x] Cài đặt 2 patrol enemy demo (1 trên platform, 1 dưới đất)
- [ ] Thay Polygon2D placeholder bằng tilemap đẹp + sprite enemy thật

### Tính năng phụ

- [ ] Màn hình kết quả giữa các màn (thời gian, số lần chết, kẻ thù đã giết)
- [ ] Haptic feedback (Android: `Input.vibrate_handheld()`)
- [ ] Leaderboard local (lưu `FileAccess`)
