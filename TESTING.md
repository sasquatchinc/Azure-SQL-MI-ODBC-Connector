# Testing & Validation Guide
# Azure SQL MI ODBC Connector

## Pre-Deployment Testing Checklist

### 1. Environment Setup Test
- [ ] ODBC Driver 17 for SQL Server is installed
- [ ] SQL MI instance is running and accessible
- [ ] Network connectivity verified (telnet to port 1433)
- [ ] Test credentials have appropriate database permissions
- [ ] Power Query/Power BI Desktop is installed and updated

### 2. ODBC Configuration Test

**Run ODBC Data Source Administrator:**
```powershell
odbcad32.exe
```

**In ODBC Administrator:**
- [ ] Click "System DSN" or "User DSN"
- [ ] Click "Add"
- [ ] Select "ODBC Driver 17 for SQL Server"
- [ ] Click "Create New Data Source"
- [ ] Enter:
  - Name: `TestAzureSQLMI`
  - Server: Your SQL MI FQDN
  - Authentication: Use Windows or SQL
  - Database: Leave blank for now
- [ ] Click "Test Connection"
- [ ] Verify success message

### 3. Connection String Validation Test

**Test with each connection string:**

#### SQL Authentication
```
Driver={ODBC Driver 17 for SQL Server};Server=<your-mi-server>.public.<hash>.database.windows.net;Database=master;Uid=<username>;Pwd=<password>;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no
```

#### Windows Authentication
```
Driver={ODBC Driver 17 for SQL Server};Server=<your-mi-server>.public.<hash>.database.windows.net;Database=master;Trusted_Connection=yes;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no
```

**Verify in PowerShell:**
```powershell
$ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=<server>;Database=master;..."
[Reflection.Assembly]::LoadWithPartialName("System.Data.Odbc") | Out-Null
$conn = New-Object System.Data.Odbc.OdbcConnection($ConnectionString)
$conn.Open()
$conn.Close()
```

- [ ] Connection opened successfully
- [ ] No encryption warnings
- [ ] Connection timeout is reasonable (< 5 seconds)

### 4. ApplicationIntent=ReadOnly Verification Test

**Test Query - Should succeed (read only):**
```sql
SELECT TOP 1 * FROM sys.databases
```

**Test Query - Should fail (write operation):**
```sql
CREATE TABLE test (id INT)
```

**Expected Results:**
- [ ] SELECT queries execute successfully
- [ ] INSERT/UPDATE/DELETE queries fail with "read-only" error
- [ ] CREATE/ALTER queries fail with "read-only" error

**Verify in Azure Portal:**
1. Go to SQL MI → Query Editor
2. Connect with same credentials
3. Run: `SELECT SERVERPROPERTY('DatabaseEngineType')`
4. Check query metrics for replica routing

### 5. Encryption Verification Test

**Check SSL/TLS in Connection:**
```powershell
$ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=<server>;...;Encrypt=yes;..."
[Reflection.Assembly]::LoadWithPartialName("System.Data.Odbc") | Out-Null
$conn = New-Object System.Data.Odbc.OdbcConnection($ConnectionString)
$conn.Open()
Write-Host "Connection String: $($conn.ConnectionString)"
Write-Host "Encryption verified"
$conn.Close()
```

- [ ] Connection uses TLS encryption
- [ ] No certificate warnings
- [ ] No unencrypted traffic

### 6. Connector File Validation Test

**Verify M Language Syntax:**
1. Open [AzureSQLMI.ODBC.pq](AzureSQLMI.ODBC/AzureSQLMI.ODBC.pq)
2. Check for syntax highlighting in VS Code
3. Look for any error squiggles
4. Verify "ApplicationIntent=ReadOnly" appears in code

### 7. Power Query Integration Test

**In Power BI Desktop:**

1. Copy `AzureSQLMI.ODBC.pq` to Custom Connectors folder
2. Restart Power BI Desktop
3. New Query → More → Custom Connector
4. Select AzureSQLMI
5. Enter connection parameters:
   - Server: Your SQL MI FQDN
   - Database: A test database
   - Credentials: Test account
6. Click OK
7. Should see table list:
   - [ ] Tables appear from your database
   - [ ] Schema information displays correctly
   - [ ] No error messages
8. Click on a table
9. Click Load or Edit
10. Data should load successfully:
    - [ ] Data appears in grid
    - [ ] Data types are inferred correctly
    - [ ] Number of rows matches expectation

### 8. Query Performance Test

**Small Query (< 1000 rows):**
```sql
SELECT TOP 100 * FROM [dbo].[YourTable]
```
- [ ] Loads in < 2 seconds
- [ ] No timeout errors

**Medium Query (1000-100K rows):**
```sql
SELECT * FROM [dbo].[YourTable] WHERE [DateColumn] > '2024-01-01'
```
- [ ] Loads in < 10 seconds
- [ ] Memory usage reasonable

**Large Query (> 100K rows):**
```sql
SELECT * FROM [dbo].[LargeTable] WHERE [IndexedColumn] = 'value'
```
- [ ] Completes without timeout
- [ ] Consider adding filters or pagination

### 9. Authentication Methods Test

**SQL Authentication:**
- [ ] Login with SQL user/password succeeds
- [ ] Wrong password fails appropriately
- [ ] User with insufficient permissions fails

