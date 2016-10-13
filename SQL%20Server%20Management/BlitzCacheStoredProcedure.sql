

CREATE PROCEDURE dbo.sp_BlitzCache
    @get_help BIT = 0,
    @top INT = 50,
    @sort_order VARCHAR(50) = 'CPU',
    @use_triggers_anyway BIT = NULL,
    @export_to_excel BIT = 0,
    @results VARCHAR(10) = 'simple',
    @output_database_name NVARCHAR(128) = NULL ,
    @output_schema_name NVARCHAR(256) = NULL ,
    @output_table_name NVARCHAR(256) = NULL ,
    @configuration_database_name NVARCHAR(128) = NULL ,
    @configuration_schema_name NVARCHAR(256) = NULL ,
    @configuration_table_name NVARCHAR(256) = NULL ,
    @duration_filter DECIMAL(38,4) = NULL ,
    @hide_summary BIT = 0 ,
    @ignore_system_db BIT = 1 ,
    @only_query_hashes VARCHAR(MAX) = NULL ,
    @ignore_query_hashes VARCHAR(MAX) = NULL ,
    @whole_cache BIT = 0 /* This will forcibly set @top to 2,147,483,647 */
WITH RECOMPILE
/******************************************
sp_BlitzCache (TM) 2014, Brent Ozar Unlimited.
(C) 2014, Brent Ozar Unlimited.
See http://BrentOzar.com/go/eula for the End User Licensing Agreement.



Description: Displays a server level view of the SQL Server plan cache.

Output: One result set is presented that contains data from the statement,
procedure, and trigger stats DMVs.

To learn more, visit http://brentozar.com/blitzcache/
where you can download new versions for free, watch training videos on
how it works, get more info on the findings, and more. To contribute
code and see your name in the change log, email your improvements &
ideas to help@brentozar.com.


KNOWN ISSUES:
- This query will not run on SQL Server 2005.
- SQL Server 2008 and 2008R2 have a bug in trigger stats (see below).
- @ignore_query_hashes and @only_query_hashes require a CSV list of hashes
  with no spaces between the hash values.

v2.3 - 2014-06-07
 - Added opserver specific output
 - Adding a `@only_query_hashes` parameter to limit results to a select set of
   query hashes.
 - Adding a `@ignore_query_hashes` parameter to exclude specific queries from
   analysis.

v2.2 - 2014-05-20
 - Added sorting on averages
 - Added configuration table parameters. Includes help messages for the
   allowed parameters and default values.
 - Missing index warning now displays the number of missing indexes.
 - Changing display to milliseconds instead of microseconds.
 - Adding a flag to ignore system databases. This is on by default.
 - Correcting a typo found by Michael Zilberstein. Thanks!
 - Fixing an XML bug for implicit conversion detection - contributed by Michael Zilberstein.
 - Added a check for unparameterized queries.

v2.1 - 2014-04-30
 - Added @duration_filter. Queries are now filtered during collection based on duration.
 - Added results summary table and hide_summary parameter.
 - Added check for > 1000 executions per minute.
 - Added check for queries with missing indexes.
 - Added check for queries with warnings in the execution plan.
 - Added check for queries using cursors.
 - Query cost will be displayed next to the execution plan for a query.
 - Added a check for plan guides and forced plans.
 - An asterisk will be displayed next to the name of queries that have gone parallel.
 - Added a check for parallel plans.
 - Added @results parameter - options are 'narrow', 'simple', and 'expert'
 - Added a check for plans using a downlevel cardinality estimator
 - Added checks for plans with implicit conversions or plan affecting convert warnings
 - Added check for queries with spill warnings
 - Consolidated warning detection into a smaller number of T-SQL statements
 - Added a Warnings column
 - Added "busy loops" check
 - Fixed bug where long-running query threshold was 300 microseconds, not seconds

v2.0 - 2014-03-23
 - Created a stored procedure
 - Added write information
 - Added option to export to a single table
 - Corrected accidental exclusion of trigger information

v1.4 - 2014-02-17
 - MOAR BUG FIXES
 - Corrected multiple sorting bugs that cause confusing displays of query
   results that weren't necessarily the top anything.
 - Updated all modification timestamps to use ISO 8601 formatting because it's
   correct, sorry Britain.
 - Added a check for SQL Server 2008R2 build greater than SP1.
   Thanks to Kevan Riley for spotting this.
 - Added the stored procedure or trigger name to the Query Type column.
   Initial suggestion from Kevan Riley.
 - Corrected erronous math that could allow for % CPU/Duration/Executions/Reads
   being higher than 100% for batches/procedures with multiple poorly
   performing statements in them.

v1.3 - 2014-02-06
 - As they say on the app store, "Bug fixes"
 - Reorganized this to put the standard, gotta-run stuff at the top.
 - Switched to YYYY/MM/DD because Brits.

v1.2 - 2014-02-04
- Removed debug code
- Fixed output where SQL Server 2008 and early don't support min_rows,
  max_rows, and total_rows.
  SQL Server 2008 and earlier will now return NULL for those columns.

v1.1 - 2014-02-02
- Incorporated sys.dm_exec_plan_attributes as recommended by Andrey
  and Michael J. Swart.
- Added additional detail columns for plan cache analysis including
  min/max rows, total rows.
- Streamlined collection of data.



*******************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @nl nvarchar(2) = NCHAR(13) + NCHAR(10) ;

IF @get_help = 1
BEGIN
    SELECT N'@get_help' AS [Parameter Name] ,
           N'BIT' AS [Data Type] ,
           N'Displays this help message.' AS [Parameter Description]

    UNION ALL
    SELECT N'@top',
           N'INT',
           N'The number of records to retrieve and analyze from the plan cache. The following DMVs are used as the plan cache: dm_exec_query_stats, dm_exec_procedure_stats, dm_exec_trigger_stats.'

    UNION ALL
    SELECT N'@sort_order',
           N'VARCHAR(10)',
           N'Data processing and display order. @sort_order will still be used, even when preparing output for a table or for excel. Possible values are: "CPU", "Reads", "Writes", "Duration", "Executions". Additionally, the word "Average" or "Avg" can be used to sort on averages rather than total. "Executions per minute" and "Executions / minute" can be used to sort by execution per minute. For the truly lazy, "xpm" can also be used.'

    UNION ALL
    SELECT N'@use_triggers_anyway',
           N'BIT',
           N'On SQL Server 2008R2 and earlier, trigger execution count is incorrect - trigger execution count is incremented once per execution of a SQL agent job. If you still want to see relative execution count of triggers, then you can force sp_BlitzCache to include this information.'

    UNION ALL
    SELECT N'@export_to_excel',
           N'BIT',
           N'Prepare output for exporting to Excel. Newlines and additional whitespace are removed from query text and the execution plan is not displayed.'

    UNION ALL
    SELECT N'@results',
           N'VARCHAR(10)',
           N'Results mode. Options are "Narrow", "Simple", or "Expert". This determines which columns will be displayed in the analysis of the plan cache.'

    UNION ALL
    SELECT N'@output_database_name',
           N'NVARCHAR(128)',
           N'The output database. If this does not exist SQL Server will divide by zero and everything will fall apart.'

    UNION ALL
    SELECT N'@output_schema_name',
           N'NVARCHAR(256)',
           N'The output schema. If this does not exist SQL Server will divide by zero and everything will fall apart.'

    UNION ALL
    SELECT N'@output_table_name',
           N'NVARCHAR(256)',
           N'The output table. If this does not exist, it will be created for you.'

    UNION ALL
    SELECT N'@duration_filter',
           N'DECIMAL(38,4)',
           N'Excludes queries with an average duration (in seconds) less than @duration_filter.'

    UNION ALL
    SELECT N'@hide_summary',
           N'BIT',
           N'Hides the findings summary result set.'

    UNION ALL
    SELECT N'@ignore_system_db',
           N'BIT',
           N'Ignores plans found in the system databases (master, model, msdb, tempdb, and resourcedb)'

    UNION ALL
    SELECT N'@only_query_hashes',
           N'VARCHAR(MAX)',
           N'A list of query hashes to query. All other query hashes will be ignored. Stored procedures and triggers will be ignored.'

    UNION ALL
    SELECT N'@ignore_query_hashes',
           N'VARCHAR(MAX)',
           N'A list of query hashes to ignore.'
           
    UNION ALL
    SELECT N'@whole_cache',
           N'BIT',
           N'This forces sp_BlitzCache to examine the entire plan cache. Be careful running this on servers with a lot of memory or a large execution plan cache.' ;



    /* Column definitions */
    SELECT N'# Executions' AS [Column Name],
           N'BIGINT' AS [Data Type],
           N'The number of executions of this particular query. This is computed across statements, procedures, and triggers and aggregated by the SQL handle.' AS [Column Description]

    UNION ALL
    SELECT N'Executions / Minute',
           N'MONEY',
           N'Number of executions per minute - calculated for the life of the current plan. Plan life is the last execution time minus the plan creation time.'

    UNION ALL
    SELECT N'Execution Weight',
           N'MONEY',
           N'An arbitrary metric of total "execution-ness". A weight of 2 is "one more" than a weight of 1.'

    UNION ALL
    SELECT N'Database',
           N'sysname',
           N'The name of the database where the plan was encountered. If the database name cannot be determined for some reason, a value of NA will be substituted. A value of 32767 indicates the plan comes from ResourceDB.'

    UNION ALL
    SELECT N'Total CPU',
           N'BIGINT',
           N'Total CPU time, reported in milliseconds, that was consumed by all executions of this query since the last compilation.'

    UNION ALL
    SELECT N'Avg CPU',
           N'BIGINT',
           N'Average CPU time, reported in milliseconds, consumed by each execution of this query since the last compilation.'

    UNION ALL
    SELECT N'CPU Weight',
           N'MONEY',
           N'An arbitrary metric of total "CPU-ness". A weight of 2 is "one more" than a weight of 1.'


    UNION ALL
    SELECT N'Total Duration',
           N'BIGINT',
           N'Total elapsed time, reported in milliseconds, consumed by all executions of this query since last compilation.'

    UNION ALL
    SELECT N'Avg Duration',
           N'BIGINT',
           N'Average elapsed time, reported in milliseconds, consumed by each execution of this query since the last compilation.'

    UNION ALL
    SELECT N'Duration Weight',
           N'MONEY',
           N'An arbitrary metric of total "Duration-ness". A weight of 2 is "one more" than a weight of 1.'

    UNION ALL
    SELECT N'Total Reads',
           N'BIGINT',
           N'Total logical reads performed by this query since last compilation.'

    UNION ALL
    SELECT N'Average Reads',
           N'BIGINT',
           N'Average logical reads performed by each execution of this query since the last compilation.'

    UNION ALL
    SELECT N'Read Weight',
           N'MONEY',
           N'An arbitrary metric of "Read-ness". A weight of 2 is "one more" than a weight of 1.'

    UNION ALL
    SELECT N'Total Writes',
           N'BIGINT',
           N'Total logical writes performed by this query since last compilation.'

    UNION ALL
    SELECT N'Average Writes',
           N'BIGINT',
           N'Average logical writes performed by each execution this query since last compilation.'

    UNION ALL
    SELECT N'Write Weight',
           N'MONEY',
           N'An arbitrary metric of "Write-ness". A weight of 2 is "one more" than a weight of 1.'

    UNION ALL
    SELECT N'Query Type',
           N'NVARCHAR(256)',
           N'The type of query being examined. This can be "Procedure", "Statement", or "Trigger".'

    UNION ALL
    SELECT N'Query Text',
           N'NVARCHAR(4000)',
           N'The text of the query. This may be truncated by either SQL Server or by sp_BlitzCache(tm) for display purposes.'

    UNION ALL
    SELECT N'% Executions (Type)',
           N'MONEY',
           N'Percent of executions relative to the type of query - e.g. 17.2% of all stored procedure executions.'

    UNION ALL
    SELECT N'% CPU (Type)',
           N'MONEY',
           N'Percent of CPU time consumed by this query for a given type of query - e.g. 22% of CPU of all stored procedures executed.'

    UNION ALL
    SELECT N'% Duration (Type)',
           N'MONEY',
           N'Percent of elapsed time consumed by this query for a given type of query - e.g. 12% of all statements executed.'

    UNION ALL
    SELECT N'% Reads (Type)',
           N'MONEY',
           N'Percent of reads consumed by this query for a given type of query - e.g. 34.2% of all stored procedures executed.'

    UNION ALL
    SELECT N'% Writes (Type)',
           N'MONEY',
           N'Percent of writes performed by this query for a given type of query - e.g. 43.2% of all statements executed.'

    UNION ALL
    SELECT N'Total Rows',
           N'BIGINT',
           N'Total number of rows returned for all executions of this query. This only applies to query level stats, not stored procedures or triggers.'

    UNION ALL
    SELECT N'Average Rows',
           N'MONEY',
           N'Average number of rows returned by each execution of the query.'

    UNION ALL
    SELECT N'Min Rows',
           N'BIGINT',
           N'The minimum number of rows returned by any execution of this query.'

    UNION ALL
    SELECT N'Max Rows',
           N'BIGINT',
           N'The maximum number of rows returned by any execution of this query.'

    UNION ALL
    SELECT N'# Plans',
           N'INT',
           N'The total number of execution plans found that match a given query.'

    UNION ALL
    SELECT N'# Distinct Plans',
           N'INT',
           N'The number of distinct execution plans that match a given query. '
            + NCHAR(13) + NCHAR(10)
            + N'This may be caused by running the same query across multiple databases or because of a lack of proper parameterization in the database.'

    UNION ALL
    SELECT N'Created At',
           N'DATETIME',
           N'Time that the execution plan was last compiled.'

    UNION ALL
    SELECT N'Last Execution',
           N'DATETIME',
           N'The last time that this query was executed.'

    UNION ALL
    SELECT N'Query Plan',
           N'XML',
           N'The query plan. Click to display a graphical plan or, if you need to patch SSMS, a pile of XML.'

    UNION ALL
    SELECT N'Plan Handle',
           N'VARBINARY(64)',
           N'An arbitrary identifier referring to the compiled plan this query is a part of.'

    UNION ALL
    SELECT N'SQL Handle',
           N'VARBINARY(64)',
           N'An arbitrary identifier referring to a batch or stored procedure that this query is a part of.'

    UNION ALL
    SELECT N'Query Hash',
           N'BINARY(8)',
           N'A hash of the query. Queries with the same query hash have similar logic but only differ by literal values or database.'

    UNION ALL
    SELECT N'Warnings',
           N'VARCHAR(MAX)',
           N'A list of individual warnings generated by this query.' ;


           
    /* Configuration table description */
    SELECT N'Frequent Execution Threshold' AS [Configuration Parameter] ,
           N'100' AS [Default Value] ,
           N'Executions / Minute' AS [Unit of Measure] ,
           N'Executions / Minute before a "Frequent Execution Threshold" warning is triggered.' AS [Description]

    UNION ALL
    SELECT N'Parameter Sniffing Variance Percent' ,
           N'30' ,
           N'Percent' ,
           N'Variance required between min/max values and average values before a "Parameter Sniffing" warning is triggered. Applies to worker time and returned rows.'

    UNION ALL
    SELECT N'Parameter Sniffing IO Threshold' ,
           N'100,000' ,
           N'Logical reads' ,
           N'Minimum number of average logical reads before parameter sniffing checks are evaluated.'

    UNION ALL
    SELECT N'Cost Threshold for Parallelism Warning' AS [Configuration Parameter] ,
           N'10' ,
           N'Percent' ,
           N'Trigger a "Nearly Parallel" warning when a query''s cost is within X percent of the cost threshold for parallelism.'

    UNION ALL
    SELECT N'Long Running Query Warning' AS [Configuration Parameter] ,
           N'300' ,
           N'Seconds' ,
           N'Triggers a "Long Running Query Warning" when average duration, max CPU time, or max clock time is higher than this number.'

    RETURN
