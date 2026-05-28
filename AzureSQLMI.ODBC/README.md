# Azure SQL Managed Instance ODBC Connector for Power Query

## Overview
This is a Power Query custom connector for connecting to Azure SQL Managed Instance (SQL MI) using ODBC driver with **ApplicationIntent=ReadOnly** hardcoded for enforced read-only access.

## Features
- **ODBC-based connection** using ODBC Driver 17 for SQL Server
- **ApplicationIntent=ReadOnly hardcoded** - Enforces read-only access automatically
- **Encrypted connections** - TLS encryption enabled by default
- **Multiple authentication methods**:
  - SQL Server Authentication (username/password)
  - Windows/Integrated Authentication
- **Automatic schema browsing** - Navigate tables by schema
- **Direct SQL query execution** - Run custom queries with read-only enforcement

## Requirements
- **Power Query** (Excel, Power BI, or Power BI Desktop)
- **ODBC Driver 17 for SQL Server** installed on the client machine
- **Azure SQL Managed Instance** accessible from your network
- Network/firewall access to the SQL MI instance

## Installation

### 1. Install ODBC Driver
Download and install ODBC Driver 17 for SQL Server from Microsoft:
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

### 2. Add Connector to Power Query
Place the connector file in your Power Query extensions folder:

**Power BI Desktop:**
```
C:\Users\<YourUsername>\Documents\Power BI Desktop\Custom Connectors
```

**Excel:**
```
C:\Users\<YourUsername>\Documents\Power Query\Connectors
```

### 3. Enable Custom Connectors
In Power BI Desktop or Excel, go to:
- **File > Options and Settings > Options > Security > Data Extensions**
- Set to "Allow any extension to load without validation or warning"

## Usage

### Basic Connection
```
AzureSQLMI.Contents(
    "myserver.public.xxxxx.database.windows.net",
    "mydatabase",
    "myusername",
    "mypassword",
    false
)
```

### Integrated Security (Windows Authentication)
```
AzureSQLMI.Contents(
    "myserver.public.xxxxx.database.windows.net",
    "mydatabase",
    null,
    null,
    true
)
```

### Direct Query Execution
```
AzureSQLMI.Query(
    "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.xxxxx.database.windows.net;Database=mydatabase;Uid=username;Pwd=password;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no",
    "SELECT * FROM [schema].[tablename]"
)
```

## Connection String Example

The connector automatically builds connection strings in this format:
```
Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.xxxxx.database.windows.net;Database=mydatabase;Uid=username;Pwd=password;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no
```

## Key Features

### ApplicationIntent=ReadOnly
- **Hardcoded** in all connection strings
- Prevents accidental write operations
- Azure SQL MI recognizes this and routes queries through read-only replicas
- Improves performance for analytics and reporting workloads

### Security Settings
- **Encrypt=yes** - Enforces TLS encryption
- **TrustServerCertificate=no** - Validates server certificate
- Supports both SQL and Windows authentication

### Connection Pooling
ODBC driver automatically manages connection pooling for performance.

## Troubleshooting

### Connection Fails
1. Verify ODBC Driver 17 is installed: Run `odbcad32.exe`
2. Test connection with a DSN in ODBC Administrator
3. Verify firewall rules allow outbound to SQL MI port 1433
4. Check SQL MI network/public endpoint is enabled
5. Verify credentials and server name spelling

### Query Errors
- All queries are executed as READ-ONLY
- Write operations (INSERT, UPDATE, DELETE) will fail
- Use SELECT statements only
- Verify ApplicationIntent=ReadOnly appears in query details

### Performance Issues
- Connection pooling is automatic via ODBC
- Consider filtering data in WHERE clause
- Use indexed columns for better performance

## Architecture

```
Power Query User Interface
         ↓
M Language Connector (AzureSQLMI.ODBC.pq)
         ↓
ODBC Driver 17 for SQL Server
         ↓
Network/TLS Connection
         ↓
Azure SQL Managed Instance (Read-Only Intent)
```

## Connection String Components

| Component | Value | Purpose |
|-----------|-------|---------|
| Driver | ODBC Driver 17 for SQL Server | Database driver |
| Server | myserver.public.xxxxx.database.windows.net | SQL MI FQDN |
| Database | mydatabase | Target database |
| Uid | username | SQL login username |
| Pwd | password | SQL login password |
| ApplicationIntent | ReadOnly | **HARDCODED - Enforces read-only** |
| Encrypt | yes | Enable TLS encryption |
| TrustServerCertificate | no | Validate server cert |

## Limitations

1. **Read-only only** - All connections are read-only (by design)
2. **ODBC dependency** - Requires ODBC Driver 17+ 
3. **Network requirements** - SQL MI must be accessible from client
4. **Authentication** - Supports SQL and Windows auth only

## Performance Tips

1. Filter data client-side to reduce network traffic
2. Use indexes on WHERE clause columns
3. Request only needed columns in SELECT
4. Use native queries instead of table navigation when possible
5. Monitor ODBC connection pool settings

## API Reference

### AzureSQLMI.Contents
Main function for navigating tables and databases.

**Parameters:**
- `Server` (text, required) - SQL MI server name or FQDN
- `Database` (text, optional) - Database name (defaults to "master")
- `Username` (text, optional) - SQL login username
- `Password` (text, optional) - SQL login password
- `UseIntegratedSecurity` (logical, optional) - Use Windows auth (true/false)

**Returns:** Navigable table structure

### AzureSQLMI.Query
Execute direct SQL queries with ApplicationIntent=ReadOnly enforced.

**Parameters:**
- `ConnectionString` (text, required) - Full ODBC connection string
- `SqlQuery` (text, required) - T-SQL query to execute

**Returns:** Query result table

### BuildConnectionString
Internal helper to construct ODBC connection strings.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review SQL MI network requirements
3. Verify ODBC driver installation
4. Check Power Query custom connector requirements
5. Review connection string format

## Version History

- **1.0.0** - Initial release with ApplicationIntent=ReadOnly hardcoded

## License

This connector is provided as-is for use with Azure SQL Managed Instance.
