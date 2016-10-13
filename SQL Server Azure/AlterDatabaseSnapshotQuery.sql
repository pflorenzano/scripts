
EXEC sp_who

-- You must stop the thinstance before running this command.  Below is the following procedure to do just that:

-- 1) Stop the thinstance by going to the https://10.255.4.77:8443/TOC/operations/landing.xhtml webpage
-- 2) Execute the ALTER DATABASE script below
-- 3) Restart the thinstance by going to the https://10.255.4.77:8443/TOC/operations/landing.xhtml webpage

USE master;
GO
ALTER DATABASE [dca0-onedevtiny12-services] SET SINGLE_USER WITH NO_WAIT;
GO
ALTER DATABASE [dca0-onedevtiny12-services] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [dca0-onedevtiny12-services] SET MULTI_USER WITH NO_WAIT;
GO


SELECT is_read_committed_snapshot_on FROM
sys.databases WHERE name = 'dca0-onedevtiny12-services'