END

DECLARE @duration_filter_i INT,
        @msg NVARCHAR(4000) ;

RAISERROR (N'Setting up temporary tables for sp_BlitzCache',0,1) WITH NOWAIT;

/* Change duration from seconds to milliseconds */
IF @duration_filter IS NOT NULL
  SET @duration_filter_i = CAST((@duration_filter * 1000.0) AS INT)

SET @sort_order = LOWER(@sort_order);
SET @sort_order = REPLACE(REPLACE(@sort_order, 'average', 'avg'), '.', '');
SET @sort_order = REPLACE(@sort_order, 'executions per minute', 'avg executions');
SET @sort_order = REPLACE(@sort_order, 'executions / minute', 'avg executions');
SET @sort_order = REPLACE(@sort_order, 'xpm', 'avg executions');


IF @sort_order NOT IN ('cpu', 'avg cpu', 'reads', 'avg reads', 'writes', 'avg writes',
                       'duration', 'avg duration', 'executions', 'avg executions')
  SET @sort_order = 'cpu';

SELECT @output_database_name = QUOTENAME(@output_database_name),
       @output_schema_name   = QUOTENAME(@output_schema_name),
       @output_table_name    = QUOTENAME(@output_table_name)

IF OBJECT_ID('tempdb..#only_query_hashes') IS NOT NULL
   DROP TABLE #only_query_hashes ;

