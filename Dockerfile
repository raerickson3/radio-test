# syntax=docker/dockerfile:1

############################
# Build stage
############################
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the csproj first for better layer caching, then restore
COPY DemoActions/DemoApp/DemoApp.csproj DemoActions/DemoApp/
RUN dotnet restore DemoActions/DemoApp/DemoApp.csproj

# Copy the rest of the repo and publish
COPY . .
RUN dotnet publish DemoActions/DemoApp/DemoApp.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

############################
# Runtime stage
############################
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# .NET 8 ASP.NET images commonly listen on 8080 by default; we set it explicitly for clarity. [1](https://mcr.microsoft.com/en-us/product/dotnet/aspnet/about)[2](https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md)
# Kestrel reads ASPNETCORE_URLS to decide what address/port to bind. [3](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel/endpoints?view=aspnetcore-10.0)
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Run as non-root (good security posture)
RUN adduser --disabled-password --gecos "" appuser \
  && chown -R appuser:appuser /app
USER appuser

COPY --from=build /app/publish .

# If your assembly name differs, update this DLL name.
ENTRYPOINT ["dotnet", "DemoApp.dll"]