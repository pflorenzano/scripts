
-- Identifying the lead blockers

Select A.*

       From dbo.sysprocesses as A with (nolock)

       Where A.blocked <> 0

       And A.blocked <> A.spid

Select A.*

       From dbo.sysprocesses as A with (nolock)

       Where A.blocked = 0

       And A.spid in (Select B.blocked

                         From dbo.sysprocesses as B with (nolock)

                         Where B.blocked <> 0

                         And B.blocked <> B.spid)