IF OBJECT_ID('tempdb..#ignore_query_hashes') IS NOT NULL
   DROP TABLE #ignore_query_hashes ;
   
IF OBJECT_ID('tempdb..#results') IS NOT NULL
    DROP TABLE #results;

IF OBJECT_ID('tempdb..#p') IS NOT NULL
    DROP TABLE #p;

IF OBJECT_ID('tempdb..#procs') IS NOT NULL
    DROP TABLE #procs;

IF OBJECT_ID ('tempdb..#checkversion') IS NOT NULL
    DROP TABLE #checkversion;

IF OBJECT_ID ('tempdb..#configuration') IS NOT NULL
   DROP TABLE #configuration;

CREATE TABLE #only_query_hashes (
   query_hash BINARY(8)
);

CREATE TABLE #ignore_query_hashes (
   query_hash BINARY(8)
);

CREATE TABLE #results (
    ID INT IDENTITY(1,1),
    CheckID INT,
    Priority TINYINT,
    FindingsGroup VARCHAR(50),
    Finding VARCHAR(200),
    URL VARCHAR(200),
    Details VARCHAR(4000)
);

CREATE TABLE #p (
    SqlHandle varbinary(64),
    TotalCPU bigint,
    TotalDuration bigint,
    TotalReads bigint,
    TotalWrites bigint,
    ExecutionCount bigint
);

