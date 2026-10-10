# Hướng Dẫn Cấu Hình, Khởi Chạy & Kiểm Thử SolidWorks MCP Server (SolidPilot)

> **Dành cho:** Coding Agents (Antigravity, Claude Code, Cursor, Windsurf, OpenClaw, v.v.) và Kỹ sư tích hợp hệ thống.  
> **Mục tiêu:** Kết nối trực tiếp AI Coding Agent với SolidWorks thông qua giao thức MCP (Model Context Protocol) để thiết kế, đo đạc, phân tích mô hình 3D và lắp ráp cơ khí tự động.

---

## 1. Tổng Quan Kiến Trúc (Architecture)

SolidWorks MCP (tên dự án: **SolidPilot**) được thiết kế theo mô hình 2 tầng phân tách trách nhiệm (Separation of Concerns) để đảm bảo an toàn tuyệt đối cho tiến trình COM của SolidWorks:

```
┌────────────────────────────────────────────────────────┐
│              AI Coding Agent (Host)                    │
│      (Antigravity / Claude Code / Cursor / Windsurf)   │
└───────────────────────────┬────────────────────────────┘
                            │ (MCP stdio protocol)
┌───────────────────────────▼────────────────────────────┐
│         Adapter Layer (Python MCP SDK v2)              │
│       adapters/claude/server.py                        │
│   - Nhận lệnh MCP từ Agent                             │
│   - Tự động kiểm tra / auto-start Execution Server     │
│   - Chuyển đổi định dạng & map response                │
└───────────────────────────┬────────────────────────────┘
                            │ (REST HTTP :5000)
┌───────────────────────────▼────────────────────────────┐
│      Execution Layer (C# .NET 4.8 / SolidPilot)        │
│       SolidworksExecution.exe                          │
│   - Single-threaded STA Apartment (Thread-safe)        │
│   - Quản lý state_version & idempotency                │
│   - Thành phần DUY NHẤT được phép gọi COM API          │
└───────────────────────────┬────────────────────────────┘
                            │ (COM API: SldWorks.Application)
┌───────────────────────────▼────────────────────────────┐
│                Dassault Systèmes SolidWorks            │
│                 (Phiên bản 2020 – 2026)                │
└────────────────────────────────────────────────────────┘
```

---

## 2. Yêu Cầu Môi Trường (Prerequisites)

Hệ thống bắt buộc phải đáp ứng các điều kiện sau:

| Thành phần | Yêu cầu tối thiểu | Ghi chú |
|---|---|---|
| **Hệ điều hành** | Windows 10 / Windows 11 64-bit | Bắt buộc vì SolidWorks COM API chỉ hỗ trợ Windows. |
| **SolidWorks** | SolidWorks 2020 – 2026 | Khuyến nghị đã cài đặt và kích hoạt bản quyền. |
| **.NET Runtime** | .NET Framework 4.8 | Tích hợp sẵn trên Windows 10/11 hoặc Visual Studio 2022. |
| **Python** | Python 3.10 – 3.12 64-bit | Khuyên dùng virtual environment (`.venv`). |
| **Thư viện Python** | `mcp>=2.0.0`, `httpx`, `pydantic` | Cài đặt qua `requirements.txt` trong thư mục adapter. |

---

## 3. Hướng Dẫn Cài Đặt Ban Đầu (Setup)

### Bước 1: Khởi tạo môi trường ảo Python cho Adapter

Mở PowerShell tại thư mục gốc của repository `solidworks-mcp`:

```powershell
cd "D:\Project\uet robotic arm\tools\solidworks-mcp\adapters\claude"

# Tạo virtual environment nếu chưa có
python -m venv .venv

# Kích hoạt venv
.\.venv\Scripts\Activate.ps1

# Cài đặt các thư viện cần thiết
pip install -r requirements.txt
```

### Bước 2: Kiểm tra file thực thi Execution Layer (C#)

Đảm bảo file `SolidworksExecution.exe` đã được biên dịch sẵn tại:
```
D:\Project\uet robotic arm\tools\solidworks-mcp\execution\solidworks\SolidworksExecution\bin\Debug\SolidworksExecution.exe
```

> **Ghi chú (Nếu cần biên dịch từ mã nguồn):**
> ```powershell
> & "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" execution\solidworks\SolidworksExecution.sln /t:Build /p:Configuration=Debug
> ```

---

## 4. Đăng Ký MCP Server Cho Coding Agents

