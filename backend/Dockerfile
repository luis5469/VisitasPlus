FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/VisitaPDV.API/VisitaPDV.API.csproj", "src/VisitaPDV.API/"]
COPY ["src/VisitaPDV.Application/VisitaPDV.Application.csproj", "src/VisitaPDV.Application/"]
COPY ["src/VisitaPDV.Infrastructure/VisitaPDV.Infrastructure.csproj", "src/VisitaPDV.Infrastructure/"]
COPY ["src/VisitaPDV.Domain/VisitaPDV.Domain.csproj", "src/VisitaPDV.Domain/"]
RUN dotnet restore "src/VisitaPDV.API/VisitaPDV.API.csproj"
COPY . .
WORKDIR "/src/src/VisitaPDV.API"
RUN dotnet build "VisitaPDV.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "VisitaPDV.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "VisitaPDV.API.dll"]
