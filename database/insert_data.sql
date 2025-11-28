USE AIFinance;
GO
--Add data into NguoiDung table
INSERT INTO NguoiDung (MaNguoiDung, HoTen, Email, MatKhau, VaiTro, TrangThai, NgayTao)
VALUES 
('USER01', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '123456', 'User', 1, GETDATE()),
('ADMIN01', N'Trần Thị Quản Trị', 'admin@finance.ai', 'admin_pass', 'Admin', 1, GETDATE()),
('USER02', N'Lê Thị C', 'lethic@gmail.com', 'password789', 'User', 1, GETDATE()),
('USER03', N'Phạm Văn Nhật Trường', 'truongphamnhat2004@gmail.com', '280904', 'User', 1, GETDATE());
GO
--Add data into NguonTien table
INSERT INTO NguonTien (MaNguonTien, MaNguoiDung, TenNguonTien, LoaiNguonTien, SoDu, NgayTao)
VALUES 
('WI01', 'USER01', N'Ví tiền mặt', 'TienMat', 5000000, GETDATE()),
('WI02', 'USER01', N'Tài khoản TCB', 'NganHang', 25500000, GETDATE()),
('WI03', 'USER01', N'Ví MoMo', 'Momo', 1200000, GETDATE()),
('WI04', 'USER01', N'Visa Credit', 'TinDung', -1500000, GETDATE()),
('WI05', 'USER03', N'Ví tiền mặt', 'TienMat', 5000000, GETDATE()),
('WI06', 'USER03', N'Tài khoản TCB', 'NganHang', 25500000, GETDATE()),
('WI07', 'USER03', N'Ví MoMo', 'Momo', 1200000, GETDATE()),
('WI08', 'USER03', N'Visa Credit', 'TinDung', -1500000, GETDATE());
GO
--add data into NganSach table 
INSERT INTO NganSach (MaNganSach, MaNguoiDung, TenNganSach, SoTienGioiHan, NgayBatDau, NgayKetThuc)
VALUES 
('NS01', 'USER01', N'Ăn uống', 4000000, GETDATE(), DATEADD(day, 30, GETDATE())),
('NS02', 'USER01', N'Mua sắm', 3000000, GETDATE(), DATEADD(day, 30, GETDATE())),
('NS03', 'USER01', N'Giải trí', 1500000, GETDATE(), DATEADD(day, 30, GETDATE())),
('NS04', 'USER03', N'Ăn uống', 4000000, GETDATE(), DATEADD(day, 30, GETDATE())),
('NS05', 'USER03', N'Mua sắm', 3000000, GETDATE(), DATEADD(day, 30, GETDATE())),
('NS06', 'USER03', N'Giải trí', 1500000, GETDATE(), DATEADD(day, 30, GETDATE()));
GO
DELETE FROM GiaoDich WHERE MaNguoiDung = 'USER03';

-- 2. Đảm bảo USER03 và Nguồn tiền đã tồn tại (để tránh lỗi khóa ngoại)
-- (Nếu bạn chưa có USER03 hoặc WI05... thì đoạn này sẽ tự tạo giúp bạn)
IF NOT EXISTS (SELECT * FROM NguoiDung WHERE MaNguoiDung = 'USER03')
BEGIN
    INSERT INTO NguoiDung (MaNguoiDung, HoTen, Email, MatKhau, VaiTro)
    VALUES ('USER03', N'Người dùng Test', 'user3@test.com', '123', 'User');
END

-- Tạo nhanh nguồn tiền ảo nếu chưa có (để tránh lỗi Foreign Key)
IF NOT EXISTS (SELECT * FROM NguonTien WHERE MaNguonTien = 'WI05')
    INSERT INTO NguonTien (MaNguonTien, MaNguoiDung, TenNguonTien) VALUES ('WI05', 'USER03', 'Ví ảo 1');
IF NOT EXISTS (SELECT * FROM NguonTien WHERE MaNguonTien = 'WI06')
    INSERT INTO NguonTien (MaNguonTien, MaNguoiDung, TenNguonTien) VALUES ('WI06', 'USER03', 'Ví ảo 2');
IF NOT EXISTS (SELECT * FROM NguonTien WHERE MaNguonTien = 'WI07')
    INSERT INTO NguonTien (MaNguonTien, MaNguoiDung, TenNguonTien) VALUES ('WI07', 'USER03', 'Ví ảo 3');
IF NOT EXISTS (SELECT * FROM NguonTien WHERE MaNguonTien = 'WI08')
    INSERT INTO NguonTien (MaNguonTien, MaNguoiDung, TenNguonTien) VALUES ('WI08', 'USER03', 'Ví ảo 4');


-- 3. Thêm dữ liệu mới (INSERT)
INSERT INTO GiaoDich (MaGiaoDich, MaNguoiDung, MaNguonTien, LoaiGiaoDich, SoTien, MoTa, NgayGiaoDich)
VALUES 
('GD01', 'USER03', 'WI05', 'Thu', 15000000, N'Lương tháng 10', GETDATE()),
('GD02', 'USER03', 'WI05', 'Chi', 3000000, N'Tiền nhà', GETDATE()),

('GD03', 'USER03', 'WI06', 'Thu', 15000000, N'Lương tháng 11', DATEADD(month, -1, GETDATE())),
('GD04', 'USER03', 'WI06', 'Chi', 4500000, N'Mua sắm Black Friday', DATEADD(month, -1, GETDATE())),
('GD05', 'USER03', 'WI07', 'Chi', 2000000, N'Ăn uống', DATEADD(month, -1, GETDATE())),

('GD06', 'USER03', 'WI07', 'Thu', 20000000, N'Lương + Thưởng', DATEADD(month, -2, GETDATE())),
('GD07', 'USER03', 'WI08', 'Chi', 5000000, N'Đi du lịch', DATEADD(month, -2, GETDATE())),
('GD08', 'USER03', 'WI08', 'Chi', 1500000, N'Đổ xăng, cafe', DATEADD(month, -2, GETDATE()));
GO
GO