Dưới đây là cấu hình JSON cho các nền tảng Coding Agent thông dụng:

### 4.1. Dành cho Google Antigravity / Gemini Code Assist
Cấu hình tại file: `C:\Users\<username>\.gemini\config\mcp_config.json`:

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "D:/Project/uet robotic arm/tools/solidworks-mcp/.venv/Scripts/python.exe",
      "args": [
        "D:/Project/uet robotic arm/tools/solidworks-mcp/adapters/claude/server.py"
      ],
      "cwd": "D:/Project/uet robotic arm/tools/solidworks-mcp/adapters/claude",
      "env": {
        "PYTHONUTF8": "1",
        "PYTHONIOENCODING": "utf-8",
        "EXECUTION_BASE_URL": "http://localhost:5000"
      }
    }
  }
}
```

### 4.2. Dành cho Claude Desktop & Claude Code
Cấu hình tại file: `%APPDATA%\Claude\claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "D:/Project/uet robotic arm/tools/solidworks-mcp/.venv/Scripts/python.exe",
      "args": [
        "D:/Project/uet robotic arm/tools/solidworks-mcp/adapters/claude/server.py"
      ],
      "cwd": "D:/Project/uet robotic arm/tools/solidworks-mcp/adapters/claude",
      "env": {
        "PYTHONUTF8": "1",
        "PYTHONIOENCODING": "utf-8",
        "EXECUTION_BASE_URL": "http://localhost:5000"
      }
    }
  }
}
```

### 4.3. Dành cho Cursor IDE / Windsurf
Cấu hình tại mục Settings -> MCP Servers (hoặc `.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "D:/Project/uet robotic arm/tools/solidworks-mcp/.venv/Scripts/python.exe",
      "args": [
        "D:/Project/uet robotic arm/tools/solidworks-mcp/adapters/claude/server.py"
      ],
      "env": {
        "PYTHONUTF8": "1",
        "PYTHONIOENCODING": "utf-8",
        "EXECUTION_BASE_URL": "http://localhost:5000"
      }
    }
  }
```

---

## 5. Cơ Chế Khởi Chạy (Execution Modes)

### Chế độ 1: Tự động khởi chạy ngầm (Auto-Spawn — Khuyên Dùng)
- Adapter Python đã được tích hợp module `_ensure_server_up()`.
- Khi Coding Agent gọi bất kỳ công cụ SolidWorks nào (ví dụ `ensure_ready`), Adapter sẽ tự động kiểm tra endpoint `http://localhost:5000/health`.
- Nếu server C# chưa chạy, Adapter sẽ **tự động khởi động `SolidworksExecution.exe` ở chế độ ngầm (Detached Process, không nháy cửa sổ console)**.
- **Agent không cần chạy lệnh khởi động thủ công.**

### Chế độ 2: Khởi chạy thủ công (Manual / Debugging)
Khi cần xem log chi tiết hoặc gỡ lỗi kết nối COM:
```powershell
# Chạy Execution Server trong cửa sổ console riêng
cd C:\Users\Admin\.gemini\mcp-servers\solidworks-mcp\execution\solidworks\SolidworksExecution\bin\Debug
.\SolidworksExecution.exe

# Kiểm tra trạng thái REST endpoint
curl http://localhost:5000/health
# Kết quả mong đợi: {"status":"READY","comAttached":true,"stateVersion":0}
```

---

## 6. Quy Trình Kiểm Thử (Smoke Test Workflow)

Coding Agent nên thực hiện chuỗi test sau để đảm bảo hệ thống sẵn sàng $100\%$:

### Test 1: Kiểm tra kết nối COM & Trạng thái SolidWorks (`ensure_ready`)
Gọi tool:
```json
{
  "server_name": "solidworks",
  "tool_name": "ensure_ready",
  "arguments": {}
}
```
**Kết quả mong đợi:**
```text
READY | server=UP | com_attached=True | sw_launched=False | active_document=... | sw_version=34.0.0 | state_version=...
```
- `server=UP`: Execution REST API đang lắng nghe bình thường.
- `com_attached=True`: Đã gắn kết thành công với tiến trình SolidWorks.

---

