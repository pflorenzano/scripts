

DECLARE @mailid int

EXECUTE [msdb].[dbo].[sp_send_dbmail]
     @profile_name		= 'BBT Database Mail',
 	 @recipients		= 'pflorenzano@buybooktech.com;mknox@buybooktech.com;7177564636@mms.att.net',
     @body			= 'Total Offers for CMW OfferCodes',
	 @subject		= 'Total Offers for CMW OfferCodes',
	 @execute_query_database = 'bbt_marketplace_main',
     @query = 'SELECT	B.Dealer_Dealershipname AS ''Dealership Name'',
									O.OfferCode					  AS ''Offer Code'',
									COUNT(*)						  AS ''Total CMW Offers''	
						FROM		aspnet_Membership M
							INNER JOIN	BBTShaft_Profile B ON B._UserID = M.UserId
							INNER JOIN	aspnet_UsersInRoles UR ON UR.UserId = M.UserId
							INNER JOIN	OfferAssignedDealer AD ON AD.DealerId = M.UserId
							INNER JOIN	Offer O ON O.OfferGuid = AD.OfferGuid
								WHERE O.OfferCode IN (''CMW'')
									AND O.DateCreated BETWEEN ''2014-08-26 07:00:00.000'' AND ''2014-08-26 23:59:59.000''
						GROUP BY B.Dealer_Dealershipname,
										O.OfferCode
						ORDER BY O.OfferCode ASC',
     @mailitem_id = @mailid OUTPUT

SELECT @mailid




