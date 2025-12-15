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

## 快速開始

### 方式 1：本地開發

```bash
# 還原依賴
dotnet restore Demo/Demo.csproj

# 運行專案
dotnet run --project Demo/Demo.csproj

# 訪問應用程式
# http://localhost:5208/hello
# http://localhost:5208/swagger
```

### 方式 2：使用 Docker

```bash
# 建置 Docker 映像
docker build -t demo-app .

# 啟動容器
docker run -d -p 8080:8080 --name demo-app demo-app

# 訪問應用程式
# http://localhost:8080/hello
# http://localhost:8080/swagger
```

### 方式 3：使用 Docker Compose

```bash
# 一鍵啟動
docker-compose up -d

# 停止
docker-compose down
```

---

## 使用 Docker 啟動 Jenkins

### 步驟 1：創建 Jenkins 數據目錄

```bash
# 在專案根目錄創建 jenkins_home 目錄（用於持久化 Jenkins 數據）
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

### 方式 2：直接貼上 Pipeline 腳本

1. 在 Jenkins 首頁點擊「新增作業」
2. 輸入作業名稱（例如：`demo-app-pipeline`）
3. 選擇「Pipeline」，點擊「確定」
4. 在「Pipeline」區塊選擇「Pipeline script」
5. 貼上以下內容：

```groovy
pipeline {
    agent any

    stages {
        stage('建置 Docker 映像') {
            steps {
                sh 'docker build -t demo-app .'
            }
        }

        stage('部署') {
            steps {
                sh 'docker stop demo-app || true'
                sh 'docker rm demo-app || true'
                sh 'docker run -d --name demo-app -p 8080:8080 demo-app'
            }
        }
    }
}
```

6. 點擊「儲存」

### 執行 Pipeline

1. 點擊「立即建置」
2. 查看建置過程和日誌
3. 建置成功後，訪問 `http://localhost:8080/hello`

---

## 部署方式

### 🐳 Docker 部署

```bash
# 建置映像
docker build -t demo-app .

# 停止舊容器
docker stop demo-app || true
docker rm demo-app || true

# 啟動新容器
docker run -d --name demo-app -p 8080:8080 demo-app

# 查看日誌
docker logs -f demo-app
```

### 🚀 Docker Compose 部署

```bash
# 啟動服務
docker-compose up -d

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

### 🔧 Jenkins 自動化部署

1. 推送代碼到 Git 倉庫
2. 在 Jenkins 中點擊「立即建置」
3. Jenkins 自動執行：
   - 拉取最新代碼
   - 建置 Docker 映像
   - 停止舊容器
   - 啟動新容器

---

## 常用指令

### Docker 指令

```bash
# 查看運行中的容器
docker ps

# 查看所有容器（包含停止的）
docker ps -a

# 查看應用程式日誌
docker logs demo-app

# 即時查看日誌
docker logs -f demo-app

# 停止容器
docker stop demo-app

# 啟動容器
docker start demo-app

# 刪除容器
docker rm demo-app

# 查看映像
docker images

# 刪除映像
docker rmi demo-app

# 進入容器內部
docker exec -it demo-app bash
```

### Jenkins 指令

```bash
# 啟動 Jenkins
docker start jenkins

# 停止 Jenkins
docker stop jenkins

# 重啟 Jenkins
docker restart jenkins

# 查看 Jenkins 日誌
docker logs jenkins

# 查看 Jenkins 初始密碼
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### .NET 指令

```bash
# 還原依賴
dotnet restore

# 建置專案
dotnet build

# 運行專案
dotnet run

# 發佈專案
dotnet publish -c Release
```

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

---

## 🔥 故障排除

### Jenkins 無法執行 Docker 指令

**問題**: 在 Jenkins Pipeline 中執行 `docker` 指令時出現 "command not found"

**解決方案**:
```bash
# 進入 Jenkins 容器
docker exec -it -u root jenkins bash

# 安裝 Docker CLI
apt-get update && apt-get install -y docker.io

# 設置權限
chmod 666 /var/run/docker.sock

# 退出
exit
```

### 端口衝突

**問題**: 啟動容器時提示端口已被佔用

**解決方案**:
```bash
# 查看佔用 8080 端口的進程
lsof -i :8080

# 或使用其他端口
docker run -d --name demo-app -p 9090:8080 demo-app
```

### 容器無法啟動

**問題**: 容器啟動後立即停止

**解決方案**:
```bash
# 查看容器日誌
docker logs demo-app

# 查看容器詳細信息
docker inspect demo-app
```

---

## 📝 注意事項

1. **端口配置**:
   - Jenkins: `8081`
   - Demo App: `8080`
   - 確保這些端口沒有被其他服務佔用

2. **權限問題**:
   - `jenkins_home` 目錄需要適當的權限
   - Docker socket 需要正確的權限設置

3. **數據持久化**:
   - Jenkins 數據存儲在 `jenkins_home` 目錄
   - 不要刪除此目錄，否則會丟失所有配置

4. **安全性**:
   - 建議修改 Jenkins 預設端口
   - 設置強密碼
   - 不要在生產環境中使用 `chmod 777`

---

## 🌟 下一步

- [ ] 添加單元測試
- [ ] 配置 CI/CD 自動觸發
- [ ] 添加資料庫支援
- [ ] 配置 HTTPS
- [ ] 添加日誌收集
- [ ] 設置監控和告警

---

## 📞 聯絡資訊

如有問題或建議，請聯絡專案維護者。

## 📄 授權

本專案採用 MIT 授權。
