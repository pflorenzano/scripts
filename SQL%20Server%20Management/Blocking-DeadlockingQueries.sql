
-- Query #1

SELECT * FROM sys.dm_exec_sql_text(0x0200000084ae43040a073f1cfe63253a2bb0a48741f719800000000000000000000000000000000000000000) -- modify this value with your actual sql_handle

(@P0 bigint)delete from [TOUCHPOINT] where [ID]=@P0

-- Query #2   

SELECT * FROM sys.dm_exec_sql_text(0x020000004f58df261fc4c4fb8e03a3f43697e644d7a15ead0000000000000000000000000000000000000000) -- modify this value with your actual sql_handle

(@P0 bigint,@P1 datetime2,@P2 varchar(8000),@P3 int,@P4 bigint,@P5 bigint,@P6 bigint)update [PROFILE_ELEMENT] set LAST_MODIFIED_BY_ID=@P0, [LAST_MODIFIED_DATE]=@P1, [REASON_FOR_INCLUDE]=@P2, [POSITION]=@P3, PROFILE_ID=@P4, REFERENCED_NODE_ID=@P5 where [ID]=@P6  

-- Query #3

SELECT * FROM sys.dm_exec_sql_text(0x0200000025102c131835866f54a5d3f86198d538ef479b440000000000000000000000000000000000000000) -- modify this value with your actual sql_handle
   
(@P0 bigint)select interactio0_.[ID] as ID1_20_, interactio0_.CREATED_BY_ID as CREATED_9_20_, interactio0_.[CREATED_DATE] as CREATED_2_20_, interactio0_.LAST_MODIFIED_BY_ID as LAST_MO10_20_, interactio0_.[LAST_MODIFIED_DATE] as LAST_MOD3_20_, interactio0_.[REASON_FOR_INCLUDE] as REASON_F4_20_, interactio0_.RELEASE_ID as RELEASE11_20_, interactio0_.[WORKING_COPY_ID] as WORKING_5_20_, interactio0_.WORKSPACE_ID as WORKSPA12_20_, interactio0_.[NAME] as NAME6_20_, interactio0_.[PATH] as PATH7_20_, interactio0_.TOUCHPOINT_ID as TOUCHPO13_20_, interactio0_.[VERIFIED_IF_VISITED] as VERIFIED8_20_ from [INTERACTION] interactio0_ where interactio0_.RELEASE_ID=@P0        
                                                    