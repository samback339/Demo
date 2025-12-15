# ========== 第一階段：建置階段 ==========
# 使用完整的 .NET 8.0 SDK 映像來編譯程式
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# 設定工作目錄為 /src
WORKDIR /src

# 複製所有專案文件到容器中
COPY . .

# 編譯並發佈應用程式
# -c Release: 使用 Release 模式編譯（優化效能）
# -o /app: 輸出到 /app 目錄
RUN dotnet publish Demo/Demo.csproj -c Release -o /app

# ========== 第二階段：執行階段 ==========
# 使用輕量的 .NET 8.0 Runtime 映像（不含 SDK，體積更小）
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# 設定工作目錄為 /app
WORKDIR /app

# 從建置階段複製編譯好的文件到當前映像
COPY --from=build /app .

# 開放 8080 端口供外部訪問
EXPOSE 8080

# 設定環境變數：讓應用程式監聽所有網路介面的 8080 端口
ENV ASPNETCORE_URLS=http://+:8080

# 容器啟動時執行的命令：運行 Demo.dll
ENTRYPOINT ["dotnet", "Demo.dll"]
