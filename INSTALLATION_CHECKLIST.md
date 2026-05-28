# Installation Checklist
# Azure SQL MI ODBC Power Query Connector

Use this checklist to ensure proper installation and configuration.

## Pre-Installation Checklist

### System Verification
- [ ] Windows 10/11 or Windows Server 2019+ installed
- [ ] User has Administrator privileges
- [ ] Internet connection available for downloads
- [ ] 2 GB free disk space available
- [ ] No conflicting ODBC drivers installed

### Software Verification
- [ ] Power BI Desktop installed (v2.95+) OR Excel with Power Query
  - Power BI: Version: _____________
  - Excel: Version: _____________
- [ ] .NET Framework 4.7+ installed
- [ ] Windows PowerShell 5.0+ available

### Network Verification
- [ ] Can ping SQL MI server (if accessible)
- [ ] Port 1433 (TCP) is accessible to SQL MI
- [ ] No proxy blocking outbound connections
- [ ] SSL/TLS capability available

### Azure SQL MI Verification
- [ ] SQL Managed Instance created and running
- [ ] Instance name: _________________________________
- [ ] Public endpoint enabled (if using): [ ] Yes [ ] No
- [ ] Private endpoint configured (if using): [ ] Yes [ ] No
- [ ] Test database exists
- [ ] Test login account created
- [ ] Test account has READ permissions

---

## Installation Steps

### Step 1: Download & Prepare Connector File

- [ ] Download connector package from repository
- [ ] Extract contents if zipped
- [ ] Verify `AzureSQLMI.ODBC.pq` file present
- [ ] File size is ~10 KB: _________________ KB
- [ ] File modified date is recent: _________________

### Step 2: Install ODBC Driver

**Check if already installed:**
```powershell
Get-OdbcDriver -Name "ODBC Driver 17 for SQL Server" -ErrorAction SilentlyContinue
```

- [ ] Output confirms driver already installed: [ ] Yes [ ] No

**If not installed, download and install:**

- [ ] Download from: https://www.microsoft.com/download/details.aspx?id=50420
- [ ] Run installer as Administrator
- [ ] Accept default options
- [ ] Accept Microsoft ODBC Driver EULA: [ ] Yes
- [ ] Installation completed successfully: [ ] Yes [ ] No
- [ ] Computer restart performed: [ ] Yes [ ] No
- [ ] Verify installation after restart:

```powershell
Get-OdbcDriver -Name "ODBC Driver 17 for SQL Server"
```

- [ ] Driver version: _________________________________

### Step 3: Create Custom Connectors Folder

**For Power BI Desktop:**
```powershell
$Path = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors"
New-Item -ItemType Directory -Path $Path -Force
```

- [ ] Folder created: $Path
- [ ] Folder path verified: _________________________________

**For Excel:**
```powershell
$Path = "$env:USERPROFILE\Documents\Power Query\Connectors"
New-Item -ItemType Directory -Path $Path -Force
```

- [ ] Folder created: $Path
- [ ] Folder path verified: _________________________________

### Step 4: Copy Connector File

**Verify source file exists:**
```powershell
Test-Path "C:\path\to\AzureSQLMI.ODBC.pq"
```

- [ ] Source file found: [ ] Yes [ ] No
- [ ] Source path: _________________________________

**Copy to destination:**
```powershell
# For Power BI Desktop
Copy-Item "C:\path\to\AzureSQLMI.ODBC.pq" "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\" -Force
```

- [ ] File copied successfully
- [ ] Destination verified:
```powershell
Test-Path "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\AzureSQLMI.ODBC.pq"
```

- [ ] File found at destination: [ ] Yes [ ] No
- [ ] File size matches: [ ] Yes [ ] No

### Step 5: Configure Power BI Desktop

- [ ] Close all Power BI Desktop instances
- [ ] Open Power BI Desktop
- [ ] Go to: File → Options and Settings → Options
- [ ] Select: Security
- [ ] Find: "Data Extensions"
- [ ] Change to: "Allow any extension to load without validation or warning"
- [ ] Click: OK
- [ ] Exit Power BI Desktop completely
- [ ] Restart Power BI Desktop
- [ ] Power BI version after restart: _________________________________

**Verify Connector Appears:**
- [ ] New Query → From Other Sources
- [ ] Search for "AzureSQLMI" or "Azure SQL"
- [ ] Connector listed: [ ] Yes [ ] No

### Step 6: Configure Excel (if needed)

- [ ] Close all Excel instances
- [ ] Open Excel
- [ ] Go to: File → Options
- [ ] Select: Trust Center
- [ ] Click: Trust Center Settings
- [ ] Select: Trusted Locations
- [ ] Click: Add New Location
- [ ] Browse to: `$env:USERPROFILE\Documents\Power Query\Connectors`
- [ ] Click: OK
- [ ] Click: OK to close all dialogs
- [ ] Exit and restart Excel

---

## Testing & Validation

### Test 1: Connector Availability

**In Power BI Desktop:**

1. New Query
2. From Other Sources
3. Search for "AzureSQLMI"
4. Should appear in results

- [ ] Connector appears in UI: [ ] Yes [ ] No
- [ ] Connector name: _________________________________
- [ ] Can select connector: [ ] Yes [ ] No

### Test 2: ODBC Connection

**Run in PowerShell:**
```powershell
[Reflection.Assembly]::LoadWithPartialName("System.Data.Odbc") | Out-Null
$conn = New-Object System.Data.Odbc.OdbcConnection("Driver={ODBC Driver 17 for SQL Server};Server=<your-mi-server>;Database=master")
$conn.Open()
$conn.Close()
```

