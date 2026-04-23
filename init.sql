-- Tạo Database cho Hệ thống Rạp Chiếu Phim
CREATE DATABASE CineplexDB;
GO

USE CineplexDB;
GO

-- Bảng quản lý doanh thu tập trung của các chi nhánh rạp
CREATE TABLE BranchRevenue (
                               BranchID INT PRIMARY KEY,
                               BranchName NVARCHAR(100),      -- Tên chi nhánh (Ví dụ: Master Hà Nội, Branch TP.HCM)
                               TotalRevenue DECIMAL(18,2),    -- Tổng doanh thu
                               Currency NVARCHAR(10),         -- Đơn vị tiền (VNĐ)
                               LastUpdated DATETIME DEFAULT GETDATE(),
                               Status NVARCHAR(50)            -- Trạng thái (Online, Tạm đóng cửa...)
);
GO

-- Khởi tạo dữ liệu mẫu cho 6 chi nhánh (tương ứng 6 Node của hệ thống)
INSERT INTO BranchRevenue (BranchID, BranchName, TotalRevenue, Currency, Status) VALUES
                                                                                     (1, N'Rạp 1 - Master (Hà Nội)', 500000000.00, N'VNĐ', N'Online'),
                                                                                     (2, N'Rạp 2 - Branch (TP.HCM)', 450000000.00, N'VNĐ', N'Online'),
                                                                                     (3, N'Rạp 3 - Branch (Đà Nẵng)', 200000000.00, N'VNĐ', N'Online'),
                                                                                     (4, N'Rạp 4 - Branch (Hải Phòng)', 150000000.00, N'VNĐ', N'Maintenance'),
                                                                                     (5, N'Rạp 5 - Branch (Cần Thơ)', 120000000.00, N'VNĐ', N'Online'),
                                                                                     (6, N'Rạp 6 - Backup (Nha Trang)', 80000000.00, N'VNĐ', N'Online');
GO

-- Xem thử thành quả
SELECT * FROM BranchRevenue;
GO