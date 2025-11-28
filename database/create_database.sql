-- 1. Tạo Database (Nếu chưa có)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AIFinance')
BEGIN
    CREATE DATABASE AIFinance;
END
GO

USE AIFinance;
GO

-- =============================================
-- 1. BẢNG NGƯỜI DÙNG (Bảng gốc)
-- =============================================
CREATE TABLE NguoiDung (
    MaNguoiDung VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    Email VARCHAR(120) NOT NULL UNIQUE,
    MatKhau VARCHAR(255) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    LanDangNhapCuoi DATETIME,
    VaiTro VARCHAR(20), -- Giả lập ENUM
    TrangThai TINYINT DEFAULT 1, -- 1: Active, 0: Locked
    
    -- Constraint giả lập ENUM cho Vai Trò
    CONSTRAINT CK_NguoiDung_VaiTro CHECK (VaiTro IN ('User', 'Admin', 'Mod'))
);
GO

-- =============================================
-- 2. CÁC BẢNG LIÊN QUAN 1-1 VỚI NGƯỜI DÙNG
-- =============================================

-- Bảng Thiết lập người dùng
CREATE TABLE ThietLapNguoiDung (
    MaNguoiDung VARCHAR(10) PRIMARY KEY,
    DonViTienTe VARCHAR(10) DEFAULT 'VND',
    NgonNgu VARCHAR(20) DEFAULT 'vi-VN',
    ThongBao TINYINT DEFAULT 1,
    AI_GoiY TINYINT DEFAULT 1,
    
    CONSTRAINT FK_ThietLap_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng Xác thực 2FA
CREATE TABLE XacThuc2FA (
    MaNguoiDung VARCHAR(10) PRIMARY KEY,
    SecretKey VARCHAR(100),
    DaKichHoat TINYINT DEFAULT 0,
    MaDuPhong NVARCHAR(MAX), -- Lưu các mã dự phòng (JSON hoặc text dài)
    
    CONSTRAINT FK_2FA_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng Reset Password (Token)
CREATE TABLE Password_Reset_Tokens (
    Email VARCHAR(120) PRIMARY KEY, -- Theo diagram lấy Email làm Key
    Token VARCHAR(255) NOT NULL,
    ThoiGianHetHan DATETIME NOT NULL,
    
    -- Liên kết logic với bảng NguoiDung qua Email
    CONSTRAINT FK_ResetToken_Email FOREIGN KEY (Email) REFERENCES NguoiDung(Email)
);
GO

-- =============================================
-- 3. CÁC BẢNG TÀI CHÍNH CỐT LÕI
-- =============================================

-- Bảng Nguồn Tiền (Ví)
CREATE TABLE NguonTien (
    MaNguonTien VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    TenNguonTien NVARCHAR(100) NOT NULL,
    LoaiNguonTien VARCHAR(50), -- Ví dụ: TienMat, NganHang, Momo
    SoDu DECIMAL(18, 2) DEFAULT 0,
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_NguonTien_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng Danh Mục (Có đệ quy cha-con)
CREATE TABLE DanhMuc (
    MaDanhMuc VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    TenDanhMuc NVARCHAR(100) NOT NULL,
    LoaiDanhMuc VARCHAR(20), -- Thu, Chi
    MaDanhMucCha VARCHAR(10), -- Tự tham chiếu chính nó
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DanhMuc_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    CONSTRAINT FK_DanhMuc_Cha FOREIGN KEY (MaDanhMucCha) REFERENCES DanhMuc(MaDanhMuc),
    CONSTRAINT CK_LoaiDanhMuc CHECK (LoaiDanhMuc IN ('Thu', 'Chi', 'ChoVay', 'DiVay'))
);
GO

-- =============================================
-- 4. BẢNG GIAO DỊCH (Quan trọng nhất)
-- =============================================
CREATE TABLE GiaoDich (
    MaGiaoDich VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    MaNguonTien VARCHAR(10) NOT NULL, -- Tiền đi ra từ đâu
    MaNguonTien_Dich VARCHAR(10),     -- Tiền đi đến đâu (cho giao dịch chuyển khoản), có thể NULL
    MaDanhMuc VARCHAR(10),
    LoaiGiaoDich VARCHAR(20),         -- Thu, Chi, ChuyenTien
    SoTien DECIMAL(18, 2) NOT NULL,
    MoTa NVARCHAR(MAX),
    NgayGiaoDich DATETIME DEFAULT GETDATE(),
    
    -- Phần AI dự đoán
    MaDanhMuc_AI VARCHAR(10),
    DoTinCay_AI FLOAT,
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_GiaoDich_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    CONSTRAINT FK_GiaoDich_NguonTien FOREIGN KEY (MaNguonTien) REFERENCES NguonTien(MaNguonTien),
    CONSTRAINT FK_GiaoDich_NguonTienDich FOREIGN KEY (MaNguonTien_Dich) REFERENCES NguonTien(MaNguonTien),
    CONSTRAINT FK_GiaoDich_DanhMuc FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc),
    CONSTRAINT CK_LoaiGiaoDich CHECK (LoaiGiaoDich IN ('Thu', 'Chi', 'ChuyenKhoan'))
);
GO

-- =============================================
-- 5. BẢNG NGÂN SÁCH
-- =============================================
CREATE TABLE NganSach (
    MaNganSach VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    TenNganSach NVARCHAR(100),
    SoTienGioiHan DECIMAL(18, 2),
    NgayBatDau DATE,
    NgayKetThuc DATE,
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_NganSach_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng trung gian Ngân Sách - Danh Mục (Quan hệ n-n)
CREATE TABLE NganSach_DanhMuc (
    MaNganSach VARCHAR(10),
    MaDanhMuc VARCHAR(10),

    PRIMARY KEY (MaNganSach, MaDanhMuc),
    CONSTRAINT FK_NSDM_NganSach FOREIGN KEY (MaNganSach) REFERENCES NganSach(MaNganSach),
    CONSTRAINT FK_NSDM_DanhMuc FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc)
);
GO

-- =============================================
-- 6. CÁC BẢNG LỊCH SỬ & AI
-- =============================================

-- Lịch sử Chatbot
CREATE TABLE ChatBot_LichSu (
    MaHoiThoai VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    NoiDungHoi NVARCHAR(MAX),
    NoiDungTraLoi NVARCHAR(MAX),
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_ChatBot_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Lịch sử AI dự đoán & Learning
CREATE TABLE AI_LichSu (
    MaAI_Log VARCHAR(10) PRIMARY KEY,
    MaNguoiDung VARCHAR(10) NOT NULL,
    MaGiaoDich VARCHAR(10),
    DanhMucDuDoan VARCHAR(10),   -- AI đoán là danh mục gì
    DanhMucChinhXac VARCHAR(10), -- Người dùng sửa lại là danh mục gì (Label)
    DoTinCay FLOAT,
    PhanHoi NVARCHAR(MAX),       -- Feedback text của user
    NgayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_AILog_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    CONSTRAINT FK_AILog_GiaoDich FOREIGN KEY (MaGiaoDich) REFERENCES GiaoDich(MaGiaoDich),
    CONSTRAINT FK_AILog_DMDuDoan FOREIGN KEY (DanhMucDuDoan) REFERENCES DanhMuc(MaDanhMuc),
    CONSTRAINT FK_AILog_DMChinhXac FOREIGN KEY (DanhMucChinhXac) REFERENCES DanhMuc(MaDanhMuc)
);
GO