CREATE TABLE #checkversion (
    version nvarchar(128),
    maj_version AS SUBSTRING(version, 1,CHARINDEX('.', version) + 1 ),
    build AS PARSENAME(CONVERT(varchar(32), version), 2)
);

CREATE TABLE #configuration (
    parameter_name VARCHAR(100),
    value DECIMAL(38,0)
);

CREATE TABLE #procs (
    QueryType nvarchar(256),
    DatabaseName sysname,
    AverageCPU decimal(38,4),
    AverageCPUPerMinute decimal(38,4),
    TotalCPU decimal(38,4),
    PercentCPUByType money,
    PercentCPU money,
    AverageDuration decimal(38,4),
    TotalDuration decimal(38,4),
    PercentDuration money,
    PercentDurationByType money,
    AverageReads bigint,
    TotalReads bigint,
    PercentReads money,
    PercentReadsByType money,
    ExecutionCount bigint,
    PercentExecutions money,
    PercentExecutionsByType money,
    ExecutionsPerMinute money,
    TotalWrites bigint,
    AverageWrites money,
    PercentWrites money,
    PercentWritesByType money,
    WritesPerMinute money,
    PlanCreationTime datetime,
    LastExecutionTime datetime,
    PlanHandle varbinary(64),
    SqlHandle varbinary(64),
    QueryHash binary(8),
    QueryPlanHash binary(8),
    StatementStartOffset int,
    StatementEndOffset int,
    MinReturnedRows bigint,
    MaxReturnedRows bigint,
    AverageReturnedRows money,
    TotalReturnedRows bigint,
    LastReturnedRows bigint,
    QueryText nvarchar(max),
    QueryPlan xml,
    /* these next four columns are the total for the type of query.
       don't actually use them for anything apart from math by type.
     */
    TotalWorkerTimeForType bigint,
    TotalElapsedTimeForType bigint,
    TotalReadsForType bigint,
    TotalExecutionCountForType bigint,
    TotalWritesForType bigint,
    NumberOfPlans int,
    NumberOfDistinctPlans int,
    min_worker_time bigint,
    max_worker_time bigint,
    is_forced_plan bit,
    is_forced_parameterized bit,
    is_cursor bit,
    is_parallel bit,
    frequent_execution bit,
    parameter_sniffing bit,
    unparameterized_query bit,
    near_parallel bit,
    plan_warnings bit,
    plan_multiple_plans bit,
    long_running bit,
    downlevel_estimator bit,
    implicit_conversions bit,
    tempdb_spill bit,
    busy_loops bit,
    tvf_join bit,
    tvf_estimate bit,
    compile_timeout bit,
    compile_memory_limit_exceeded bit,
    warning_no_join_predicate bit,
    QueryPlanCost float,
    missing_index_count int,
    unmatched_index_count int,
    min_elapsed_time bigint,
    max_elapsed_time bigint,
    Warnings VARCHAR(MAX)
);

