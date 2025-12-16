# Demo - .NET 8.0 Web API 專案

這是一個使用 .NET 8.0 開發的 Web API 專案，支援使用 Docker 和 Jenkins 進行自動化部署。

## 📋 目錄

- [專案簡介](#專案簡介)
- [快速開始](#快速開始)
- [使用 Docker 啟動 Jenkins](#使用-docker-啟動-jenkins)
- [配置 Jenkins Pipeline](#配置-jenkins-pipeline)
- [部署方式](#部署方式)
- [常用指令](#常用指令)

---

## 專案簡介

- **框架**: ASP.NET Core 8.0
- **類型**: Web API
- **API 文檔**: Swagger UI
- **端口**: 8080

### API 端點

- `GET /hello` - 返回 "hello world"
- `GET /weatherforecast` - 返回天氣預報數據
- `GET /swagger` - Swagger API 文檔

---

## 使用 Docker 啟動 Jenkins

### 步驟 0：安裝 Docker

在開始之前，請確保你的電腦已安裝 Docker。

#### macOS

1. 下載 Docker Desktop for Mac：
   - 前往 [Docker 官網](https://www.docker.com/products/docker-desktop/)
   - 下載 Docker Desktop for Mac（Apple Silicon 或 Intel 版本）

2. 安裝 Docker Desktop：
   - 雙擊下載的 `.dmg` 文件
   - 拖動 Docker 圖標到應用程式資料夾
   - 打開 Docker Desktop 並等待啟動完成

3. 驗證安裝：
   ```bash
   docker --version
   docker ps
   ```

#### Windows

1. 下載 Docker Desktop for Windows：
   - 前往 [Docker 官網](https://www.docker.com/products/docker-desktop/)
   - 下載 Docker Desktop for Windows

2. 安裝 Docker Desktop：
   - 執行安裝程式
   - 確保啟用 WSL 2（Windows Subsystem for Linux 2）
   - 重啟電腦

3. 驗證安裝：
   ```powershell
   docker --version
   docker ps
   ```

### 步驟 1：創建 Jenkins 數據目錄

```bash
# 在電腦的任意位置創建 jenkins_home 目錄（用於持久化 Jenkins 數據）
mkdir jenkins_home

# 設置權限（重要！）
chmod 777 jenkins_home
```

### 步驟 2：啟動 Jenkins 容器

```bash
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**參數說明：**
- `-d`: 在背景執行
- `--name jenkins`: 容器名稱為 jenkins
- `-p 8081:8080`: Jenkins Web 界面映射到主機的 8081 端口
- `-p 50000:50000`: Jenkins agent 通訊端口
- `-v /var/run/docker.sock:/var/run/docker.sock`: 讓 Jenkins 可以使用主機的 Docker
- `-v $(pwd)/jenkins_home:/var/jenkins_home`: 持久化 Jenkins 數據

### 步驟 3：獲取初始管理員密碼

```bash
# 查看 Jenkins 日誌，找到初始密碼
docker logs jenkins

# 或直接從文件讀取
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 步驟 4：訪問 Jenkins

1. 打開瀏覽器訪問：`http://localhost:8081`
2. 輸入步驟 3 獲取的初始密碼
3. 選擇「安裝建議的插件」
4. 創建第一個管理員帳號
5. 完成安裝

### 步驟 5：安裝 Docker 相關插件（可選）

Jenkins 已經可以使用主機的 Docker，但如果需要更多功能：

1. 進入 Jenkins → 管理 Jenkins → 插件管理
2. 搜索並安裝以下插件：
   - Docker Pipeline
   - Docker plugin

### 步驟 6：讓 Jenkins 容器能執行 Docker 指令

```bash
# 進入 Jenkins 容器
docker exec -it -u root jenkins bash

# 安裝 Docker CLI
apt-get update
apt-get install -y docker.io

# 設置權限
chmod 666 /var/run/docker.sock

# 退出容器
exit
```

---

## 配置 Jenkins Pipeline

### 方式 1：從 Git 倉庫創建 Pipeline

1. 在 Jenkins 首頁點擊「新增作業」
2. 輸入作業名稱（例如：`demo-app-pipeline`）
3. 選擇「Pipeline」，點擊「確定」
4. 在「Pipeline」區塊選擇「Pipeline script from SCM」
5. SCM 選擇「Git」
6. 輸入倉庫 URL
7. Script Path 填入：`Jenkinsfile`
8. 點擊「儲存」

### 執行 Pipeline

1. 點擊「立即建置」
2. 查看建置過程和日誌
3. 建置成功後，訪問 `http://localhost:8080/hello`

---

### 🔧 Jenkins 自動化部署

1. 推送代碼到 Git 倉庫
2. 在 Jenkins 中點擊「立即建置」
3. Jenkins 自動執行：
   - 拉取最新代碼
   - 建置 Docker 映像
   - 停止舊容器
   - 啟動新容器

---

## 📁 專案結構

```
Demo/
├── Demo/                    # 主要專案目錄
│   ├── Program.cs          # 應用程式入口
│   ├── Demo.csproj         # 專案配置
│   ├── appsettings.json    # 應用程式設定
│   └── Properties/
│       └── launchSettings.json
├── Dockerfile              # Docker 映像建置文件
├── .dockerignore           # Docker 忽略文件
├── Jenkinsfile             # Jenkins Pipeline 腳本
├── docker-compose.yml      # Docker Compose 配置
├── .gitignore              # Git 忽略文件
└── README.md               # 本文件
```