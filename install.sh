#!/usr/bin/env bash
# Cài giao diện "thẻ nổi + đất nung" cho VS Code (macOS / Linux).
# Việc script làm:
#   1. chép float-clay.css và float-clay-menu.js vào ~/.vscode-custom/
#   2. gộp settings-float-clay.json vào settings.json của VS Code (có sao lưu trước)
#   3. cài extension Custom CSS and JS Loader nếu tìm thấy lệnh `code`
# Script KHÔNG sửa file của app VS Code. Bước cuối (bật CSS) phải tự làm trong VS Code, xem README.md.
#
# Dùng:  ./install.sh          hỏi xác nhận trước khi sửa settings.json
#        ./install.sh --yes    không hỏi
#        ./install.sh --no-settings   chỉ chép CSS, không đụng settings.json
set -euo pipefail

ASSUME_YES=0; SKIP_SETTINGS=0
for a in "$@"; do
  case "$a" in
    --yes|-y) ASSUME_YES=1 ;;
    --no-settings) SKIP_SETTINGS=1 ;;
    *) echo "Tham số không hợp lệ: $a"; exit 2 ;;
  esac
done

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.vscode-custom"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [ -n "${CLAY_USER_DIR:-}" ]; then
  USER_DIR="$CLAY_USER_DIR"            # chỉ dùng để thử nghiệm
elif [ "$(uname)" = "Darwin" ]; then
  USER_DIR="$HOME/Library/Application Support/Code/User"
else
  USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
fi
SETTINGS="$USER_DIR/settings.json"

for f in float-clay.css float-clay-menu.js settings-float-clay.json; do
  [ -f "$HERE/$f" ] || { echo "Thiếu file $f cạnh install.sh"; exit 1; }
done
command -v python3 >/dev/null || { echo "Cần python3 để gộp settings."; exit 1; }

# ---- 1. chép CSS ----
mkdir -p "$TARGET_DIR/backup"
if [ -f "$TARGET_DIR/float-clay.css" ] && ! cmp -s "$HERE/float-clay.css" "$TARGET_DIR/float-clay.css"; then
  cp "$TARGET_DIR/float-clay.css" "$TARGET_DIR/backup/float-clay.css.$STAMP.bak"
  echo "• Đã sao lưu CSS cũ: $TARGET_DIR/backup/float-clay.css.$STAMP.bak"
fi
cp "$HERE/float-clay.css" "$TARGET_DIR/float-clay.css"
echo "• Đã chép CSS vào $TARGET_DIR/float-clay.css"
if [ -f "$TARGET_DIR/float-clay-menu.js" ] && ! cmp -s "$HERE/float-clay-menu.js" "$TARGET_DIR/float-clay-menu.js"; then
  cp "$TARGET_DIR/float-clay-menu.js" "$TARGET_DIR/backup/float-clay-menu.js.$STAMP.bak"
fi
cp "$HERE/float-clay-menu.js" "$TARGET_DIR/float-clay-menu.js"
echo "• Đã chép JS menu vào $TARGET_DIR/float-clay-menu.js (chỉ chèn CSS vào menu chuột phải, xem README)"

# ---- 2. gộp settings ----
if [ "$SKIP_SETTINGS" -eq 1 ]; then
  echo "• Bỏ qua settings.json (--no-settings). Tự gộp settings-float-clay.json nếu cần."
else
  mkdir -p "$USER_DIR"
  if [ ! -f "$SETTINGS" ]; then
    cp "$HERE/settings-float-clay.json" "$SETTINGS"
    echo "• Chưa có settings.json, đã tạo mới từ settings-float-clay.json"
  else
    echo "• Sẽ gộp settings-float-clay.json vào: $SETTINGS"
    echo "  Các khoá bị ghi đè nếu đã tồn tại; khoá window.density.layout = compact sẽ bị gỡ (làm khe giữa các thẻ bị nén)."
    echo "  LƯU Ý: file được ghi lại dạng JSON chuẩn nên các dòng chú thích (//) trong settings.json sẽ mất."
    if [ "$ASSUME_YES" -ne 1 ]; then
      read -r -p "  Tiếp tục? [y/N] " ans
      case "$ans" in y|Y|yes|YES) ;; *) echo "  Đã huỷ gộp settings. CSS đã được chép."; SKIP_SETTINGS=1 ;; esac
    fi
    if [ "$SKIP_SETTINGS" -ne 1 ]; then
      cp "$SETTINGS" "$TARGET_DIR/backup/settings.json.$STAMP.bak"
      echo "  Đã sao lưu: $TARGET_DIR/backup/settings.json.$STAMP.bak"
      python3 -I - "$SETTINGS" "$HERE/settings-float-clay.json" <<'PY'
import json, re, sys
path, frag_path = sys.argv[1], sys.argv[2]
raw = open(path, encoding="utf-8").read()
clean = re.sub(r'^\s*//.*$', '', raw, flags=re.M)          # chú thích cả dòng
clean = re.sub(r',(\s*[}\]])', r'\1', clean)                # dấu phẩy thừa
try:
    cur = json.loads(clean) if clean.strip() else {}
except Exception as e:
    sys.exit("  Không đọc được settings.json (%s). Không sửa gì; hãy gộp tay từ settings-float-clay.json." % e)
frag = json.load(open(frag_path, encoding="utf-8"))
cur.update(frag)
if cur.get("window.density.layout") == "compact":
    del cur["window.density.layout"]
json.dump(cur, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
open(path, "a").write("\n")
print("  Đã gộp %d khoá vào settings.json" % len(frag))
PY
    fi
  fi
fi

# ---- 3. extension ----
CODE_BIN="$(command -v code || true)"
if [ -z "$CODE_BIN" ] && [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi
if [ "${CLAY_SKIP_EXT:-0}" = "1" ]; then
  echo "• Bỏ qua bước cài extension (CLAY_SKIP_EXT=1)."
elif [ -n "$CODE_BIN" ]; then
  echo "• Cài extension Custom CSS and JS Loader (be5invis.vscode-custom-css)"
  "$CODE_BIN" --install-extension be5invis.vscode-custom-css >/dev/null 2>&1 \
    && echo "  Xong." || echo "  Không cài được tự động, hãy cài tay trong VS Code (tab Extensions)."
  echo "• Cài extension phụ trợ cweijan.vscode-office (tuỳ chọn)"
  "$CODE_BIN" --install-extension cweijan.vscode-office >/dev/null 2>&1 \
    && echo "  Xong." || echo "  Bỏ qua."
else
  echo "• Không tìm thấy lệnh 'code'. Hãy cài extension 'Custom CSS and JS Loader' (be5invis.vscode-custom-css) trong VS Code."
fi

cat <<'EOF'

Còn một bước phải tự làm trong VS Code (script không làm thay được):
  1. Mở Command Palette (Cmd/Ctrl+Shift+P) -> chạy "Enable Custom CSS and JS"
  2. Bấm Restart khi được hỏi. Nếu thấy cảnh báo "installation appears to be corrupt" thì chọn "Don't show again".
Sau mỗi lần VS Code cập nhật, chạy lại bước 1-2. Xem README.md để biết cách gỡ.
EOF
