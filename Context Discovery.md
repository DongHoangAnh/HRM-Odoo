# Context Discovery — HRM Odoo 19

## 1. Bối cảnh dự án

Dự án dành cho công ty giáo dục, tập trung riêng vào phần Nhân sự trên Odoo 19.

Scope đã chốt chỉ gồm 5 module:

- Nhân viên
- Chấm công
- Nghỉ phép
- Bảng lương
- Tuyển dụng

Mọi phần ngoài cột Nhân sự trong sơ đồ tổng quan hệ thống đều là Out of Scope với team này.

## 2. Bức tranh toàn cảnh

Công ty có 4 bộ phận chính:

| Bộ phận | Việc chính | Liên quan đến HR |
|---|---|---|
| Nhân sự | Quản lý hồ sơ, công, lương, thưởng | Đây là scope |
| Kinh doanh | Tư vấn, chăm sóc khách hàng, data học viên | Cần biết cơ cấu phòng ban để tạo nhân viên đúng |
| Vận hành & SP | Xếp lớp, giảng dạy, LMS | Giáo viên / trợ giảng là nhân viên nên cần quản lý công và lương |
| Tài chính | Duyệt chi, báo cáo tài chính | Nhận output lương từ HR để thanh toán |

Điểm đặc thù của dự án là nhân viên bao gồm cả giáo viên và trợ giảng. Nhóm này có thể có cơ cấu lương riêng, ví dụ tính theo giờ dạy hoặc theo lớp, khác với nhân viên văn phòng.

## 3. Vấn đề thực sự đọc từ sơ đồ

### 3.1 Dữ liệu đầu vào

HR đang nhận dữ liệu theo 2 cách thủ công:

- Nhân sự điền form thông tin cá nhân nhưng dữ liệu không tự vào hệ thống, cần người nhập lại.
- Nhân sự chấm công hàng ngày nhưng cơ chế hiện tại chưa rõ, có thể vẫn thủ công hoặc thiếu tự động hóa.
- Giáo viên và trợ giảng vừa là nhân viên vừa phục vụ vận hành lớp học, nên dữ liệu bị phân mảnh giữa HR và bộ phận Vận hành.

### 3.2 Vận hành

Ba việc đang làm thủ công song song:

- Quản lý hồ sơ nhân sự online nhưng chưa rõ đang ở đâu, có thể là Excel hoặc tool riêng.
- Theo dõi thăng tiến, lương, hợp đồng, kỳ hạn nhưng chưa có cảnh báo khi gần đến hạn.
- Theo dõi công chưa được kết nối với tính lương.

### 3.3 Báo cáo đầu ra

Sơ đồ liệt kê 3 nhóm báo cáo HR cần có:

- Chuyển cần
- Lương thưởng
- Quản lý cơ sở vật chất

Mục “Quản lý cơ sở vật chất” cần được làm rõ xem có thuộc scope HR hay không.

## 4. Từ điển dự án

### 4.1 Nhân viên

| Term | Định nghĩa trong dự án | Odoo model | Alias |
|---|---|---|---|
| Nhân viên văn phòng | Kinh doanh, Marketing, Vận hành, Tài chính, HR | hr.employee | Staff |
| Giáo viên | Người giảng dạy, full-time hoặc part-time | hr.employee | Teacher |
| Trợ giảng | Hỗ trợ giáo viên trong lớp, có thể là nhân viên hoặc cộng tác viên | hr.employee | TA |
| Hợp đồng | Văn bản pháp lý xác định lương và thời hạn | hr.contract | HĐLĐ |
| Phòng ban | Nhân sự / Kinh doanh / Vận hành & SP / Tài chính | hr.department | Department |
| Chức vụ | Tư vấn viên / Giáo viên / Trợ giảng / Kế toán… | hr.job | Job position |
| Thăng tiến | Thay đổi chức vụ / lương / phòng ban, cần lưu lịch sử | hr.contract mới | Promotion |
| Kỳ hạn hợp đồng | Ngày hết hạn hợp đồng, phải cảnh báo trước N ngày | date_end | Contract expiry |
| Thử việc | Giai đoạn đầu trước hợp đồng chính thức | hr.contract type | Probation |

### 4.2 Chấm công

| Term | Định nghĩa | Odoo model | Alias |
|---|---|---|---|
| Check-in / Check-out | Giờ vào / giờ ra thực tế | hr.attendance | Vào ca / Ra ca |
| Ca làm việc | Lịch giờ làm tiêu chuẩn | resource.calendar | Work schedule |
| Ngày công | Số ngày làm thực tế trong kỳ | computed | Working days |
| OT | Giờ làm vượt ca tiêu chuẩn | computed | Tăng ca |
| Giờ dạy | Số giờ giảng dạy thực tế của giáo viên / trợ giảng | custom | Teaching hours |
| Chuyển cần | Thuyên chuyển nhân viên giữa phòng ban / cơ sở | custom field | Transfer |

### 4.3 Nghỉ phép