SET @only_query_hashes = LTRIM(RTRIM(@only_query_hashes)) ;
SET @ignore_query_hashes = LTRIM(RTRIM(@ignore_query_hashes)) ;

/* If the user is attempting to limit by query hash, set up the
   #only_query_hashes temp table. This will be used to narrow down
   results.

   Just a reminder: Using @only_query_hashes will ignore stored
   procedures and triggers.
 */
IF @only_query_hashes IS NOT NULL
   AND LEN(@only_query_hashes) > 0
BEGIN
   DECLARE @individual VARCHAR(50) ;

   WHILE LEN(@only_query_hashes) > 0
   BEGIN
        IF PATINDEX('%,%', @only_query_hashes) > 0
        BEGIN  
               SET @individual = SUBSTRING(@only_query_hashes, 0, PATINDEX('%,%',@only_query_hashes)) ;
               
               INSERT INTO #only_query_hashes
               select cast('' as xml).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               from (select case substring(@individual, 1, 2) when '0x' then 3 else 0 end) as t(pos)
               
               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS BINARY(8));

               SET @only_query_hashes = SUBSTRING(@only_query_hashes, LEN(@individual + ',') + 1, LEN(@only_query_hashes)) ;
        END
        ELSE
        BEGIN
               SET @individual = @only_query_hashes
               SET @only_query_hashes = NULL

               INSERT INTO #only_query_hashes
               select cast('' as xml).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               from (select case substring(@individual, 1, 2) when '0x' then 3 else 0 end) as t(pos)

               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS VARBINARY(MAX)) ;
        END
   END
END

/* If the user is setting up a list of query hashes to ignore, those
   values will be inserted into #ignore_query_hashes. This is used to
   exclude values from query results.

   Stored procedures and triggers will still be queried.
 */
IF @ignore_query_hashes IS NOT NULL
   AND LEN(@ignore_query_hashes) > 0
BEGIN
   SET @individual = '' ;

   WHILE LEN(@ignore_query_hashes) > 0
   BEGIN
        IF PATINDEX('%,%', @ignore_query_hashes) > 0
        BEGIN  
               SET @individual = SUBSTRING(@ignore_query_hashes, 0, PATINDEX('%,%',@ignore_query_hashes)) ;
               
               INSERT INTO #ignore_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos) ;
               
               SET @ignore_query_hashes = SUBSTRING(@ignore_query_hashes, LEN(@individual + ',') + 1, LEN(@ignore_query_hashes)) ;
        END
        ELSE
        BEGIN
               SET @individual = @ignore_query_hashes ;
               SET @ignore_query_hashes = NULL ;

               INSERT INTO #ignore_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos) ;
        END
   END
END

IF @configuration_database_name IS NOT NULL
BEGIN
   DECLARE @config_sql NVARCHAR(MAX) = N'INSERT INTO #configuration SELECT parameter_name, value FROM '
        + QUOTENAME(@configuration_database_name)
        + '.' + QUOTENAME(@configuration_schema_name)
        + '.' + QUOTENAME(@configuration_table_name)
        + ' ; ' ;
   EXEC(@config_sql);
END

