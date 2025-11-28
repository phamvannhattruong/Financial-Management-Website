USE AIFinance;
GO

INSERT INTO NguoiDung (MaNguoiDung, HoTen, Email, MatKhau, VaiTro, TrangThai, NgayTao)
VALUES 
-- Người dùng 1 (Khớp với code Python/JS cũ)
('USER01', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '123456', 'User', 1, GETDATE()),

-- Người dùng 2 (Thử vai trò Admin)
('ADMIN01', N'Trần Thị Quản Trị', 'admin@finance.ai', 'admin_pass', 'Admin', 1, GETDATE()),

-- Người dùng 3 (Người dùng mới)
('USER02', N'Lê Thị C', 'lethic@gmail.com', 'password789', 'User', 1, GETDATE());
GO

