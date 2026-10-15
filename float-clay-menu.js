/* float-clay-menu.js — chỉ làm một việc: chèn một <style> vào lớp "shadow DOM" của menu chuột phải / dropdown
   (CSS bên ngoài không chạm tới được lớp này). Không đọc, không ghi, không gửi dữ liệu nào ra ngoài.
   Nạp qua extension Custom CSS and JS Loader, cùng chỗ với float-clay.css. */
(() => {
  const CSS = `
    .monaco-menu { font-size: 12.5px; min-width: 200px; }
    .monaco-menu .monaco-action-bar.vertical { padding: 6px 0; }
    .monaco-menu .monaco-action-bar.vertical .action-menu-item {
      height: 28px !important;
      margin: 0 6px !important;
      border-radius: 10px !important;
    }
    .monaco-menu .monaco-action-bar.vertical .action-item.focused > .action-menu-item {
      background-color: #f5e7dd !important;
    }
    .monaco-menu .monaco-action-bar.vertical .action-label.separator {
      margin: 6px 14px !important;
      width: auto !important;
    }
  `;

  const inject = (host) => {
    const root = host && host.shadowRoot;
    if (!root || root.getElementById('clay-menu-style')) return;
    const style = document.createElement('style');
    style.id = 'clay-menu-style';
    style.textContent = CSS;
    root.appendChild(style);
  };

  const start = () => {
    const workbench = document.querySelector('.monaco-workbench');
    if (!workbench) { setTimeout(start, 500); return; }
    workbench.querySelectorAll(':scope > .shadow-root-host').forEach(inject);
    // menu được gắn thẳng vào .monaco-workbench, nên chỉ cần theo dõi con trực tiếp (nhẹ, không quét cả cây)
    new MutationObserver((records) => {
      for (const r of records) for (const n of r.addedNodes) {
        if (n.nodeType === 1 && n.classList.contains('shadow-root-host')) inject(n);
      }
    }).observe(workbench, { childList: true });
  };

  start();
})();