### Test 2: Khảo sát tài liệu đang mở (Read-only Test)
Nếu SolidWorks đang mở một Part hoặc Assembly, gọi lệnh đọc an toàn:
```json
// Với Part:
{
  "server_name": "solidworks",
  "tool_name": "analyze_model",
  "arguments": { "analysis_type": "features" }
}

// Với Assembly:
{
  "server_name": "solidworks",
  "tool_name": "analyze_assembly",
  "arguments": { "analysis_type": "components" }
}
```
**Kết quả mong đợi:** Trả về JSON chứa danh sách Features hoặc Components mà không làm thay đổi trạng thái file.

---

### Test 3: Tạo chi tiết & Đùn khối thử nghiệm (Write / Modeling Test)
Thực hiện tuần tự:
1. Tạo Part mới: `open_new_part()`
2. Tạo phác thảo: `create_sketch(plane="Top Plane")`
3. Thêm hình tròn: `add_sketch_entity(entity_type="circle", center=[0.0, 0.0], radius=0.025)` *(bán kính 25mm)*
4. Đùn khối: `extrude_feature(operation="boss", depth=0.010)` *(đùn dày 10mm)*
5. Kiểm tra kết quả: `analyze_model(analysis_type="geometry")`
6. Đóng không lưu: `close_document(save=False)`

---

## 7. Các Quy Tắc Bắt Buộc Cho Coding Agent (Strict Agent Rules)

Khi viết prompt hoặc gán chỉ thị hệ thống cho Agent sử dụng SolidWorks MCP, **BẮT BUỘC** tuân thủ các điều sau:

### 🔴 Quy tắc 1: Khóa COM độc quyền (Exclusive Lock)
- Tiến trình `SldWorks.Application` trên Windows **chỉ cho phép 1 kết nối COM duy nhất tại một thời điểm**.
- **Tuyệt đối KHÔNG chạy script Python bên ngoài** (dùng `win32com.client`) trong khi SolidWorks MCP đang chạy, vì sẽ gây xung đột khóa (Exclusive Lock error) làm treo SolidWorks.

### 🔴 Quy tắc 2: Quy ước Đơn vị: Thiết kế dùng mm — Gọi COM API dùng Mét ($m$)
- **Trong tư duy thiết kế, thảo luận & bản vẽ cơ khí:** Đơn vị tiêu chuẩn **luôn luôn là Milimét ($mm$)** (hệ MMGS: milimet - gram - giây). Mọi kích thước trao đổi giữa Kỹ sư và Agent (ví dụ: đường kính $\varnothing 82\text{ mm}$, cao $58\text{ mm}$, độ sâu lỗ $5.5\text{ mm}$) đều được hiểu theo chuẩn $mm$.
- **Tại sao API lại dùng Mét ($m$)?**
  - Đây là quy định kiến trúc cốt lõi của **Dassault Systèmes**: Toàn bộ hàm COM API nội tại của SolidWorks (`IFeatureManager::FeatureExtrusion3`, `ISketchManager::CreateCircleByRadius`...) đều tính toán bằng đơn vị cơ bản quốc tế **SI (Mét)** bất kể file CAD đang hiển thị hệ MMGS hay IPS.
  - Nếu Agent truyền thẳng số `10` (với ý định $10\text{ mm}$), SolidWorks API sẽ hiểu là **$10\text{ mét}$** (khối đùn to bằng tòa nhà 3 tầng)!
- **Trách nhiệm chuyển đổi của Coding Agent:**
  - **Khi gọi Tool MCP:** Agent phải tự động nhân với $10^{-3}$ ($1\text{ mm} = 0.001\text{ m}$).
    - Bán kính $r = 41\text{ mm} \longrightarrow \text{radius} = 0.041$
    - Độ sâu cắt $h = 5.5\text{ mm} \longrightarrow \text{depth} = 0.0055$
    - Chiều cao đùn $H = 58\text{ mm} \longrightarrow \text{depth} = 0.058$
  - **Khi đọc dữ liệu trả về từ MCP (Inspection / Analysis):** Agent phải tự động nhân với $1000$ để báo cáo kích thước dạng $mm$ trực quan cho kỹ sư con người.

### 🔴 Quy tắc 3: Theo dõi `state_version` & Kiểm tra lỗi sau mỗi bước
- Mỗi lệnh tạo/sửa khối (Mutating tool) sẽ tăng `state_version` lên 1 đơn vị.
- Sau khi thực hiện các lệnh nhạy cảm (`extrude_feature`, `add_mate`, `edit_feature`), luôn gọi `analyze_model` hoặc `analyze_assembly` để kiểm tra `result_geometry` và đảm bảo không có feature hoặc mate bị báo đỏ (Missing Reference / Over-defined).

