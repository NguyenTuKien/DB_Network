USE master;
GO

-- 1. Xóa link cũ đang bị lỗi tên miền
IF EXISTS (SELECT srvname FROM sysservers WHERE srvname = 'BRANCH_NODE_LINK')
    EXEC sp_dropserver 'BRANCH_NODE_LINK', 'droplogins';
GO

-- 2. Tạo lại Link dùng chính xác IP Tailscale của máy Branch
EXEC sp_addlinkedserver
     @server     = N'BRANCH_NODE_LINK',
     @srvproduct = N'SqlServer',
     @provider   = N'MSOLEDBSQL',
     @datasrc    = N'100.75.76.66,1433';
GO

-- 3. Cấu hình đăng nhập
EXEC sp_addlinkedsrvlogin
     @rmtsrvname = N'BRANCH_NODE_LINK',
     @useself    = N'False',
     @locallogin = NULL,
     @rmtuser    = N'sa',
     @rmtpassword= N'KienPassword123!'; -- Nhớ đổi thành pass thật
GO

EXEC sp_serveroption 'BRANCH_NODE_LINK', 'rpc', 'true';
EXEC sp_serveroption 'BRANCH_NODE_LINK', 'rpc out', 'true';
EXEC sp_serveroption 'BRANCH_NODE_LINK', 'remote proc transaction promotion', 'true'; -- Tắt cái này để né lỗi timeout DTC!
GO