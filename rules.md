# HRM Odoo 19 — Vibe Coding Rules

> Bộ quy tắc bất di bất dịch áp dụng cho toàn bộ session.  
> AI và human đều phải tuân theo. Không có ngoại lệ.

---

## 🔧 Môi trường

| Thành phần | Phiên bản |
|------------|-----------|
| Odoo       | 19        |
| Python     | 3.10 – 3.14 |
| IDE        | VSCode    |
| Module     | HRM (Human Resource Management) |

---

## 🚫 Nguyên tắc tối thượng — không bao giờ được phá vỡ

### 1. Không được xóa file hoặc code
- Trước khi xóa bất kỳ thứ gì, AI **phải** nói rõ:  
  _"Tôi sẽ xóa `[tên file/đoạn code]` vì `[lý do cụ thể]`"_
- Đợi xác nhận từ người dùng trước khi thực hiện.
- **Không bao giờ tự xóa**, dù lý do có vẻ hiển nhiên.

### 2. Không override Odoo core
- Không sửa thẳng vào source Odoo.
- Luôn dùng `_inherit` hoặc `inherit` để mở rộng.
- Nếu cần thay đổi hành vi core, phải thảo luận trước.

### 3. Không thay đổi database ngoài ORM
- Không chạy `DROP TABLE`, `ALTER TABLE`, hay raw SQL migration tùy tiện.
- Mọi thay đổi schema phải đi qua Odoo ORM và migration chính thức.
- Script migration phải được review trước khi chạy.

---

## 🐍 Chuẩn code Python / Odoo 19

### Khai báo model
```python
class HrEmployeeExtend(models.Model):
    _name = 'hr.employee.extend'          # bắt buộc
    _description = 'HR Employee Extended'  # bắt buộc
    _inherit = 'hr.employee'              # kế thừa đúng chuẩn
```

### Type hints
- Dùng Python 3.10+ syntax: `str | None`, `list[int]`, `dict[str, Any]`
- Không dùng `Optional`, `List`, `Dict` từ `typing` nếu tránh được.

```python
# ✅ đúng
def get_employee(self, emp_id: int) -> dict[str, str] | None:
    ...

# ❌ tránh
from typing import Optional, Dict
def get_employee(self, emp_id: int) -> Optional[Dict[str, str]]:
    ...
```

### Decorator đúng mục đích

| Decorator | Dùng khi |
|-----------|----------|
| `@api.model` | method không phụ thuộc record cụ thể |
| `@api.depends(...)` | compute field |
| `@api.onchange(...)` | phản ứng thay đổi trên form |
| `@api.constrains(...)` | validate dữ liệu |

### Thứ tự tổ chức file Python
```
imports
→ constants / config
→ class declaration
  → _name, _description, _inherit, _order
  → fields
  → SQL constraints
  → compute / inverse methods  (@api.depends)
  → onchange methods           (@api.onchange)
  → constraint methods         (@api.constrains)
  → CRUD overrides             (create, write, unlink)
  → business logic (public)
  → helper methods (private, đặt tên _method)
```

---

## 📁 Chuẩn cấu trúc module

```
hrm_custom/
├── __init__.py
├── __manifest__.py          ← luôn cập nhật khi thêm file
├── models/
│   ├── __init__.py
│   ├── hr_employee.py
│   └── hr_leave.py
├── views/
│   ├── hr_employee_views.xml
│   └── hr_leave_views.xml
├── security/
│   ├── ir.model.access.csv  ← bắt buộc có cho mọi model mới
│   └── hr_security.xml
├── data/
│   └── hr_data.xml
├── wizard/
│   └── __init__.py
├── report/
│   └── __init__.py
└── static/
    └── description/
        └── icon.png
```

### Quy tắc `__manifest__.py`
- Cập nhật `depends`, `data`, `assets` **ngay khi** thêm file mới.
- Không để sót file chưa được khai báo.

### Quy tắc đặt tên XML id
```xml
<!-- pattern: module_name.model_action_type -->
<record id="hrm_custom.hr_employee_form_view" model="ir.ui.view">
<record id="hrm_custom.hr_employee_tree_view" model="ir.ui.view">
<record id="hrm_custom.hr_employee_action" model="ir.actions.act_window">
<menuitem id="hrm_custom.menu_hr_employee" ...>
```

### Tách feature lớn
Mỗi tính năng lớn (payroll, leave, attendance, recruitment…) phải tách file model riêng trong `models/`, không nhồi vào một file duy nhất.

---

## 🔐 Security & ACL

- Mọi model mới **bắt buộc** có record trong `security/ir.model.access.csv`.
- Không để model trần không có ACL — Odoo sẽ báo lỗi khi deploy.

```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_hr_employee_extend,hr.employee.extend,model_hr_employee_extend,base.group_user,1,0,0,0
```

- Group permission phải rõ ràng: User / Manager / Admin phân quyền tách biệt.

---

## 🤖 Quy tắc AI khi vibe coding

### Trước khi code bất kỳ task nào
AI phải liệt kê rõ:
```
📋 File sẽ TẠO: [danh sách]
✏️  File sẽ SỬA: [danh sách]
❌  File sẽ XÓA: [danh sách + lý do] → đợi xác nhận
```
Sau đó mới bắt đầu code. Không code "chui" vào file không được nhắc.

### Khi không chắc
- Hỏi lại ngắn gọn, 1 câu, rõ ràng.
- Không tự đoán rồi code. Không "assume" requirement.

### Khi fix bug
1. Giải thích nguyên nhân gốc rễ (root cause).
2. Đề xuất cách fix và trade-off nếu có.
3. Chỉnh code sau khi được xác nhận hướng fix.

### Khi refactor
- Không refactor ngoài scope được yêu cầu.
- Nếu thấy code cũ có vấn đề, **báo cáo** — không tự ý sửa.

---

## 📝 Chất lượng & logging

### Docstring
Mọi method phức tạp (business logic, compute nặng) phải có docstring:
```python
def compute_remaining_leave(self) -> None:
    """
    Tính số ngày phép còn lại của nhân viên.

    Input:  self (recordset hr.employee)
    Output: ghi vào field remaining_leave_days
    Side effects: không có
    """
```

### Logging
```python
# ✅ đúng
_logger = logging.getLogger(__name__)
_logger.info("Leave approved for employee %s", employee.name)
_logger.warning("Leave balance low for %s", employee.name)
_logger.error("Failed to compute payslip: %s", str(e))

# ❌ không được commit
print("debug here")
_logger.debug("spam log mọi bước")
```

### Không để lại
- `print()` trong code production
- `TODO` / `FIXME` không có issue/ticket đi kèm
- Code bị comment out dài hạn — xóa hoặc ghi rõ lý do giữ lại

---

## ✅ Checklist trước khi commit

```
[ ] Không có print() hay debug log spam
[ ] Mọi model mới có ACL trong ir.model.access.csv
[ ] __manifest__.py đã cập nhật đủ file
[ ] XML id đặt tên đúng pattern
[ ] Không sửa thẳng Odoo core
[ ] Type hints Python 3.10+ đã dùng
[ ] Method phức tạp có docstring
[ ] Không tự xóa file nào mà chưa xác nhận
```

---

> _Rules này có hiệu lực từ đầu đến cuối project. Mọi thay đổi rules phải được hai bên đồng ý bằng văn bản (hoặc message) trước khi áp dụng._
