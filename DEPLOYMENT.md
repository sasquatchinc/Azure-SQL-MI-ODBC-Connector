# Deployment & Installation Guide
# Azure SQL MI ODBC Connector for Power Query

## Overview

This guide covers installing, deploying, and maintaining the Azure SQL MI ODBC Connector across different environments and user bases.

## Pre-Deployment Requirements

### System Requirements
- **OS**: Windows 10 / Windows 11 / Windows Server 2019+
- **ODBC Driver**: ODBC Driver 17 for SQL Server (or 18 if available)
- **Power Query**: Latest version
- **Network**: Outbound access to Azure SQL MI (port 1433)
- **Disk Space**: ~2 MB for connector files

### Software Requirements

**Client Side:**
- Power BI Desktop v2.95+ OR
- Excel 2016+ with Power Query OR
- SQL Server Management Studio 18+ (optional)

**Server Side:**
- Azure SQL Managed Instance (Standard or Premium tier)
- Network endpoint enabled (public or private)

## Installation Methods

### Method 1: Manual Installation (Single User)

#### Step 1: Download Connector File
1. Obtain `AzureSQLMI.ODBC.pq` from the project repository
2. Verify file integrity (optional: check SHA-256 hash)

#### Step 2: Locate Custom Connectors Folder

**Power BI Desktop:**
```
C:\Users\<username>\Documents\Power BI Desktop\Custom Connectors
```

**Excel (Office 365):**
```
C:\Users\<username>\Documents\Power Query\Connectors
```

**Create folder if it doesn't exist:**
```powershell
# PowerShell as Administrator
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors" -Force
```

#### Step 3: Copy Connector File
```powershell
Copy-Item -Path "C:\path\to\AzureSQLMI.ODBC.pq" -Destination "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\"
```

#### Step 4: Install ODBC Driver
1. Download from: https://www.microsoft.com/download/details.aspx?id=50420
2. Run installer as Administrator
3. Accept default options
4. Restart computer when prompted

#### Step 5: Configure Power BI / Excel

**Power BI Desktop:**
1. File → Options and Settings → Options
2. Select "Security"
3. Under "Data Extensions", select:
   - ☑ "Allow any extension to load without validation or warning"
4. Click OK
5. Restart Power BI Desktop

**Excel:**
1. File → Options
2. Select "Trust Center"
3. Click "Trust Center Settings"
4. Select "Trusted Locations"
5. Click "Add New Location"
6. Browse to: `%USERPROFILE%\Documents\Power Query\Connectors`
7. Click OK

#### Step 6: Verify Installation
1. Open Power BI Desktop
2. New Query → From Other Sources
3. Search for "Azure SQL MI" or "AzureSQLMI"
4. Should appear in list

### Method 2: Enterprise Deployment (Group Policy)

#### For Organization-Wide Deployment:

**Step 1: Create Network Share**
```
\\fileserver\shared\PowerQuery\Connectors\
```

**Step 2: Deploy via Group Policy**

Create GPO with following settings:
```
Computer Configuration → Preferences → Windows Settings → File System

Source: \\fileserver\shared\PowerQuery\Connectors\AzureSQLMI.ODBC.pq
Destination: %USERPROFILE%\Documents\Power BI Desktop\Custom Connectors\
Action: Create
```

**Step 3: Registry Settings (Optional)**

For enterprise security settings:
```registry
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\PowerQuery\Security]
"ExtensionSecurityLevel"=dword:00000001
"AllowNonValidatedExtensions"=dword:00000001
```

**Step 4: Deploy via Intune (If using Intune)**
1. Create Win32 app package with deployment script
2. Assign to user/device groups
3. Set as available or required

### Method 3: Scripted Deployment (Automated)

