# AGENTS.md — Hướng dẫn đóng góp & công cụ

## Chuỗi công cụ

| Việc | Công cụ / MCP | Quy ước |
|---|---|---|
| Thiết kế CAD parametric | MCP `onshape` (local, `~/tools/onshape-mcp`) | Model làm trên Onshape cloud (`cad.onshape.com`); chỉ commit bản **export** STEP/STL vào `cad/exports/` |
| Custom FeatureScript (tính năng lặp) | MCP `featurescript` (Onshape Labs, remote) | Cần `ONSHAPE_LABS_TOKEN`; code nguồn đặt `cad/featurescript/` |
| Tài liệu / thuyết minh / báo cáo | MCP `typst` + CLI `typst compile` | Nguồn `.typ` trong `docs/typst/`; xuất PDF vào `docs/typst/out/` |
| Điều khiển robot | Arduino (chưa dùng MCP) | Nguồn đặt `firmware/` |

## Quy tắc quan trọng

- **KHÔNG commit secret**: Onshape và mọi API key chỉ nằm ngoài repo
  (`~/.config/onshape/env.sh`, chmod 600, được nạp qua `~/.zshrc`). Khi dùng
  MCP `onshape`, biến `ONSHAPE_ACCESS_KEY`/`ONSHAPE_SECRET_KEY` được kế thừa
  từ môi trường của opencode — không cần và không được ghi vào file.
- Model CAD sống trên cloud Onshape: **không** commit file model dự án thật;
  chỉ commit file tái tạo được (FeatureScript) và bản xuất (STEP/STL).
- Tài liệu đánh dấu (`*.md`) dùng để cộng tác nhanh; bản **chính thức** (thuyết
  minh < 20 trang) soạn bằng Typst và xuất PDF.
- Luôn chạy `typst compile` trước khi coi tài liệu hoàn tất; MCP `typst` có tool
  kiểm tra cú pháp và render PNG để xem thử.

## Cấu trúc thư mục

```
├── docs/
│   ├── typst/            # Nguồn Typst (thuyết minh, biểu mẫu) + out/
│   └── *.md              # Yêu cầu kỹ thuật, quyết định thiết kế…
├── cad/
│   ├── featurescript/    # Custom feature code
│   └── exports/          # STEP/STL xuất từ Onshape
└── firmware/             # Arduino code
```