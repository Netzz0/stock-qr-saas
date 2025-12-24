# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy project file
COPY ["src/StockQR.Api/StockQR.Api.csproj", "src/StockQR.Api/"]
COPY ["src/StockQR.Application/StockQR.Application.csproj", "src/StockQR.Application/"]
COPY ["src/StockQR.Domain/StockQR.Domain.csproj", "src/StockQR.Domain/"]
COPY ["src/StockQR.Infrastructure/StockQR.Infrastructure.csproj", "src/StockQR.Infrastructure/"]

# Restore
RUN dotnet restore "src/StockQR.Api/StockQR.Api.csproj"

# Copy source
COPY . .

# Build
RUN dotnet build "src/StockQR.Api/StockQR.Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "src/StockQR.Api/StockQR.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

EXPOSE 5000

ENTRYPOINT ["dotnet", "StockQR.Api.dll"]