| Term | Định nghĩa | Odoo model | Alias |
|---|---|---|---|
| Loại phép | Phép năm / Phép ốm / Phép không lương / Thai sản | hr.leave.type | Leave type |
| Allocation | Số ngày phép được cấp | hr.leave.allocation | Cấp phép |
| Đơn nghỉ phép | Yêu cầu nghỉ cụ thể | hr.leave | Leave request |
| Số dư phép | Allocation trừ ngày đã dùng | computed | Balance |
| Luồng duyệt | NV xin → Quản lý duyệt → HR xác nhận | workflow | Approval flow |

### 4.4 Bảng lương

| Term | Định nghĩa | Odoo model | Alias |
|---|---|---|---|
| Kỳ lương | Chu kỳ tính lương 1 tháng | hr.payslip.run | Payroll period |
| Phiếu lương | Bảng tính của 1 nhân viên trong 1 kỳ | hr.payslip | Payslip |
| Cơ cấu lương văn phòng | Công thức cho nhân viên văn phòng | hr.payroll.structure | Office structure |
| Cơ cấu lương GV | Công thức riêng cho giáo viên, có thể tính theo giờ dạy | hr.payroll.structure | Teacher structure |
| Lương thưởng | Thưởng định kỳ / KPI / tháng 13 | hr.salary.rule | Bonus |
| Gross / Net | Trước / sau khấu trừ | computed | — |
| BHXH / BHYT / BHTN | Bảo hiểm theo luật Việt Nam | hr.salary.rule | Social insurance |
| Thuế TNCN | Lũy tiến 7 bậc | hr.salary.rule | PIT |
| Phụ cấp | Xăng, ăn, điện thoại… | hr.salary.rule | Allowance |

### 4.5 Tuyển dụng

| Term | Định nghĩa | Odoo model | Alias |
|---|---|---|---|
| Vị trí tuyển | Job đang cần tuyển | hr.job | Job position |
| Ứng viên | Người nộp đơn | hr.applicant | Applicant |
| Pipeline tuyển dụng | Luồng từ nộp đơn → offer → nhận việc | hr.recruitment.stage | Pipeline |
| Stage | Mới nộp → Sàng lọc → Phỏng vấn → Offer → Onboard | stage | Giai đoạn |
| Kênh tuyển | LinkedIn / Website / Giới thiệu nội bộ / Headhunt | utm.source | Source |
| Offer | Đề nghị việc làm chính thức | custom | Offer letter |

## 5. Constraints không thể thay đổi

### 5.1 Kỹ thuật

- Nền tảng: Odoo 19
- Đã có license
- Python 3.10 – 3.14
- Server đã setup
- Không sửa Odoo core
- Tự phát triển custom modules riêng, triển khai trên database online riêng
- IDE: VSCode

### 5.2 Nghiệp vụ đặc thù công ty giáo dục

- Giáo viên vừa là nhân viên, nên không tạo model riêng, dùng hr.employee với job position = Giáo viên.
- Cơ cấu lương giáo viên có thể khác, nên tách hr.payroll.structure riêng khi cần.
- Dữ liệu giáo viên và trợ giảng cũng thuộc Vận hành, nhưng HR là nguồn sự thật duy nhất cho hồ sơ nhân viên.
- Tài chính nhận output lương từ HR, nên định dạng xuất file phải thống nhất trước.

### 5.3 Pháp lý Việt Nam

- Bộ luật Lao động 2019
- BHXH / BHYT / BHTN phải cấu hình được, không hardcode
- Thuế TNCN 7 bậc
- Giảm trừ gia cảnh: 11tr cho bản thân + 4.4tr/người phụ thuộc
- Lưu hồ sơ 10 năm, chỉ archive, không xóa

## 6. Custom Development Rules

### 6.1 Cách tổ chức module

- Mỗi nghiệp vụ lớn tách thành một custom module riêng.
- Giữ module mỏng, chỉ chứa đúng nghiệp vụ của phần đó.
- Ưu tiên tách model, view, security, data rõ ràng theo chuẩn Odoo.
- Không gom nhiều nghiệp vụ khác nhau vào một module nếu có thể tách sạch được.

### 6.2 Naming convention

- Tên module dùng tiền tố thống nhất, ví dụ `hrm_...`.
- Tên model custom dùng pattern rõ nghĩa, bám domain giáo dục và HR.
- XML id phải nhất quán, dễ đọc, dễ grep, tránh tên chung chung.
- Field custom nên mô tả đúng nghiệp vụ, không đặt tên mơ hồ hoặc viết tắt khó hiểu.

### 6.3 Ưu tiên triển khai

1. Dữ liệu nền tảng: nhân viên, phòng ban, chức vụ, hợp đồng.
2. Chấm công và các dữ liệu đầu vào để tính công / giờ dạy.
3. Nghỉ phép và quy trình duyệt.
4. Bảng lương và cấu trúc lương riêng cho giáo viên / trợ giảng.
5. Tuyển dụng và onboarding.
6. Báo cáo và các phần tích hợp với Tài chính / Vận hành.