### 🔴 Quy tắc 4: Lưu tài liệu định kỳ
- Luôn chủ động gọi `save_document` sau khi hoàn thành một cụm tính năng logic để tránh mất dữ liệu khi SolidWorks gặp sự cố bộ nhớ.

---

## 8. Bảng Tra Cứu Nhanh Các Tool Phổ Biến (Cheat Sheet)

| Nhóm chức năng | Tên Tool | Mục đích sử dụng |
|---|---|---|
| **Vòng đời tài liệu** | `ensure_ready` | Kiểm tra kết nối COM và trạng thái SolidWorks. |
| | `open_new_part` / `open_new_assembly` | Tạo tài liệu Part / Assembly mới. |
| | `open_document` / `activate_document` | Mở file từ đĩa hoặc chuyển đổi giữa các tab tài liệu. |
| | `save_document` / `close_document` | Lưu file hiện tại hoặc đóng tài liệu. |
| **Phác thảo (Sketch)** | `create_sketch` / `edit_sketch` | Bắt đầu sketch trên mặt phẳng hoặc mở lại sketch cũ. |
| | `add_sketch_entity` | Vẽ đoạn thẳng, đường tròn, cung tròn, chữ nhật, spline. |
| | `add_sketch_constraint` | Thêm ràng buộc hình học (Coincident, Concentric, Horizontal...). |
| | `add_dimension` | Gán kích thước đo cho đoạn thẳng, góc hoặc đường tròn. |
| **Tạo khối 3D** | `extrude_feature` | Đùn khối (`boss`), cắt khối (`cut`), xoay (`revolve`), sweep. |
| | `add_edge_feature` | Bo tròn cạnh (`fillet`) hoặc vát mép (`chamfer`). |
| | `create_pattern` | Tạo mảng sao chép tuyến tính (Linear) hoặc xoay tròn (Circular). |
| | `modify_dimension` | Chỉnh sửa trực tiếp giá trị kích thước của Feature đã vẽ. |
| **Lắp ráp (Assembly)**| `insert_component` | Chèn part vào assembly kèm tọa độ/gốc đặt. |
| | `add_mate` | Gán quan hệ lắp ráp (Concentric, Coincident, Parallel, Distance...). |
| | `analyze_assembly` | Đọc cấu trúc cây lắp ráp, danh sách linh kiện và quan hệ mates. |
| **Khảo sát (Analysis)**| `analyze_model` | Đo thể tích, khối lượng, diện tích, danh sách mặt (faces), cạnh (edges). |
| | `get_selection` | Đọc thực thể hình học người dùng đang click chọn trên giao diện SolidWorks. |
| | `verify_state` | Kiểm tra tính hợp lệ và danh sách cây tính năng hiện thời. |

---

## 9. Quy Ước Hình Học Khi Dùng Tool (đã kiểm chứng trên dự án)

| Tình huống | Quy ước |
|---|---|
| Sketch trên `Front Plane` hoặc mặt phẳng song song | $(x, y)$ sketch $\to$ $(x, y)$ của chi tiết; pháp tuyến $+Z$ |
| Sketch trên `Top Plane` hoặc mặt phẳng song song | $(x, y)$ sketch $\to$ $(x, -z)$ của chi tiết; pháp tuyến $+Y$ |
| Sketch trên `Right Plane` hoặc mặt phẳng song song | đọc `frame.xdir` / `frame.ydir` trong kết quả `create_sketch` trước khi vẽ |
| `extrude_feature` (boss và cut) | mặc định đi theo chiều pháp tuyến dương; `reverse=true` để đi ngược |
| Cung $180^\circ$ bằng `arc_center` | chia thành hai cung $90^\circ$ |
| `transform_json` của `insert_component` | 3 hàng đầu là 3 trục của component biểu diễn trong hệ assembly, sau đó là tịnh tiến (mét) |
| Sửa chi tiết đang nằm trong assembly đang mở | lưu chi tiết, rồi kích hoạt lại assembly để nó cập nhật |
| Xuất STL ngay sau khi tạo feature | đóng và mở lại tài liệu trước khi xuất, nếu không chỉ các mặt đang được chọn bị xuất |
| File đang mở ở cửa sổ SolidWorks khác | sao ra thư mục tạm rồi mở bản sao; không dùng `close_document(close_all=true)` |
