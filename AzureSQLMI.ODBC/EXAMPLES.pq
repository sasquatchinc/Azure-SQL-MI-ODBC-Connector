// Power Query M Language - Example Usage
// Azure SQL Managed Instance ODBC Connector Examples

// ============================================
// EXAMPLE 1: Basic Connection with SQL Auth
// ============================================
let
    Server = "myserver.public.abc123xyz.database.windows.net",
    Database = "MyDatabase",
    Username = "sqladmin",
    Password = "YourStrongPassword123!",
    UseWindowsAuth = false,
    
    Source = AzureSQLMI.Contents(Server, Database, Username, Password, UseWindowsAuth),
    
    // Navigate to specific table
    SchemaData = Source{[ItemName="dbo.Customers"]}[Data]
in
    SchemaData


// ============================================
// EXAMPLE 2: Connection with Windows Auth
// ============================================
let
    Server = "myserver.public.abc123xyz.database.windows.net",
    Database = "MyDatabase",
    UseWindowsAuth = true,
    
    Source = AzureSQLMI.Contents(Server, Database, null, null, UseWindowsAuth),
    
    // Filter to specific table
    Orders = Source{[ItemName="dbo.Orders"]}[Data],
    
    // Apply additional filtering
    FilteredOrders = Table.SelectRows(Orders, each [OrderDate] >= #date(2024, 1, 1))
in
    FilteredOrders


// ============================================
// EXAMPLE 3: Direct SQL Query
// ============================================
let
    ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.abc123xyz.database.windows.net;Database=MyDatabase;Uid=sqladmin;Pwd=YourStrongPassword123!;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no",
    
    Query = "
        SELECT TOP 1000
            CustomerID,
            CustomerName,
            Email,
            Phone,
            RegistrationDate
        FROM dbo.Customers
        WHERE Status = 'Active'
        ORDER BY RegistrationDate DESC
    ",
    
    Source = AzureSQLMI.Query(ConnectionString, Query)
in
    Source


// ============================================
// EXAMPLE 4: Complex Query with Joins
// ============================================
let
    ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.abc123xyz.database.windows.net;Database=MyDatabase;Uid=sqladmin;Pwd=YourStrongPassword123!;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no",
    
    Query = "
        SELECT
            c.CustomerID,
            c.CustomerName,
            o.OrderID,
            o.OrderDate,
            o.TotalAmount,
            CONVERT(VARCHAR(10), o.OrderDate, 120) as OrderDateFormatted
        FROM dbo.Customers c
        INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
        WHERE YEAR(o.OrderDate) = 2024
        ORDER BY o.OrderDate DESC
    ",
    
    Source = AzureSQLMI.Query(ConnectionString, Query),
    
    // Type inference
    TypedData = Table.TransformColumnTypes(Source, {
        {"CustomerID", Int64.Type},
        {"CustomerName", Text.Type},
        {"OrderID", Int64.Type},
        {"OrderDate", type datetime},
        {"TotalAmount", type number},
        {"OrderDateFormatted", Text.Type}
    })
in
    TypedData


// ============================================
// EXAMPLE 5: Parameterized Query
// ============================================
let
    // Define parameters
    StartDate = #date(2024, 1, 1),
    EndDate = #date(2024, 12, 31),
    MinAmount = 1000,
    
    ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.abc123xyz.database.windows.net;Database=MyDatabase;Uid=sqladmin;Pwd=YourStrongPassword123!;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no",
    
    Query = "
        SELECT
            c.CustomerName,
            COUNT(*) as OrderCount,
            SUM(o.TotalAmount) as TotalSpent,
            AVG(o.TotalAmount) as AvgOrderAmount
        FROM dbo.Customers c
        INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
        WHERE o.OrderDate BETWEEN '" & Date.ToText(StartDate, "yyyy-MM-dd") & "' AND '" & Date.ToText(EndDate, "yyyy-MM-dd") & "'
            AND o.TotalAmount >= " & Text.From(MinAmount) & "
        GROUP BY c.CustomerName
        HAVING COUNT(*) > 1
        ORDER BY TotalSpent DESC
    ",
    
    Source = AzureSQLMI.Query(ConnectionString, Query)
in
    Source


// ============================================
// EXAMPLE 6: Using Table Navigation
// ============================================
let
    Source = AzureSQLMI.Contents(
        "myserver.public.abc123xyz.database.windows.net",
        "MyDatabase",
        "sqladmin",
        "YourStrongPassword123!",
        false
    ),
    
    // List all available tables
    Tables = Source,
    
    // Convert to list for viewing
    TableList = Tables[Content]
in
    TableList


// ============================================
// EXAMPLE 7: Error Handling
// ============================================
let
    Server = "myserver.public.abc123xyz.database.windows.net",
    Database = "MyDatabase",
    Username = "sqladmin",
    Password = "YourStrongPassword123!",
    
    TryConnect = try AzureSQLMI.Contents(
        Server,
        Database,
        Username,
        Password,
        false
    ) catch (error) error,
    
    Result = if TryConnect is table then
        TryConnect
    else
        error "Connection failed: " & error[Message]
in
    Result


// ============================================
// EXAMPLE 8: Combining Multiple Queries
// ============================================
let
    ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=myserver.public.abc123xyz.database.windows.net;Database=MyDatabase;Uid=sqladmin;Pwd=YourStrongPassword123!;ApplicationIntent=ReadOnly;Encrypt=yes;TrustServerCertificate=no",
    
    // Get all customers
    CustomersQuery = "SELECT * FROM dbo.Customers WHERE Status = 'Active'",
    Customers = AzureSQLMI.Query(ConnectionString, CustomersQuery),
    
    // Get recent orders
    OrdersQuery = "
        SELECT TOP 10000 * FROM dbo.Orders 
        WHERE OrderDate >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
        ORDER BY OrderDate DESC
    ",
    Orders = AzureSQLMI.Query(ConnectionString, OrdersQuery),
    
    // Merge the tables
    Merged = Table.NestedJoin(Customers, {"CustomerID"}, Orders, {"CustomerID"}, "Orders")
in
    Merged


// ============================================
// KEY POINTS FOR ALL EXAMPLES:
// ============================================
// 1. ApplicationIntent=ReadOnly is HARDCODED
// 2. All connections use ODBC Driver 17
// 3. Encryption is enabled (Encrypt=yes)
// 4. Certificate validation is enabled
// 5. Replace server names with your actual SQL MI FQDN
// 6. Replace database names with your actual database
// 7. Replace credentials with your actual credentials
// 8. Use Windows auth when possible (more secure than password)