DECLARE @sql nvarchar(MAX) = N'',
        @insert_list nvarchar(MAX) = N'',
        @plans_triggers_select_list nvarchar(MAX) = N'',
        @body nvarchar(MAX) = N'',
        @body_where nvarchar(MAX) = N'',
        @body_order nvarchar(MAX) = N'ORDER BY #sortable# DESC OPTION (RECOMPILE) ',
        
        @q nvarchar(1) = N'''',
        @pv varchar(20),
        @pos tinyint,
        @v decimal(6,2),
        @build int;


RAISERROR (N'Determining SQL Server version.',0,1) WITH NOWAIT;

INSERT INTO #checkversion (version)
SELECT CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128))
OPTION (RECOMPILE);


SELECT @v = maj_version ,
       @build = build
FROM   #checkversion
OPTION (RECOMPILE);

RAISERROR (N'Creating dynamic SQL based on SQL Server version.',0,1) WITH NOWAIT;

SET @insert_list += N'
INSERT INTO #procs (QueryType, DatabaseName, AverageCPU, TotalCPU, AverageCPUPerMinute, PercentCPUByType, PercentDurationByType,
                    PercentReadsByType, PercentExecutionsByType, AverageDuration, TotalDuration, AverageReads, TotalReads, ExecutionCount,
                    ExecutionsPerMinute, TotalWrites, AverageWrites, PercentWritesByType, WritesPerMinute, PlanCreationTime,
                    LastExecutionTime, StatementStartOffset, StatementEndOffset, MinReturnedRows, MaxReturnedRows, AverageReturnedRows, TotalReturnedRows,
                    LastReturnedRows, QueryText, QueryPlan, TotalWorkerTimeForType, TotalElapsedTimeForType, TotalReadsForType,
                    TotalExecutionCountForType, TotalWritesForType, SqlHandle, PlanHandle, QueryHash, QueryPlanHash,
                    min_worker_time, max_worker_time, is_parallel, min_elapsed_time, max_elapsed_time) ' ;

SET @body += N'
FROM   (SELECT *,
               CAST((CASE WHEN DATEDIFF(second, cached_time, GETDATE()) > 0 AND execution_count > 1
                          THEN DATEDIFF(second, cached_time, GETDATE()) / 60.0
                          ELSE NULL END) as MONEY) as age_minutes,
               CAST((CASE WHEN DATEDIFF(second, cached_time, last_execution_time) > 0 AND execution_count > 1
                          THEN DATEDIFF(second, cached_time, last_execution_time) / 60.0
                          ELSE Null END) as MONEY) as age_minutes_lifetime
        FROM   sys.#view# x ' + @nl ;

IF (SELECT COUNT(*) FROM #only_query_hashes) > 0
   AND (SELECT COUNT(*) FROM #ignore_query_hashes) = 0
BEGIN
    SET @body += N'        WHERE  EXISTS(SELECT 1/0 FROM #only_query_hashes q WHERE q.query_hash = x.query_hash) ' + @nl
END

                          
SET @body += N') AS qs
       CROSS JOIN(SELECT SUM(execution_count) AS t_TotalExecs,
                         SUM(total_elapsed_time) / 1000.0 AS t_TotalElapsed,
                         SUM(total_worker_time) / 1000.0 AS t_TotalWorker,
                         SUM(total_logical_reads) AS t_TotalReads,
                         SUM(total_logical_writes) AS t_TotalWrites
                  FROM   sys.#view#) AS t
       CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
       CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
       CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp ' + @nl ;

SET @body_where = N'WHERE  pa.attribute = ' + QUOTENAME('dbid', @q) + @nl ;

IF @duration_filter IS NOT NULL
   SET @body_where += N'       AND (total_elapsed_time / 1000.0) / execution_count > @min_duration ' + @nl ;

SET @plans_triggers_select_list += N'
SELECT TOP (@top)
       ''Procedure: '' + COALESCE(OBJECT_NAME(qs.object_id, qs.database_id),'''') AS QueryType,
       COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), ''-- N/A --'') AS DatabaseName,
       (total_worker_time / 1000.0) / execution_count AS AvgCPU ,
       (total_worker_time / 1000.0) AS TotalCPU ,
       CASE WHEN total_worker_time = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((total_worker_time / 1000.0) / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time)) AS MONEY)
            END AS AverageCPUPerMinute ,
       CASE WHEN t.t_TotalWorker = 0 THEN 0
            ELSE CAST(ROUND(100.00 * (total_worker_time / 1000.0) / t.t_TotalWorker, 2) AS MONEY)
            END AS PercentCPUByType,
       CASE WHEN t.t_TotalElapsed = 0 THEN 0
            ELSE CAST(ROUND(100.00 * (total_elapsed_time / 1000.0) / t.t_TotalElapsed, 2) AS MONEY)
            END AS PercentDurationByType,
       CASE WHEN t.t_TotalReads = 0 THEN 0
            ELSE CAST(ROUND(100.00 * total_logical_reads / t.t_TotalReads, 2) AS MONEY)
            END AS PercentReadsByType,
       CASE WHEN t.t_TotalExecs = 0 THEN 0
            ELSE CAST(ROUND(100.00 * execution_count / t.t_TotalExecs, 2) AS MONEY)
            END AS PercentExecutionsByType,
       (total_elapsed_time / 1000.0) / execution_count AS AvgDuration ,
       (total_elapsed_time / 1000.0) AS TotalDuration ,
       total_logical_reads / execution_count AS AvgReads ,
       total_logical_reads AS TotalReads ,
       execution_count AS ExecutionCount ,
       CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time))) AS money)
            END AS ExecutionsPerMinute ,
       total_logical_writes AS TotalWrites ,
       total_logical_writes / execution_count AS AverageWrites ,
       CASE WHEN t.t_TotalWrites = 0 THEN 0
            ELSE CAST(ROUND(100.00 * total_logical_writes / t.t_TotalWrites, 2) AS MONEY)
            END AS PercentWritesByType,
       CASE WHEN total_logical_writes = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * total_logical_writes / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0)) AS money)
            END AS WritesPerMinute,
       qs.cached_time AS PlanCreationTime,
       qs.last_execution_time AS LastExecutionTime,
       NULL AS StatementStartOffset,
       NULL AS StatementEndOffset,
       NULL AS MinReturnedRows,
       NULL AS MaxReturnedRows,
       NULL AS AvgReturnedRows,
       NULL AS TotalReturnedRows,
       NULL AS LastReturnedRows,
       st.text AS QueryText ,
       query_plan AS QueryPlan,
       t.t_TotalWorker,
       t.t_TotalElapsed,
       t.t_TotalReads,
       t.t_TotalExecs,
       t.t_TotalWrites,
       qs.sql_handle AS SqlHandle,
       qs.plan_handle AS PlanHandle,
       NULL AS QueryHash,
       NULL AS QueryPlanHash,
       qs.min_worker_time / 1000.0,
       qs.max_worker_time / 1000.0,
       CASE WHEN qp.query_plan.value(''declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)'', ''float'')  > 0 THEN 1 ELSE 0 END,
       qs.min_elapsed_time / 1000.0,
       qs.max_elapsed_time / 1000.0 '


