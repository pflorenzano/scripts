if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RuleDataRoutingComMarketException]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[RuleDataRoutingComMarketException]
GO

ALTER TABLE [dbo].[RuleDataRoutingComMarketException] ADD 
	CONSTRAINT [PK_RuleDataRoutingComMarketException] PRIMARY KEY  CLUSTERED 
	(
		[MarketGroupID],
		[MarketID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[RuleDataRoutingComMarketException] ADD 
	CONSTRAINT [FK_RuleDataRoutingComMarketException_RuleDataRouteLocation] FOREIGN KEY 
	(
		[LessThanRouteID]
	) REFERENCES [dbo].[RuleDataRouteLocation] (
		[ID]
	),
	CONSTRAINT [FK_RuleDataRoutingComMarketException_RuleDataRouteLocation1] FOREIGN KEY 
	(
		[GreaterEqualRouteID]
	) REFERENCES [dbo].[RuleDataRouteLocation] (
		[ID]
	),
	CONSTRAINT [FK_RuleDataRoutingComMarketException_RuleDataRouteLocation2] FOREIGN KEY 
	(
		[UndefinedOutDefaultRouteID]
	) REFERENCES [dbo].[RuleDataRouteLocation] (
		[ID]
	)
GO

