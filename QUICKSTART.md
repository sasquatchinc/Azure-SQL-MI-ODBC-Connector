# Quick Start Guide - Azure SQL MI ODBC Connector for Power Query

## 5-Minute Setup

### Step 1: Verify Prerequisites
- [ ] ODBC Driver 17 for SQL Server installed (run `odbcad32.exe` to verify)
- [ ] Power BI Desktop or Excel with Power Query
- [ ] Azure SQL Managed Instance accessible from your network
- [ ] SQL MI credentials or Windows authentication available

### Step 2: Locate Connector Folder
**For Power BI Desktop:**
```
C:\Users\<YourUsername>\Documents\Power BI Desktop\Custom Connectors
```

**For Excel:**
```
C:\Users\<YourUsername>\Documents\Power Query\Connectors
```

Create the folder if it doesn't exist.

### Step 3: Copy Connector File
Copy `AzureSQLMI.ODBC.pq` to your Custom Connectors folder.

### Step 4: Enable Custom Connectors
**Power BI Desktop:**
1. File → Options and Settings → Options
2. Security → Data Extensions
3. Set to "Allow any extension to load without validation or warning"
4. Restart Power BI Desktop

**Excel:**
1. File → Options → Trust Center
2. Trust Center Settings → Trusted Locations
3. Add your Custom Connectors folder path

### Step 5: Connect in Power Query
1. New Query → From Other Sources → Web
2. Paste one of these formulas (updated with your details):

#### Option A: SQL Authentication
```
AzureSQLMI.Contents(
    "myserver.public.abc123xyz.database.windows.net",
    "MyDatabase",
    "sqladmin",
    "MyPassword123!",
    false
)
```

#### Option B: Windows Authentication
```
AzureSQLMI.Contents(
    "myserver.public.abc123xyz.database.windows.net",
    "MyDatabase",
    null,
    null,
    true
)
```

### Step 6: Test Connection
1. Click "Invoke" or OK
2. You should see available tables from your database
3. Select tables to import
4. Click Load

## Getting Your SQL MI Server Name

1. Go to Azure Portal
2. Navigate to your SQL Managed Instance
3. Look for "Host" property, e.g., `myserver.public.abc123xyz.database.windows.net`
4. Use this as your Server parameter

## Verifying ApplicationIntent=ReadOnly

### Method 1: In Power Query
The connector automatically adds `ApplicationIntent=ReadOnly` to all connections.

### Method 2: Check Connection Properties
Run this query to verify read-only status:
```sql
SELECT
    session_id,
    login_name,
    client_interface_name,
    program_name,
    SERVERPROPERTY('IsIntegratedSecurityOnly') as IntegratedSecurity
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID
```

If `ApplicationIntent=ReadOnly` is set, the session uses a read-only replica.

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| "Driver not found" | Install ODBC Driver 17 for SQL Server |
| Connection refused | Check SQL MI network rules, public endpoint enabled |
| Authentication failed | Verify credentials, check IP firewall rules |
| Query timeout | Add timeout to connection string or filter data more |
| Cannot write data | This is by design - ApplicationIntent=ReadOnly prevents writes |

## Common Connection Strings

### Azure SQL MI with SQL Auth
```
Driver={ODBC Driver 17 for SQL Server};
Server=myserver.public.abc123xyz.database.windows.net;
Database=MyDatabase;
Uid=sqladmin;
Pwd=MyPassword123!;
ApplicationIntent=ReadOnly;
Encrypt=yes;
TrustServerCertificate=no
```

### Azure SQL MI with Windows Auth
```
Driver={ODBC Driver 17 for SQL Server};
Server=myserver.public.abc123xyz.database.windows.net;
Database=MyDatabase;
Trusted_Connection=yes;
ApplicationIntent=ReadOnly;
Encrypt=yes;
TrustServerCertificate=no
```

## Performance Tips

1. **Filter early** - Apply WHERE clauses on the server, not in Power Query
2. **Select columns needed** - Don't SELECT * if you don't need all columns
3. **Use indexes** - Query columns that have indexes
4. **Batch imports** - Import large tables during off-peak hours
5. **Enable query folding** - Let ODBC handle aggregations when possible

## What is ApplicationIntent=ReadOnly?

- **Purpose**: Routes all queries to read-only replicas in Azure SQL MI
- **Benefits**: Better performance for read-heavy workloads, prevents accidental writes
- **Enforcement**: Hardcoded in this connector - cannot be overridden
- **Azure SQL MI**: Automatically routes to secondary replicas when available

## Next Steps

1. **Import first table** - Test with a small table first
2. **Monitor performance** - Check query duration in Power Query
3. **Optimize queries** - Use native SQL queries for complex operations
4. **Build reports** - Create visualizations in Power BI
5. **Schedule refresh** - Set up data refresh in Power BI Service

## Additional Resources

- [Azure SQL Managed Instance Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/managed-instance-overview)
- [ODBC Driver 17 Documentation](https://learn.microsoft.com/en-us/sql/connect/odbc/microsoft-odbc-driver-for-sql-server)
- [Power Query Documentation](https://learn.microsoft.com/en-us/powerquery-m/power-query-m-function-reference)
- [ReadOnly Intent in Azure SQL](https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options#read_committed_snapshot)

## Support & Issues

If you encounter issues:
1. Check ODBC Driver installation
2. Verify connectivity to SQL MI from your machine
3. Confirm credentials have database access
4. Check Power Query custom connector requirements
5. Review error messages in Power Query diagnostics

---

**Ready to connect?** Start with Step 1 above, then follow each step in order. You should be querying data in 5-10 minutes!