SET @sql += @insert_list;

SET @sql += N'
SELECT TOP (@top)
       ''Statement'' AS QueryType,
       COALESCE(DB_NAME(CAST(pa.value AS INT)), ''-- N/A --'') AS DatabaseName,
       (total_worker_time / 1000.0) / execution_count AS AvgCPU ,
       (total_worker_time / 1000.0) AS TotalCPU ,
       CASE WHEN total_worker_time = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((total_worker_time / 1000.0) / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time)) AS MONEY)
            END AS AverageCPUPerMinute ,
       CAST(ROUND(100.00 * (total_worker_time / 1000.0) / t.t_TotalWorker, 2) AS MONEY) AS PercentCPUByType,
       CAST(ROUND(100.00 * (total_elapsed_time / 1000.0) / t.t_TotalElapsed, 2) AS MONEY) AS PercentDurationByType,
       CAST(ROUND(100.00 * total_logical_reads / t.t_TotalReads, 2) AS MONEY) AS PercentReadsByType,
       CAST(ROUND(100.00 * execution_count / t.t_TotalExecs, 2) AS MONEY) AS PercentExecutionsByType,
       (total_elapsed_time / 1000.0) / execution_count AS AvgDuration ,
       (total_elapsed_time / 1000.0) AS TotalDuration ,
       total_logical_reads / execution_count AS AvgReads ,
       total_logical_reads AS TotalReads ,
       execution_count AS ExecutionCount ,
       CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time))) AS money)
            END AS ExecutionsPerMinute ,
       total_logical_writes AS TotalWrites ,
       total_logical_writes / execution_count AS AverageWrites ,
       CASE WHEN t.t_TotalWrites = 0 THEN 0
            ELSE CAST(ROUND(100.00 * total_logical_writes / t.t_TotalWrites, 2) AS MONEY)
            END AS PercentWritesByType,
       CASE WHEN total_logical_writes = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * total_logical_writes / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0)) AS money)
            END AS WritesPerMinute,
       qs.creation_time AS PlanCreationTime,
       qs.last_execution_time AS LastExecutionTime,
       qs.statement_start_offset AS StatementStartOffset,
       qs.statement_end_offset AS StatementEndOffset, '

IF (@v >= 11) OR (@v >= 10.5 AND @build >= 2500)
BEGIN
    SET @sql += N'
       qs.min_rows AS MinReturnedRows,
       qs.max_rows AS MaxReturnedRows,
       CAST(qs.total_rows as MONEY) / execution_count AS AvgReturnedRows,
       qs.total_rows AS TotalReturnedRows,
       qs.last_rows AS LastReturnedRows, ' ;
END
ELSE
BEGIN
    SET @sql += N'
       NULL AS MinReturnedRows,
       NULL AS MaxReturnedRows,
       NULL AS AvgReturnedRows,
       NULL AS TotalReturnedRows,
       NULL AS LastReturnedRows, ' ;
END

SET @sql += N'
       SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
                                                                        WHEN -1 THEN DATALENGTH(st.text)
                                                                        ELSE qs.statement_end_offset
                                                                      END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText ,
       query_plan AS QueryPlan,
       t.t_TotalWorker,
       t.t_TotalElapsed,
       t.t_TotalReads,
       t.t_TotalExecs,
       t.t_TotalWrites,
       qs.sql_handle AS SqlHandle,
       NULL AS PlanHandle,
       qs.query_hash AS QueryHash,
       qs.query_plan_hash AS QueryPlanHash,
       qs.min_worker_time / 1000.0,
       qs.max_worker_time / 1000.0,
       CASE WHEN qp.query_plan.value(''declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)'', ''float'')  > 0 THEN 1 ELSE 0 END,
       qs.min_elapsed_time / 1000.0,
       qs.max_worker_time  / 1000.0 '

SET @sql += REPLACE(REPLACE(@body, '#view#', 'dm_exec_query_stats'), 'cached_time', 'creation_time') ;

