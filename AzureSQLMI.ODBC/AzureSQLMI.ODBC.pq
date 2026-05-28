section AzureSQLMI;

// Azure SQL Managed Instance ODBC Connector
// ReadOnly connector with ApplicationIntent=ReadOnly hardcoded
// Version 1.0

// Connection String Builder
BuildConnectionString = (
    optional Server as text,
    optional Database as text,
    optional Username as text,
    optional Password as text,
    optional UseIntegratedSecurity as logical
) as text =>
    let
        DefaultDriver = "ODBC Driver 17 for SQL Server",
        
        // Build base connection string with mandatory ApplicationIntent=ReadOnly
        ConnectionParts = {
            "Driver={" & DefaultDriver & "}",
            if Server <> null then "Server=" & Server else null,
            if Database <> null then "Database=" & Database else null,
            if UseIntegratedSecurity then "Trusted_Connection=yes" else null,
            if not UseIntegratedSecurity and Username <> null then "Uid=" & Username else null,
            if not UseIntegratedSecurity and Password <> null then "Pwd=" & Password else null,
            "ApplicationIntent=ReadOnly",  // HARDCODED - Enforces read-only access
            "Encrypt=yes",
            "TrustServerCertificate=no"
        },
        
        // Filter out null values and join
        FilteredParts = List.Select(ConnectionParts, each _ <> null),
        Result = Text.Combine(FilteredParts, ";")
    in
        Result;

// Main connector function
[DataSource.Kind="AzureSQLMI", Publish="1.0.0"]
shared AzureSQLMI.Contents = (
    Server as text,
    optional Database as text,
    optional Username as text,
    optional Password as text,
    optional UseIntegratedSecurity as logical
) as table =>
    let
        // Default parameters
        UseIntSec = if UseIntegratedSecurity = null then false else UseIntegratedSecurity,
        DbName = if Database = null or Database = "" then "master" else Database,
        
        // Build connection string with ReadOnly enforcement
        ConnectionString = BuildConnectionString(
            Server,
            DbName,
            Username,
            Password,
            UseIntSec
        ),
        
        // Execute query to get available tables
        Sql = "
            SELECT 
                TABLE_SCHEMA,
                TABLE_NAME,
                TABLE_TYPE
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE'
            ORDER BY TABLE_SCHEMA, TABLE_NAME
        ",
        
        // Connect using ODBC driver
        OdbcConnection = Odbc.Query(ConnectionString, Sql),
        
        // Transform results into navigable structure
        TableList = Table.ToRecords(OdbcConnection),
        
        // Create navigation table
        NavTable = Table.FromRecords(
            List.Transform(TableList, each [
                Name = [TABLE_SCHEMA] & "." & [TABLE_NAME],
                Key = [TABLE_SCHEMA] & "." & [TABLE_NAME],
                Data = GetTable(ConnectionString, [TABLE_SCHEMA], [TABLE_NAME]),
                ItemKind = "Table",
                ItemName = "Table",
                IsLeaf = true
            ]),
            {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}
        ),
        
        NavTableWithNav = Table.ToNavigationTable(NavTable, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTableWithNav;

// Helper function to retrieve table data
GetTable = (ConnectionString as text, Schema as text, TableName as text) as table =>
    let
        Sql = "SELECT * FROM [" & Schema & "].[" & TableName & "]",
        Result = Odbc.Query(ConnectionString, Sql, [QuoteChar="#(lf)"])
    in
        Result;

// Direct query execution with ReadOnly enforcement
[DataSource.Kind="AzureSQLMI", Publish="1.0.0"]
shared AzureSQLMI.Query = (
    ConnectionString as text,
    SqlQuery as text
) as table =>
    let
        // Ensure ApplicationIntent=ReadOnly is in connection string
        FinalConnectionString = if Text.Contains(ConnectionString, "ApplicationIntent", Comparer.OrdinalIgnoreCase) then
            ConnectionString
        else
            ConnectionString & ";ApplicationIntent=ReadOnly",
        
        Result = Odbc.Query(FinalConnectionString, SqlQuery)
    in
        Result;

// Credentials support
AzureSQLMI = [
    TestConnection = (connectionString) => 
        let
            parts = Text.Split(connectionString, ";"),
            serverPart = List.First(List.Select(parts, each Text.StartsWith(_, "Server", Comparer.OrdinalIgnoreCase)), ""),
            hasReadOnly = List.AnyTrue(List.Transform(parts, each Text.Contains(_, "ApplicationIntent=ReadOnly", Comparer.OrdinalIgnoreCase)))
        in
            {"AzureSQLMI.Contents", serverPart, if hasReadOnly then "ReadOnly Mode Active" else "WARNING: ReadOnly not set"}
];

// Connection UI
[DataSource.Kind="AzureSQLMI"]
shared AzureSQLMI.UI = [
    Beta = true,
    Category = "Database",
    ButtonText = { "Azure SQL MI (ODBC - ReadOnly)" },
    LeafTableVisible = true,
    SourceImage = AzureSQLMI.Icons,
    SourceTypeImage = AzureSQLMI.Icons
];

AzureSQLMI.Icons = [
    Icon16 = { 0, 0 },
    Icon32 = { 0, 0 }
];

// Authentication support
AzureSQLMI.Authentication = [
    UsernamePassword = [
        UsernameLabel = "SQL Login",
        PasswordLabel = "Password"
    ],
    Windows = [
        Label = "Integrated Security"
    ]
];
