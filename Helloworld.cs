#:sdk Microsoft.NET.Sdk.Web

var builder = WebApplication.CreateBuilder();

var app = builder.Build();

app.MapGet("/", () => "Hello, world!");

app.Run();