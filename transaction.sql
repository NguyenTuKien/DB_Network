-- 1. Đảm bảo nếu có lỗi mạng thì hủy bỏ toàn bộ giao dịch ngay lập tức
SET XACT_ABORT ON;
GO

USE CineplexDB;
GO

-- ==========================================
-- XEM TRẠNG THÁI TRƯỚC KHI CHUYỂN TIỀN
-- ==========================================
PRINT N'--- TRẠNG THÁI DOANH THU TRƯỚC KHI ĐIỀU CHUYỂN ---';
SELECT
    'MASTER (HN)' AS ViTri, BranchID, BranchName, TotalRevenue, Currency
FROM dbo.BranchRevenue WHERE BranchID = 1
UNION ALL
SELECT
    'BRANCH (HCM)', BranchID, BranchName, TotalRevenue, Currency
FROM [BRANCH_NODE_LINK].CineplexDB.dbo.BranchRevenue WHERE BranchID = 2;
GO

-- ==========================================
-- THỰC THI GIAO DỊCH (TRANSACTION)
-- ==========================================
BEGIN TRY
    -- Bắt đầu giao dịch: "Một mất một còn"
    BEGIN TRANSACTION;

    -- Số tiền rạp TP.HCM nộp về cho Hà Nội
    DECLARE @Amount DECIMAL(18,2) = 50000000.00; -- 50 Triệu VNĐ

    -- BƯỚC 1: TRỪ tiền tại máy Chi nhánh (Remote Update)
    -- Nếu bước này lỗi (ví dụ: rớt mạng Tailscale), nó sẽ nhảy xuống CATCH ngay
    UPDATE [BRANCH_NODE_LINK].CineplexDB.dbo.BranchRevenue
    SET TotalRevenue = TotalRevenue - @Amount,
        LastUpdated = GETDATE()
    WHERE BranchID = 2;

    -- BƯỚC 2: CỘNG tiền tại máy Master (Local Update)
    UPDATE dbo.BranchRevenue
    SET TotalRevenue = TotalRevenue + @Amount,
        LastUpdated = GETDATE()
    WHERE BranchID = 1;

    -- BƯỚC 3: Nếu cả 2 lệnh trên đều OK, xác nhận chốt sổ
    COMMIT TRANSACTION;

    PRINT N'GIAO TÁC THÀNH CÔNG! Đã chuyển 50 Triệu từ TP.HCM về Hà Nội.';
END TRY
BEGIN CATCH
    -- Nếu có bất kỳ lỗi nào (Lỗi code, lỗi mạng, lỗi logic), hoàn tác toàn bộ
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'XẢY RA LỖI - HỆ THỐNG ĐÃ HOÀN TÁC (ROLLBACK) ĐỂ BẢO VỆ TIỀN!';
    PRINT N'Chi tiết lỗi: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==========================================
-- XEM TRẠNG THÁI SAU KHI CHUYỂN TIỀN
-- ==========================================
PRINT N'--- TRẠNG THÁI DOANH THU SAU KHI ĐIỀU CHUYỂN ---';
SELECT
    'MASTER (HN)' AS ViTri, BranchID, BranchName, TotalRevenue, Currency
FROM dbo.BranchRevenue WHERE BranchID = 1
UNION ALL
SELECT
    'BRANCH (HCM)', BranchID, BranchName, TotalRevenue, Currency
FROM [BRANCH_NODE_LINK].CineplexDB.dbo.BranchRevenue WHERE BranchID = 2;
GO