IF (SELECT COUNT(*) FROM #ignore_query_hashes) > 0
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0
BEGIN
    SET @sql += REPLACE(@sql, ') AS qs', ') AS qs
    LEFT JOIN #ignore_query_hashes iqh ON iqh.query_hash = qs.query_hash ' + @nl) ;
END




SET @sql += @body_where ;

IF @ignore_system_db = 1
    SET @sql += 'AND COALESCE(DB_NAME(CAST(pa.value AS INT)), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') ' + @nl ;

IF (SELECT COUNT(*) FROM #ignore_query_hashes) > 0
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0
BEGIN
    SET @sql += ' AND iqh.query_hash IS NULL ' + @nl ;
END

SET @sql += @body_order + @nl + @nl + @nl;


IF (SELECT COUNT(*) FROM #only_query_hashes) = 0
BEGIN
    SET @sql += @insert_list;
    SET @sql += REPLACE(@plans_triggers_select_list, '#query_type#', 'Stored Procedure') ;

    SET @sql += REPLACE(@body, '#view#', 'dm_exec_procedure_stats') ; 
    SET @sql += @body_where ;

    IF @ignore_system_db = 1
       SET @sql += ' AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') ' + @nl ;

    SET @sql += @body_order + @nl + @nl + @nl ;
END



/*******************************************************************************
 *
 * Because the trigger execution count in SQL Server 2008R2 and earlier is not
 * correct, we ignore triggers for these versions of SQL Server. If you'd like
 * to include trigger numbers, just know that the ExecutionCount,
 * PercentExecutions, and ExecutionsPerMinute are wildly inaccurate for
 * triggers on these versions of SQL Server.
 *
 * This is why we can't have nice things.
 *
 ******************************************************************************/
IF (@use_triggers_anyway = 1 OR @v >= 11)
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0
BEGIN
   RAISERROR (N'Adding SQL to collect trigger stats.',0,1) WITH NOWAIT;

   /* Trigger level information from the plan cache */
   SET @sql += @insert_list ;

   SET @sql += REPLACE(@plans_triggers_select_list, '#query_type#', 'Trigger') ;

   SET @sql += REPLACE(@body, '#view#', 'dm_exec_trigger_stats') ;

   SET @sql += @body_where ;

   IF @ignore_system_db = 1
      SET @sql += ' AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') ' + @nl ;
END




DECLARE @sort NVARCHAR(MAX);

SELECT @sort = CASE @sort_order WHEN 'cpu' THEN 'total_worker_time'
                                WHEN 'reads' THEN 'total_logical_reads'
                                WHEN 'writes' THEN 'total_logical_writes'
                                WHEN 'duration' THEN 'total_elapsed_time'
                                WHEN 'executions' THEN 'execution_count'
                                /* And now the averages */
                                WHEN 'avg cpu' THEN 'total_worker_time / execution_count'
                                WHEN 'avg reads' THEN 'total_logical_reads / execution_count'
                                WHEN 'avg writes' THEN 'total_logical_writes / execution_count'
                                WHEN 'avg duration' THEN 'total_elapsed_time / execution_count'
                                WHEN 'avg executions' THEN 'CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time))) AS money)
            END'
               END ;

SELECT @sql = REPLACE(@sql, '#sortable#', @sort);

SET @sql += N'
INSERT INTO #p (SqlHandle, TotalCPU, TotalReads, TotalDuration, TotalWrites, ExecutionCount)
SELECT  SqlHandle,
        TotalCPU,
        TotalReads,
        TotalDuration,
        TotalWrites,
        ExecutionCount
FROM    (SELECT  SqlHandle,
                 TotalCPU,
                 TotalReads,
                 TotalDuration,
                 TotalWrites,
                 ExecutionCount,
                 ROW_NUMBER() OVER (PARTITION BY SqlHandle ORDER BY #sortable# DESC) AS rn
         FROM    #procs) AS x
WHERE x.rn = 1
OPTION (RECOMPILE);
';

SELECT @sort = CASE @sort_order WHEN 'cpu' THEN 'TotalCPU'
                                WHEN 'reads' THEN 'TotalReads'
                                WHEN 'writes' THEN 'TotalWrites'
                                WHEN 'duration' THEN 'TotalDuration'
                                WHEN 'executions' THEN 'ExecutionCount'
                                WHEN 'avg cpu' THEN 'TotalCPU / ExecutionCount'
                                WHEN 'avg reads' THEN 'TotalReads / ExecutionCount'
                                WHEN 'avg writes' THEN 'TotalWrites / ExecutionCount'
                                WHEN 'avg duration' THEN 'TotalDuration / ExecutionCount'
                                WHEN 'avg executions' THEN 'CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time))) AS money)
            END'
               END ;

SELECT @sql = REPLACE(@sql, '#sortable#', @sort);



RAISERROR('Collecting execution plan information.', 0, 1) WITH NOWAIT;
EXEC sp_executesql @sql, N'@top INT, @min_duration INT', @top, @duration_filter_i;



/* Compute the total CPU, etc across our active set of the plan cache.
 * Yes, there's a flaw - this doesn't include anything outside of our @top
 * metric.
 */
RAISERROR('Computing CPU, duration, read, and write metrics', 0, 1) WITH NOWAIT;
DECLARE @total_duration BIGINT,
        @total_cpu BIGINT,
        @total_reads BIGINT,
        @total_writes BIGINT,
        @total_execution_count BIGINT;

SELECT  @total_cpu = SUM(TotalCPU),
        @total_duration = SUM(TotalDuration),
        @total_reads = SUM(TotalReads),
        @total_writes = SUM(TotalWrites),
        @total_execution_count = SUM(ExecutionCount)
FROM    #p
OPTION (RECOMPILE) ;

DECLARE @cr NVARCHAR(1) = NCHAR(13);
DECLARE @lf NVARCHAR(1) = NCHAR(10);
DECLARE @tab NVARCHAR(1) = NCHAR(9);

/* Update CPU percentage for stored procedures */
UPDATE #procs
SET     PercentCPU = y.PercentCPU,
        PercentDuration = y.PercentDuration,
        PercentReads = y.PercentReads,
        PercentWrites = y.PercentWrites,
        PercentExecutions = y.PercentExecutions,
        ExecutionsPerMinute = y.ExecutionsPerMinute,
        /* Strip newlines and tabs. Tabs are replac