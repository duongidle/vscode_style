# VS Code "thẻ nổi + đất nung"

Giao diện VS Code sáng, bo góc, gọn, kiểu Claude Desktop / Codex. Các khối là thẻ nổi bo 16px trên nền kem, nhấn màu đất nung.

![Giao diện mẫu](images/demo.png)

Làm cho **VS Code 1.142** trên macOS. Chưa thử trên Windows và Linux.

## Cài

```bash
git clone https://github.com/duongidle/vscode_v-float-clay_style.git
cd vscode_v-float-clay_style
./install.sh
```

Script chép CSS vào `~/.vscode-custom/`, gộp setting vào `settings.json` (có sao lưu, hỏi trước khi sửa), cài extension *Custom CSS and JS Loader*, và cài phông **Figtree** và **Fira Code** (có sẵn trong thư mục `font/`) nếu máy chưa có. Không muốn cài phông thì thêm `--no-fonts`.

Sau đó trong VS Code: `Cmd+Shift+P` → **Enable Custom CSS and JS** → **Restart**.
Nếu báo "installation appears to be corrupt" thì chọn **Don't show again**, đó là bình thường.

### Cài tay (Windows hoặc không muốn chạy script)

1. Cài extension `be5invis.vscode-custom-css`.
2. Chép `float-clay.css` và `float-clay-menu.js` vào thư mục `.vscode-custom` trong thư mục cá nhân.
3. Gộp `settings-float-clay.json` vào `settings.json`.
4. Cài các file `.ttf` trong `font/Figtree/static/` và `font/Fira_Code/static/` (bấm đúp từng file, hoặc chép vào thư mục phông của hệ điều hành).
5. Chạy **Enable Custom CSS and JS** rồi Restart.

## Lưu ý

- Mỗi lần VS Code cập nhật, chạy lại **Enable Custom CSS and JS**. Nếu giao diện bị lệch sau cập nhật lớn, đó là do CSS bám vào cấu trúc nội bộ của VS Code.
- Gói đặt `window.menuStyle` và `window.dialogStyle` thành `custom` để VS Code tự vẽ menu và hộp thoại (trên macOS mặc định là của hệ điều hành, không đổi được giao diện). Muốn trả về như cũ, xoá hai dòng này.
- Phông giao diện là **Figtree**, phông code là **Fira Code**. Thiếu phông thì VS Code tự dùng phông hệ thống, không lỗi.
- Thanh status chỉ giữ vị trí con trỏ và số lỗi (đã ẩn Copilot, chuông, ngôn ngữ, mã hoá...). Muốn hiện lại, xoá khối "status bar" trong `float-clay.css`.
- Nếu đang dùng `window.density.layout: compact` thì bỏ đi, vì nó làm khe giữa các thẻ bị nén.

## Gỡ

**Disable Custom CSS and JS** → Restart. Rồi xoá các dòng có trong `settings-float-clay.json` khỏi `settings.json` (hoặc khôi phục từ bản sao lưu trong `~/.vscode-custom/backup/`).

## Giấy phép

Mã nguồn: [MIT](LICENSE). Phông trong `font/`: SIL Open Font License (xem `OFL.txt` trong từng thư mục).