**Deployment Script:**
```powershell
# Deploy-AzureSQLMIConnector.ps1
# Run as Administrator

param(
    [string]$ConnectorPath = "C:\Temp\AzureSQLMI.ODBC.pq",
    [string]$Environment = "PowerBI", # PowerBI or Excel
    [switch]$InstallODBC = $false
)

Write-Host "Azure SQL MI Connector Deployment Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if running as admin
$IsAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains [Security.Principal.SecurityIdentifier]"S-1-5-32-544"
if (-not $IsAdmin) {
    Write-Host "✗ This script must run as Administrator" -ForegroundColor Red
    exit 1
}

# Determine target folder
if ($Environment -eq "PowerBI") {
    $TargetFolder = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors"
    $AppName = "Power BI Desktop"
} else {
    $TargetFolder = "$env:USERPROFILE\Documents\Power Query\Connectors"
    $AppName = "Excel"
}

# Create folder if needed
if (-not (Test-Path $TargetFolder)) {
    Write-Host "Creating connector folder: $TargetFolder"
    New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    Write-Host "✓ Folder created" -ForegroundColor Green
}

# Copy connector file
if (Test-Path $ConnectorPath) {
    Copy-Item -Path $ConnectorPath -Destination $TargetFolder -Force
    Write-Host "✓ Connector installed: $TargetFolder" -ForegroundColor Green
} else {
    Write-Host "✗ Connector file not found: $ConnectorPath" -ForegroundColor Red
    exit 1
}

# Install ODBC Driver if requested
if ($InstallODBC) {
    Write-Host "Checking ODBC Driver 17 for SQL Server..."
    $ODBCDriver = Get-OdbcDriver -Name "ODBC Driver 17 for SQL Server" -ErrorAction SilentlyContinue
    
    if ($ODBCDriver) {
        Write-Host "✓ ODBC Driver 17 already installed" -ForegroundColor Green
    } else {
        Write-Host "⚠ ODBC Driver 17 not found. Please install from:" -ForegroundColor Yellow
        Write-Host "  https://www.microsoft.com/download/details.aspx?id=50420"
    }
}

# Configure security settings
Write-Host "Configuring security settings for $AppName..."

if ($Environment -eq "PowerBI") {
    # PowerBI Registry key
    $RegPath = "HKCU:\Software\Microsoft\Office\16.0\PowerBI\Settings\Power Query"
    
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Note: Power BI settings are typically configured via UI
    # Registry settings may not directly enable custom connectors
    Write-Host "⚠ Please manually enable custom connectors in Power BI Desktop:" -ForegroundColor Yellow
    Write-Host "  File → Options → Security → Data Extensions" -ForegroundColor Yellow
}

Write-Host "`n✓ Deployment completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Restart $AppName"
Write-Host "2. Test connector with your SQL MI credentials"
Write-Host "3. Review QUICKSTART.md for usage instructions"
```

**Run Deployment Script:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Deploy-AzureSQLMIConnector.ps1 -Environment PowerBI -InstallODBC $true
```

### Method 4: Docker Container Deployment

**Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install ODBC Driver
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://www.microsoft.com/download/confirmation.aspx?id=50420" \
    -OutFile odbc-driver.msi; \
    Start-Process msiexec.exe -ArgumentList "/i odbc-driver.msi /quiet /passive" -Wait

# Copy connector
COPY AzureSQLMI.ODBC.pq /connector/

# Set environment
ENV CONNECTOR_PATH=C:\connector\AzureSQLMI.ODBC.pq
ENV ODBC_DRIVER="ODBC Driver 17 for SQL Server"

WORKDIR /app
```

## Post-Deployment Configuration

### Step 1: Configure Firewall Rules

**Azure SQL MI Network Settings:**
1. Go to Azure Portal
2. SQL Managed Instance → Networking
3. Ensure "Public Endpoint" is enabled if needed
4. Add firewall rule for client IP range:
   - Rule name: `AllowPowerQueryClients`
   - Start IP: (your network range)
   - End IP: (your network range)

**Client Firewall (Windows Defender):**
```powershell
# Allow outbound to SQL MI
New-NetFirewallRule -DisplayName "Allow SQL MI Access" `
    -Direction Outbound -Action Allow -Protocol TCP `
    -RemotePort 1433 -RemoteAddress "20.0.0.0/8"
```

### Step 2: Test Connectivity

**From PowerShell:**
```powershell
$Server = "myserver.public.hash.database.windows.net"
$Port = 1433