### 6.4 Nguyên tắc triển khai

- Luôn phát triển trên database online riêng.
- Không sửa Odoo core.
- Ưu tiên làm phần có dữ liệu thật và luồng chốt trước, sau đó mới mở rộng.
- Nếu có điểm chưa rõ về nghiệp vụ, chốt bằng câu hỏi trước khi code.

## 7. Open Questions cần hỏi trước khi code

### 7.1 Ưu tiên cao

- Giáo viên và trợ giảng lương tính theo tháng cố định hay theo giờ dạy thực tế?
- Công ty có nhiều cơ sở hoặc chi nhánh không?
- Hiện đang chấm công bằng thiết bị hay cách gì, có tích hợp được không?
- Team Tài chính cần HR xuất file định dạng gì để thanh toán lương?

### 7.2 Nhân viên

- Quản lý hồ sơ nhân sự online hiện đang dùng tool gì, có cần migrate dữ liệu cũ không?
- Cảnh báo hết hạn hợp đồng cần báo trước bao nhiêu ngày, báo cho ai?
- “Chuyển cần” trong báo cáo là quy trình thuyên chuyển nội bộ thế nào?
- Có nhân viên part-time, đặc biệt là giáo viên dạy bán thời gian, không?
- Nhân viên part-time có hợp đồng không?

### 7.3 Chấm công

- Giáo viên và trợ giảng có ca làm việc cố định hay thay đổi theo lịch lớp học?
- “Theo dõi công” hiện đang track bằng Excel hay công cụ gì?
- OT áp dụng cho tất cả nhân viên hay chỉ nhân viên văn phòng?

### 7.4 Bảng lương

- Hiện có bao nhiêu loại cơ cấu lương đang áp dụng?
- Phụ cấp nào tính BHXH, phụ cấp nào không?
- “Lương thưởng” trong báo cáo có vào phiếu lương hay trả ngoài?
- Nhân viên đã đăng ký người phụ thuộc giảm trừ thuế chưa?

### 7.5 Tuyển dụng

- Pipeline tuyển dụng hiện tại có bao nhiêu stage, ai duyệt ở mỗi stage?
- Khi ứng viên nhận offer thì có tự động tạo nhân viên mới không?
- Tuyển dụng giáo viên có quy trình riêng như demo dạy hoặc test nghiệp vụ không?

### 7.6 Báo cáo

- “Quản lý cơ sở vật chất” là tài sản cấp cho nhân viên hay cơ sở hạ tầng văn phòng?
- Báo cáo lương thưởng cần theo kỳ nào: tháng, quý hay năm?
- Báo cáo “Chuyển cần” cần hiển thị thông tin gì cụ thể?

## 8. Điểm tích hợp với các bộ phận khác

| Từ / Đến | Dữ liệu trao đổi | Chiều | Ai làm chủ dữ liệu |
|---|---|---|---|
| HR → Tài chính | Output bảng lương để thanh toán | Một chiều | HR |
| HR → Vận hành | Danh sách giáo viên / trợ giảng, hợp đồng, trạng thái | Một chiều | HR |
| Vận hành → HR | Giờ dạy thực tế của giáo viên nếu tính lương theo giờ | Một chiều | Vận hành |
| HR ← Tài chính | Phiếu đề xuất chi từ Lark | Tham khảo | Tài chính |

## 9. Assumptions đã chốt

| # | Assumption | Người xác nhận | Ngày |
|---|---|---|---|
| 1 | Luật lao động áp dụng: Việt Nam | — | — |
| 2 | Giao diện chính: Tiếng Việt | — | — |
| 3 | Tính lương theo tháng | — | — |
| 4 | Scope: 5 module — Nhân viên, Chấm công, Nghỉ phép, Bảng lương, Tuyển dụng | — | — |
| 5 | Giáo viên / Trợ giảng quản lý trong hr.employee, không tạo model riêng | — | — |
| 6 | HR là nguồn sự thật duy nhất cho hồ sơ nhân viên, kể cả GV / Trợ giảng | — | — |
| 7 | Custom development sẽ chạy trên database online riêng | — | — |

## 10. Out of Scope

| Tính năng | Thuộc bộ phận |
|---|---|
| Quản lý học viên, lớp học, LMS | Vận hành & SP |
| Data kinh doanh, Pancake CRM | Kinh doanh |
| Báo cáo tài chính, dòng tiền | Tài chính |
| Đánh giá chất lượng giảng dạy | Vận hành & SP |
| Tích hợp Lark để xử lý phiếu đề xuất chi | Tài chính |
| Mobile app riêng | Dùng Odoo mobile mặc định |

## 11. Kết luận

Tài liệu này là mốc tham chiếu cho phần HR của dự án. Khi bắt đầu code, mọi thiết kế phải bám đúng scope 5 module, giữ giáo viên và trợ giảng trong hr.employee, và xác nhận các open questions có ảnh hưởng đến kiến trúc trước khi triển khai.