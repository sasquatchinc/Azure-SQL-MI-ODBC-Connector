# GitHub Setup Instructions
# Azure SQL MI ODBC Custom Connector

## Quick Summary
Your local repository is ready to push. Follow these steps to get it on GitHub:

## Step 1: Create Repository on GitHub (Web)

1. Go to https://github.com/new
2. Fill in repository details:
   - Repository name: `Azure-SQL-MI-ODBC-Connector`
   - Description: "ODBC-based Power Query custom connector for Azure SQL Managed Instance with ApplicationIntent=ReadOnly hardcoded"
   - Visibility: Public (recommended) or Private
   - Do NOT initialize with README, .gitignore, or license (we already have these)
3. Click "Create repository"

## Step 2: Push Code to GitHub

Run these commands in PowerShell (from project directory):

### Option A: Using HTTPS (Password/PAT Authentication)
```powershell
cd "c:\Users\SHAWJ050\Desktop\Projects\VS Code Stuffs\AzureSQL MI PQ Connector"

git remote add origin https://github.com/sasquatchinc/Azure-SQL-MI-ODBC-Connector.git
git branch -M main
git push -u origin main
```

When prompted for credentials:
- Username: sasquatchinc
- Password: Your Personal Access Token (PAT) from GitHub
  - Create one at: https://github.com/settings/tokens
  - Needs: repo, write:packages scopes
  - Store securely - you'll need it for future pushes

### Option B: Using SSH (Recommended for Security)
```powershell
cd "c:\Users\SHAWJ050\Desktop\Projects\VS Code Stuffs\AzureSQL MI PQ Connector"

git remote add origin git@github.com:sasquatchinc/Azure-SQL-MI-ODBC-Connector.git
git branch -M main
git push -u origin main
```

Requires SSH key setup:
1. Generate key: ssh-keygen -t ed25519 -C "your-email@example.com"
2. Add to GitHub: https://github.com/settings/keys
3. Run: eval "$(ssh-agent -s)" and ssh-add ~/.ssh/id_ed25519

## Step 3: Verify Push

Check your repository on GitHub:
- https://github.com/sasquatchinc/Azure-SQL-MI-ODBC-Connector

You should see:
✓ All files uploaded
✓ Initial commit with full message
✓ 13 files total
✓ Main branch set

## Repository Contents on GitHub

```
📦 Azure-SQL-MI-ODBC-Connector
├── 📁 AzureSQLMI.ODBC/
│   ├── AzureSQLMI.ODBC.pq          (Main connector - 250 lines M language)
│   ├── EXAMPLES.pq                 (8 usage examples)
│   ├── README.md                   (Technical documentation)
│   ├── metadata.json               (Connector metadata)
│   ├── CredentialUI.json           (Credential configuration)
│   └── Resources.resx              (Localization strings)
├── README.md                       (Project overview)
├── QUICKSTART.md                   (5-minute setup guide)
├── DEPLOYMENT.md                   (Enterprise deployment)
├── TESTING.md                       (Testing procedures)
├── INSTALLATION_CHECKLIST.md       (Installation steps)
├── PROJECT_SUMMARY.md              (Project summary)
├── .gitignore                      (Git ignore rules)
└── LICENSE (optional)              (Add later if desired)
```

## Next Steps After Push

### 1. Add GitHub Topics (Optional)
In GitHub repo settings → About section:
- Add topics: `power-query`, `azure-sql`, `odbc`, `custom-connector`, `power-bi`

### 2. Add License (Optional)
```powershell
# Add MIT License or your choice
git add LICENSE
git commit -m "Add MIT License"
git push
```

### 3. Create GitHub Release (Optional)
```
1. Go to Releases tab
2. Click "Create a new release"
3. Tag: v1.0.0
4. Title: Azure SQL MI ODBC Connector v1.0.0
5. Publish release
```

### 4. Enable GitHub Pages (Optional)
To create documentation site:
1. Go to Settings → Pages
2. Source: main branch /root
3. Create a docs folder with index.md

## Troubleshooting

### "remote origin already exists"
```powershell
git remote remove origin
git remote add origin https://github.com/sasquatchinc/Azure-SQL-MI-ODBC-Connector.git
```

### "fatal: not a git repository"
```powershell
cd "c:\Users\SHAWJ050\Desktop\Projects\VS Code Stuffs\AzureSQL MI PQ Connector"
git status  # Should show "On branch main"
```

### "Authentication failed"
- Check your GitHub username (sasquatchinc)
- If using PAT, verify it's not expired
- For SSH, ensure key is added to GitHub account

### "Everything up-to-date"
Already pushed! Check: https://github.com/sasquatchinc/Azure-SQL-MI-ODBC-Connector

## Future Updates

To update your GitHub repository with changes:

```powershell
cd "c:\Users\SHAWJ050\Desktop\Projects\VS Code Stuffs\AzureSQL MI PQ Connector"
git add .
git commit -m "Your commit message"
git push origin main
```

## Verify Local Setup

Current status:
```
Repository: Initialized ✓
Files: 13 ✓
Initial Commit: Created ✓
Branch: main
Remote: Pending
Status: Ready to push
```

---

Ready? Execute Step 2 (Option A or B) above to complete the push!
