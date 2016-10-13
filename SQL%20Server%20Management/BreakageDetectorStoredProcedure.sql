--------------------------------------------------------------------------------
-- This proc can be used to perform some checks on procs and views. It uses
-- extended proc sp_refreshsqlmodule to try to refresh SQL dependencies. Along
-- the way, it reports on various forms of brokenness such as missing columns
-- that it might find.
--
-- For administrative use only. Does not change the database but does cause
-- the updating of the SQL dependency information.
--
-- v2: added automatic pass for schemabound views, table-valued functions; added
--     more comprehensive dependency checking to flag more issues than before
-- v1: initial
--------------------------------------------------------------------------------
create proc [dbo].[BreakageDetector]
    @ListAllObjects bit = 0 -- Set to 1 to list all objects, not just the ones checked
as
begin
    set nocount on;
    declare @msg nvarchar(max) = 'BreakageDetector v2 starts ' + convert(nvarchar(max), getdate()) + ' on ' + db_name() + ' on ' + @@servername;
   print @msg;

    declare @Name nvarchar(max), @Type nvarchar(max);
    declare @Result int;
    declare @IssueCount int = 0;
    declare @TotalCount int = 0;

    declare C cursor fast_forward for
    select schema_name(o.schema_id) + '.' + object_name(o.object_id), type
    from sys.objects o
    where type_desc in ('sql_stored_procedure', 'sql_trigger', 'sql_scalar_function', 'sql_table_valued_function', 'sql_inline_table_valued_function', 'view')
    order by object_name(o.object_id);

    open C;
    while 1=1
    begin
        fetch next from C into @Name, @Type;
        if @@FETCH_STATUS <> 0 break;
        set @TotalCount = @TotalCount + 1;
        declare @Sql nvarchar(max) = N'EXEC sp_refreshsqlmodule ''' + @Name + '''';
        -- PRINT @Sql; --j
        if @Name = object_schema_name(@@PROCID) + '.' + object_name(@@PROCID)
        begin
            if @ListAllObjects = 1 print '     skipping self: ' + @Name;
            continue;
        end
        if 1 = (select objectproperty(object_id(@Name), 'IsSchemaBound'))
            and (@Type = 'V' or @Type = 'TF')
        begin
            if @ListAllObjects = 1 print '     assumed ok: schemabound item ' + @Name;
            continue;
        end
        begin try
            exec @Result = sp_executesql @Sql;
            if @Result <> 0 RAISERROR('Failed', 16, 1);
        end try
        begin catch
            declare @err int = error_number();
            set @msg = error_message();
            set @IssueCount = @IssueCount + 1;
            print '*** ISSUE: ' + @Type + ' ' + @Name + ' (' + cast(@err as varchar) + ': ' + @msg + ')';
            if @@TRANCOUNT > 0 rollback transaction;
            continue;
        end catch
        -- for procs, follow dependencies further
        if @Type = 'P'
        begin
            declare @objid int = object_id(@Name);
            declare @misslist varchar(max) = null;
            select @misslist = coalesce(@misslist+', ', '') + coalesce(ed.referenced_schema_name + '.', '') + ed.referenced_entity_name
            from sys.sql_expression_dependencies ed
            where ed.referencing_id = @objid and ed.referenced_id is null;
            if @misslist is not null
            begin
                set @IssueCount = @IssueCount + 1;
                print '*** ISSUE: ' + @Type + ' ' + @Name + ': Can''t resolve ' + @misslist;
                continue;
            end
        end
        if @ListAllObjects = 1 print '     ok: ' + @Name;
    end

    set @msg = '  Objects checked: ' + cast(@TotalCount as varchar);
    if @ListAllObjects = 0 set @msg = @msg + ' (to list all of them, invoke with @ListAllObjects=1)';
    print @msg;
    print '  Issues found: ' + cast(@IssueCount as varchar);
    close C;
    deallocate C;
    print 'BreakageDetector done.';
end
