# Grapple Pack — Mobile Port (Fork)

<p align="center">
  <picture>
	<source srcset="../assets/gameplay.gif?raw=true">
	<img alt="Shows a gif with a snippet of gameplay." src="../assets/gameplay.gif?raw=true">
  </picture>
</p>

> **Về bản fork này (tiếng Việt):** Đây là bản port **Grapple Pack** từ PC sang **mobile
> (Android)** bằng Godot 4.6, thực hiện như một đồ án thực tập. So với bản gốc, bản này thêm:
> điều khiển cảm ứng đa chạm (multi-touch), hệ thống 4 loại kẻ thù có hoạt ảnh tấn công &
> phản hồi sát thương, giao diện song ngữ **Anh/Việt**, và build được file **APK** chạy trên
> thiết bị thật. Toàn bộ credit gameplay/art/nhạc gốc thuộc về các tác giả ban đầu (xem dưới).
>
> 📄 Tài liệu dự án: [IDEA.md](IDEA.md) (kế hoạch) · [PROGRESS.md](PROGRESS.md) (nhật ký) ·
> [BUILD.md](BUILD.md) (hướng dẫn build APK/IPA) · [HISTORY_PROMPT.md](HISTORY_PROMPT.md) (lịch sử).

## Tính năng bản mobile

- 🎮 **Touch controls đa chạm** — D-pad (Trái/Phải/Xuống) + Nhảy + Pause; giữ nhiều nút cùng
  lúc (vừa chạy vừa nhảy, vừa đu dây). Chạm vùng trống màn hình để bắn móc theo hướng ngón.
- 👾 **Hệ thống 4 kẻ thù** — Mushroom (dậm đầu), Flying Eye / Goblin / Skeleton (giết bằng
  móc 1/2/3 phát), có hoạt ảnh tấn công và hiệu ứng trúng đòn.
- 🌐 **Song ngữ Anh / Việt** — chuyển ngôn ngữ ngay trong menu Pause, lưu lựa chọn.
- 📱 **Build Android** — màn hình dọc 180×320, renderer GL Compatibility, APK chạy thiết bị thật.

---

## Bản gốc (original game)

## [Play the game here!](https://diego-escalante.itch.io/grapple-pack)

This game was made in the month of November for the 2023 GitHub Game Off jam. The theme of the jam was "scale." It was made with Godot 4 using GDScript. You can read the game's feedback [here](https://itch.io/jam/game-off-2023/rate/2346085).

## Setting Up the Project Locally
1. Make sure you have [Godot 4](https://godotengine.org/download) installed, as that is the version of the engine that was used for this game. No need to get the .NET version of Godot, as this project purely uses GDScript.
2. Clone this repo in your desired directory: `git clone https://github.com/diego-escalante/GO2023-GrapplePack.git`
3. Start up Godot. In the initial Project Manager window, click Import and choose the `project.godot` file at the root of your cloned repo.
4. Once the engine opens up the project, you can run the game by using the Play buttons on the top right.

> **Build APK (Android):** xem hướng dẫn chi tiết trong [BUILD.md](BUILD.md). Tóm tắt: cài
> JDK 17 + Android SDK (command-line tools), tải Export Templates trong Godot, rồi
> **Project → Export → Android → Export Project**. Bản fork đã có sẵn preset Android và đã
> khoá màn hình dọc (Portrait).

## Rankings
The game received the following rankings in the game jam:
| Category   | Rank (out of 634 entries) |
|-----------:|:--------------------------|
| Overall    | 3🥉                      |
| Gameplay   | 1🥇                      |
| Audio      | 9                         |
| Graphics   | 27                        |
| Innovation | 105                       |
| Theme      | 89                        |

## Links
The game has been featured in the following places:
* [GitHub Blog: Game Off 2023 Results](https://github.blog/2024-01-09-game-off-2023-results/)
* [DEV: Ten great Godot games + source code from Game Off 2023](https://dev.to/github/top-godot-games-from-game-off-2023-5f3k)
* [GitHub Blog: Game Bytes · January 2024](https://github.blog/2024-01-18-game-bytes-january-2024/)
* [YouTube: GitHub Game Off 2023 Results](https://youtu.be/jXyBsaioXFA?si=HfMKL2270DAjxae6)
