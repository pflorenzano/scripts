
SELECT v.*
   FROM BBTShaft_Profile v
    JOIN (SELECT v.vAutoID
				FROM BBTShaft_Profile v
			 GROUP BY v.vAutoID
			  HAVING COUNT(*) > 1) x ON x.vAutoID = v.vAutoID

SELECT v.vAutoID
  FROM BBTShaft_Profile v
   INNER JOIN [dbo].[aspnet_Membership] a ON a.UserID = v._UserID
    WHERE a.IsApproved = 1
GROUP BY v.vAutoID
  HAVING COUNT(*) > 1

SELECT TOP 10 *
 FROM BBTShaft_Profile