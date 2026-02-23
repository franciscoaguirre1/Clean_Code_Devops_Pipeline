using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// 1. Obtener la cadena de conexión de Azure
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// 2. Registrar el DbContext para usar SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 1. Move Swagger OUTSIDE the If-block for easier testing
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Product API V1");
    c.RoutePrefix = string.Empty; // This makes Swagger the Home Page!
});

// Mock Data for Sprint 1
var products = new List<Product>
{
    new(1, "Mechanical Keyboard", "Electronics", 120.00m, 15),
    new(2, "Wireless Mouse", "Electronics", 45.00m, 0),
    new(3, "Clean Code Book", "Books", 35.00m, 50),
    new(4, "DevOps Handbook", "Books", 40.00m, 10),
    new(5, "Office Chair", "Furniture", 250.00m, 5)
};

// 2. The LINQ Filtering Endpoint
app.MapGet("/api/products", (string? category, decimal? maxPrice, bool? inStock) =>
{
    var query = products.AsQueryable();

    if (!string.IsNullOrEmpty(category))
        query = query.Where(p => p.Category.Equals(category, StringComparison.OrdinalIgnoreCase));

    if (maxPrice.HasValue)
        query = query.Where(p => p.Price <= maxPrice.Value);

    if (inStock.HasValue && inStock.Value)
        query = query.Where(p => p.Stock > 0);

    return Results.Ok(query.ToList());
})
.WithName("GetProducts")
.WithOpenApi();

app.Run();

// 3. ALL records/classes MUST go at the very bottom!
public record Product(int Id, string Name, string Category, decimal Price, int Stock);


public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Product> Products => Set<Product>();
}