try {
    $TCPClient = New-Object Net.Sockets.TcpClient
    $TCPClient.Connect($Server, $Port)
    Write-Host "✓ Network connectivity to SQL MI verified" -ForegroundColor Green
    $TCPClient.Close()
} catch {
    Write-Host "✗ Cannot reach SQL MI: $_" -ForegroundColor Red
}
```

### Step 3: Test ODBC Connection

**Test DSN:**
```powershell
$ConnStr = "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.hash.database.windows.net;Database=master;Uid=sqladmin;Pwd=Password123!;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no"

[Reflection.Assembly]::LoadWithPartialName("System.Data.Odbc") | Out-Null
$Conn = New-Object System.Data.Odbc.OdbcConnection($ConnStr)
try {
    $Conn.Open()
    Write-Host "✓ ODBC Connection successful" -ForegroundColor Green
    $Conn.Close()
} catch {
    Write-Host "✗ ODBC Connection failed: $_.Exception.Message" -ForegroundColor Red
}
```

### Step 4: Create Test Query

In Power BI or Excel, create a test query:
```m
AzureSQLMI.Contents(
    "myserver.public.hash.database.windows.net",
    "TestDatabase",
    "testuser",
    "testpassword",
    false
)
```

Verify tables appear from your database.

## Maintenance & Updates

### Updating the Connector

**Step 1: Backup Current Version**
```powershell
$ConnectorPath = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors"
Copy-Item "$ConnectorPath\AzureSQLMI.ODBC.pq" "$ConnectorPath\AzureSQLMI.ODBC.pq.backup"
```

**Step 2: Deploy New Version**
Copy new `AzureSQLMI.ODBC.pq` to connector folder

**Step 3: Restart Applications**
Close and reopen Power BI / Excel

**Step 4: Test**
Run test query to verify new version works

### Rollback Procedure

```powershell
$ConnectorPath = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors"
Move-Item "$ConnectorPath\AzureSQLMI.ODBC.pq.backup" "$ConnectorPath\AzureSQLMI.ODBC.pq" -Force
```

## Troubleshooting Deployment

| Issue | Cause | Solution |
|-------|-------|----------|
| Connector not found in Power BI | File not copied correctly | Verify file location matches custom connectors path |
| ODBC Driver error | Driver not installed | Run ODBC Driver installer |
| Connection refused | Firewall blocked | Check Azure SQL MI firewall rules |
| Authentication failed | Invalid credentials | Verify username/password in SQL MI |
| Permission denied | Running without admin | Run PowerShell as Administrator |

## Security Considerations

### File Permissions
```powershell
# Restrict connector file access
$ConnectorFile = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\AzureSQLMI.ODBC.pq"
$Acl = Get-Acl $ConnectorFile
$Acl.SetAccessRuleProtection($true, $true)
Set-Acl -Path $ConnectorFile -AclObject $Acl
```

### Credential Storage
- Never hardcode credentials in connector files
- Use Power Query credential storage
- Implement Windows authentication where possible
- Rotate SQL credentials regularly

### Compliance
- Document all connector deployments
- Maintain audit logs of connector usage
- Ensure connections use encryption (TLS)
- Verify ApplicationIntent=ReadOnly is enforced

## Uninstallation

**Manual Removal:**
```powershell
Remove-Item "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\AzureSQLMI.ODBC.pq"
```

**Via Scripted Removal:**
```powershell
# Uninstall-AzureSQLMIConnector.ps1
$ConnectorPath = "$env:USERPROFILE\Documents\Power BI Desktop\Custom Connectors\AzureSQLMI.ODBC.pq"
if (Test-Path $ConnectorPath) {
    Remove-Item $ConnectorPath -Force
    Write-Host "✓ Connector removed" -ForegroundColor Green
}
```

## Support & Documentation

- **README.md** - Full feature documentation
- **QUICKSTART.md** - 5-minute setup guide
- **TESTING.md** - Testing & validation guide
- **EXAMPLES.pq** - Code examples and use cases
- **metadata.json** - Connector metadata and configuration

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-XX-XX | Initial release with ApplicationIntent=ReadOnly hardcoded |

---

**For support:** Contact your IT department or refer to documentation files included in the connector package.
