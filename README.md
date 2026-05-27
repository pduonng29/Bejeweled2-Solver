# Bejeweled2-Solver

## 1. Giới thiệu đề tài

Đây là bài tập lớn môn Cấu trúc dữ liệu và Giải thuật với đề tài xây dựng chương trình giải puzzle cho game Bejeweled 2 Deluxe.

Chương trình nhận đầu vào là file `.bpz`, đọc dữ liệu màn chơi, mô phỏng luật của game, tìm chuỗi nước đi hợp lệ và tạo file `.sol` để game sử dụng thông qua chức năng Hint.

## 2. Mục tiêu

- Đọc đúng file puzzle `.bpz`.
- Chuyển dữ liệu `.bpz` thành board 8x8.
- Sinh các nước đi hợp lệ theo luật Bejeweled 2.
- Mô phỏng swap, match, clear, gravity và chain reaction.
- Tìm lời giải để xóa toàn bộ board.
- Ghi file `.sol` để game chính sử dụng.
- Tối ưu thuật toán nhằm hạn chế tràn RAM và crash game.

## 3. Công nghệ sử dụng

- GameMaker Studio 2
- GML Script
- Bejeweled 2 Deluxe
- GitHub

## 4. Thuật toán sử dụng

Chương trình sử dụng kết hợp nhiều chiến lược tìm kiếm:

- Greedy Search
- Beam Search
- Exact Priority Search
- Tail Solver
- Heuristic Search
- Visited Set để tránh lặp trạng thái

## 5. Cấu trúc thư mục

```text
source/
└── Bejeweled_2_Solution/
    ├── Bejeweled_2_Puzzle.yyp
    ├── scripts/
    ├── objects/
    ├── rooms/
    └── options/

docs/
├── report/
└── images/

test_data/
├── Nhom4_40lvls/
└── Game_80lvls_sample/

## 6. Cách chạy chương trình
- Mở GameMaker Studio 2.
- Mở file project:
- source/Bejeweled_2_Solution/Bejeweled_2_Puzzle.yyp
- Kiểm tra đường dẫn file .bpz trong chương trình.
- Chạy project trong GameMaker.
- Nếu tìm được lời giải hợp lệ, chương trình sẽ tạo file .sol cùng tên với file .bpz.
- Mở Bejeweled 2 Deluxe và dùng chức năng Hint để kiểm tra lời giải.

## 7. Một số lỗi đã xử lý
- Đọc sai định dạng file .bpz.
- Nhầm định dạng .bpz cố định 64 byte với định dạng biến độ dài.
- Sai luật swap với ô trống và rock.
- Sai hướng swap khi ghi file .sol.
- Solver đi vào nhánh chết ở cuối game.
- Tràn RAM do sinh quá nhiều trạng thái.
- Crash GameMaker do log và frontier quá lớn.

## 8. Thành viên nhóm
- Nguyễn Xuân Sáng
- Phạm Thùy Dương
- Trần Thúy Quỳnh

## 9. Ghi chú
- Project chỉ sử dụng file .bpz làm đầu vào. File .sol được chương trình tự tạo sau khi verify lời giải.