- [ ] Script runs without errors: [ ] Yes [ ] No
- [ ] Connection successful: [ ] Yes [ ] No
- [ ] Error (if any): _________________________________

### Test 3: Credential Setup

**In Power BI Desktop:**

1. New Query → From Other Sources → AzureSQLMI
2. Enter SQL MI server FQDN
3. Enter test database name
4. Enter test username/password
5. Click OK

- [ ] Connector prompts for credentials: [ ] Yes [ ] No
- [ ] Authentication options shown: [ ] Yes [ ] No
- [ ] Can proceed to next step: [ ] Yes [ ] No
- [ ] Error message (if any): _________________________________

### Test 4: Table Navigation

**In Power Query Editor:**

After connecting, should see:
- [ ] List of tables appears: [ ] Yes [ ] No
- [ ] Tables grouped by schema: [ ] Yes [ ] No
- [ ] Sample table visible: _________________________________
- [ ] Can select table: [ ] Yes [ ] No

### Test 5: Data Loading

**Select a table and load data:**

1. Click table name
2. Click Load or Edit
3. Data should appear in Power Query

- [ ] Data loaded successfully: [ ] Yes [ ] No
- [ ] Row count: _________________________________
- [ ] Column count: _________________________________
- [ ] Data preview visible: [ ] Yes [ ] No
- [ ] No errors in load: [ ] Yes [ ] No

### Test 6: ReadOnly Verification

**Verify ApplicationIntent=ReadOnly is enforced:**

```sql
-- Try to create a table (should fail)
CREATE TABLE test_table (id INT)
```

- [ ] Write operation blocked: [ ] Yes [ ] No
- [ ] Error message received: [ ] Yes [ ] No
- [ ] Error indicates read-only: [ ] Yes [ ] No

**Try to read data (should succeed):**

```sql
SELECT TOP 1 * FROM sys.tables
```

- [ ] Read operation succeeded: [ ] Yes [ ] No
- [ ] Data returned: [ ] Yes [ ] No

---

## Post-Installation Configuration

### Security Setup

- [ ] Credentials stored in Power Query credential manager: [ ] Yes [ ] No
- [ ] No passwords saved in Power BI files: [ ] Yes [ ] No
- [ ] Windows authentication configured (if applicable): [ ] Yes [ ] No
- [ ] TLS encryption verified: [ ] Yes [ ] No

### Performance Configuration

- [ ] Query timeout adjusted if needed: _________________ seconds
- [ ] Connection pooling enabled: [ ] Yes [ ] No (automatic)
- [ ] Network performance verified: _________________ ms latency

### Backup & Documentation

- [ ] Backup copy of connector file created: [ ] Yes [ ] No
- [ ] Backup location: _________________________________
- [ ] Documentation saved locally: [ ] Yes [ ] No
- [ ] Connection details documented securely: [ ] Yes [ ] No

---

## Troubleshooting Performed

### Issues Encountered & Resolutions

| Issue | Resolution | Status |
|-------|-----------|--------|
| | | [ ] Resolved [ ] Pending |
| | | [ ] Resolved [ ] Pending |
| | | [ ] Resolved [ ] Pending |

### Common Fixes Applied

- [ ] Restarted Power BI Desktop
- [ ] Cleared Power Query cache (if needed)
- [ ] Reinstalled ODBC driver
- [ ] Updated Power BI/Excel to latest version
- [ ] Verified network connectivity
- [ ] Checked SQL MI firewall rules
- [ ] Verified credentials

---

## Final Verification

### Ready for Production

- [ ] All checklist items completed
- [ ] All tests passed
- [ ] No unresolved issues
- [ ] Documentation reviewed
- [ ] Backup procedures established
- [ ] Security review completed
- [ ] Performance acceptable
- [ ] Ready for daily use: [ ] Yes [ ] No

### Sign-Off

| Item | Status |
|------|--------|
| Installation Complete | [ ] Yes [ ] No |
| Testing Complete | [ ] Yes [ ] No |
| Documentation Complete | [ ] Yes [ ] No |
| Ready for Use | [ ] Yes [ ] No |
| Approved by | _________________ |
| Date | _________________ |
| Approval Signature | _________________ |

---

## Maintenance Checklist (Ongoing)

### Monthly

- [ ] Verify connector still works
- [ ] Check for ODBC driver updates
- [ ] Monitor SQL MI performance
- [ ] Review query logs

### Quarterly

- [ ] Backup connector files
- [ ] Review security settings
- [ ] Test disaster recovery procedure
- [ ] Update documentation if needed

### Annually

- [ ] Full security audit
- [ ] Performance review
- [ ] Update compliance documentation
- [ ] Plan for next version

---

## Support Contact Information

| Role | Contact | Phone | Email |
|------|---------|-------|-------|
| Admin | | | |
| DBA | | | |
| BI Lead | | | |
| IT Support | | | |

---

## Notes & Comments

Use this space for any additional notes, issues, or observations:

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

---

## Document Information

| Field | Value |
|-------|-------|
| Document Title | Installation Checklist |
| Version | 1.0 |
| Date Created | _________________ |
| Date Completed | _________________ |
| Completed By | _________________ |
| Reviewed By | _________________ |
| Approved By | _________________ |

---

**Installation Process Complete!** ✓

Your Azure SQL MI ODBC Power Query Connector is now ready for use.

**Next Steps:**
1. Begin using connector in Power BI/Excel
2. Review EXAMPLES.pq for advanced usage
3. Monitor initial query performance
4. Provide feedback on connector experience
5. Report any issues to support team
