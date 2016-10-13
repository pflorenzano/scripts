
-- Returns the type of lock participating in the deadlock and the current command affect by the deadlock. 

DBCC TRACEOFF (1204)

-- Returns more detailed information about the command being executed at the time of a deadlock.  

DBCC TRACEOFF (1205)

-- Used to complement flag 1204 by displaying other locks held by deadlock parties 

DBCC TRACEOFF (1206)

-- Displays the status of (all) trace flags.

DBCC TRACESTATUS (-1)