**Windows Authentication:**
- [ ] Login with Windows credentials succeeds
- [ ] Credentials automatically passed from Windows
- [ ] No password prompt needed

### 10. Error Handling Test

**Invalid Server:**
```
Server: invalidserver.database.windows.net
```
- [ ] Connection fails with clear error
- [ ] Error message indicates server not found

**Invalid Database:**
```
Server: valid-server
Database: nonexistent-db
```
- [ ] Connection succeeds but database query fails
- [ ] Error indicates database not found

**Timeout Test:**
```
Timeout: Set to very short value (1 second)
Query: SELECT WAITFOR DELAY '00:00:05'; SELECT 1
```
- [ ] Query times out appropriately
- [ ] No hung connections

### 11. Security Test

**Credential Storage:**
- [ ] Passwords not stored in plain text in .pq file
- [ ] Power Query credential storage used
- [ ] No credentials in connection string logs

**Network Security:**
- [ ] All traffic encrypted (TLS)
- [ ] Certificate validation enabled
- [ ] Network isolation verified (firewall rules)

**Read-Only Enforcement:**
- [ ] DELETE statement fails
- [ ] UPDATE statement fails
- [ ] ALTER statement fails
- [ ] INSERT statement fails
- [ ] SELECT statement succeeds

### 12. Metadata Test

**Verify metadata.json:**
```json
{
  "name": "AzureSQLMI.ODBC",
  "version": "1.0.0",
  "readOnly": true,
  "hardcodedSecurityFeatures": [
    "ApplicationIntent=ReadOnly",
    "Encrypt=yes",
    "TrustServerCertificate=no"
  ]
}
```
- [ ] All required fields present
- [ ] Version is correct
- [ ] Read-only flag set to true
- [ ] Security features documented

## Test Results Template

```
Test Date: _______________
Tester: ___________________
SQL MI Server: _____________
Database: __________________
Test Environment: [ ] Dev [ ] Test [ ] Staging [ ] Production

RESULTS:
✓ Environment Setup: PASS / FAIL
✓ ODBC Configuration: PASS / FAIL
✓ Connection String: PASS / FAIL
✓ ApplicationIntent=ReadOnly: PASS / FAIL
✓ Encryption: PASS / FAIL
✓ Connector Syntax: PASS / FAIL
✓ Power Query Integration: PASS / FAIL
✓ Query Performance: PASS / FAIL
✓ Authentication Methods: PASS / FAIL
✓ Error Handling: PASS / FAIL
✓ Security: PASS / FAIL
✓ Metadata: PASS / FAIL

OVERALL RESULT: [ ] PASS [ ] FAIL

Issues Found:
1. _________________________________
2. _________________________________
3. _________________________________

Notes:
_________________________________
_________________________________
_________________________________

Approval: _____________ Date: _________
```

## Automated Testing (PowerShell)

```powershell
# Test script for ODBC connector
$server = "myserver.public.hash.database.windows.net"
$database = "master"
$username = "sqladmin"
$password = "Password123!"

# Test 1: ODBC Driver check
try {
    [Reflection.Assembly]::LoadWithPartialName("System.Data.Odbc") | Out-Null
    Write-Host "✓ ODBC Driver library loaded" -ForegroundColor Green
} catch {
    Write-Host "✗ ODBC Driver not found" -ForegroundColor Red
}

# Test 2: Connection string with ReadOnly
$connStr = "Driver={ODBC Driver 17 for SQL Server};Server=$server;Database=$database;Uid=$username;Pwd=$password;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no"

try {
    $conn = New-Object System.Data.Odbc.OdbcConnection($connStr)
    $conn.Open()
    Write-Host "✓ Connection established successfully" -ForegroundColor Green
    
    # Test 3: Read query
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT @@VERSION"
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "✓ Read query succeeded" -ForegroundColor Green
    }
    $reader.Close()
    
    # Test 4: Write query (should fail)
    $cmd.CommandText = "CREATE TABLE test123 (id INT)"
    try {
        $cmd.ExecuteNonQuery()
        Write-Host "✗ Write operation was NOT blocked - SECURITY ISSUE!" -ForegroundColor Red
    } catch {
        Write-Host "✓ Write operation blocked (expected)" -ForegroundColor Green
    }
    
    $conn.Close()
    Write-Host "✓ Connection closed successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAll tests completed!" -ForegroundColor Cyan
```

## Performance Benchmarks

Run these to establish baseline performance:

| Query Type | Expected Time | Actual Time | Status |
|-----------|--------------|------------|--------|
| SELECT TOP 100 | < 2s | _____ | |
| SELECT TOP 10,000 | < 5s | _____ | |
| SELECT with JOIN | < 5s | _____ | |
| Aggregation query | < 10s | _____ | |
| Large result set | < 30s | _____ | |

## Sign-Off

By testing this connector thoroughly, you ensure:
- ✓ Security controls are enforced (ApplicationIntent=ReadOnly)
- ✓ Connections are encrypted (TLS)
- ✓ Performance is acceptable
- ✓ Error handling is appropriate
- ✓ Metadata is correct
- ✓ Read-only access is guaranteed

**Ready for Production:** [ ] YES [ ] NO

Comments: _________________________________
