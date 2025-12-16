# Demo - .NET 8.0 Web API 專案 (Windows 版本)

這是一個使用 .NET 8.0 開發的 Web API 專案，支援使用 Docker 和 Jenkins 進行自動化部署。

> **注意**: 這是 Windows 版本的安裝指南。如果你使用的是 macOS，請參考 [README.md](README.md)

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

### 步驟 0：安裝 Docker Desktop for Windows

#### 系統需求
- Windows 10 64-bit: Pro, Enterprise, 或 Education (Build 19041 或更高版本)
- 或 Windows 11 64-bit
- 啟用 WSL 2 功能

#### 安裝步驟

1. **下載 Docker Desktop for Windows**
   - 前往 [Docker 官網](https://www.docker.com/products/docker-desktop/)
   - 下載 Docker Desktop for Windows 安裝程式

2. **安裝 Docker Desktop**
   - 雙擊 `Docker Desktop Installer.exe` 執行安裝
   - 確保勾選「Use WSL 2 instead of Hyper-V」選項
   - 等待安裝完成
   - 重啟電腦

3. **啟用 WSL 2（如果尚未啟用）**

   以**系統管理員身份**打開 PowerShell，執行以下命令：

   ```powershell
   # 啟用 WSL
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

   # 啟用虛擬機器平台
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

   # 重啟電腦
   Restart-Computer
   ```

   重啟後，下載並安裝 WSL 2 Linux 核心更新套件：
   - [下載 WSL 2 Linux 核心更新套件](https://aka.ms/wsl2kernel)

   設置 WSL 2 為預設版本：
   ```powershell
   wsl --set-default-version 2
   ```

4. **啟動 Docker Desktop**
   - 在開始功能表找到「Docker Desktop」並啟動
   - 等待 Docker 引擎啟動完成（系統托盤圖標變為綠色）

5. **驗證安裝**

   打開 PowerShell，執行：
   ```powershell
   docker --version
   docker ps
   ```

   如果看到版本資訊和容器列表（即使是空的），表示安裝成功。

---

### 步驟 1：創建 Jenkins 數據目錄

打開 PowerShell，執行：

```powershell
# 在當前目錄創建 jenkins_home 目錄（用於持久化 Jenkins 數據）
New-Item -ItemType Directory -Path "jenkins_home" -Force

# 註：Windows 上不需要設置 chmod 權限
```

---

### 步驟 2：啟動 Jenkins 容器

#### 方式 A：使用 PowerShell（推薦）

```powershell
docker run -d `
  --name jenkins `
  -p 8081:8080 `
  -p 50000:50000 `
  -v //var/run/docker.sock:/var/run/docker.sock `
  -v ${PWD}/jenkins_home:/var/jenkins_home `
  jenkins/jenkins:lts
```

**注意事項：**
- PowerShell 中使用反引號 `` ` `` 進行換行
- Windows 路徑使用 `${PWD}` 獲取當前目錄
- Docker socket 路徑使用 `//var/run/docker.sock`（雙斜線）

#### 方式 B：使用絕對路徑（如果方式 A 失敗）

```powershell
docker run -d --name jenkins -p 8081:8080 -p 50000:50000 -v //var/run/docker.sock:/var/run/docker.sock -v C:\Users\YourUsername\jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

**記得將 `C:\Users\YourUsername` 替換為實際路徑！**

**參數說明：**
- `-d`: 在背景執行
- `--name jenkins`: 容器名稱為 jenkins
- `-p 8081:8080`: Jenkins Web 界面映射到主機的 8081 端口
- `-p 50000:50000`: Jenkins agent 通訊端口
- `-v //var/run/docker.sock:/var/run/docker.sock`: 讓 Jenkins 可以使用主機的 Docker
- `-v ${PWD}/jenkins_home:/var/jenkins_home`: 持久化 Jenkins 數據

---

### 步驟 3：獲取初始管理員密碼

打開 PowerShell，執行：

```powershell
# 查看 Jenkins 日誌，找到初始密碼
docker logs jenkins

# 或直接從文件讀取
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

複製顯示的密碼（一串長的英數字組合）。

---

### 步驟 4：訪問 Jenkins

1. 打開瀏覽器訪問：`http://localhost:8081`
2. 輸入步驟 3 獲取的初始密碼
3. 選擇「安裝建議的插件」（Install suggested plugins）
4. 等待插件安裝完成
5. 創建第一個管理員帳號
6. 完成安裝

---

### 步驟 5：安裝 Docker 相關插件

Jenkins 已經可以使用主機的 Docker，但如果需要更多功能：

1. 進入 Jenkins → 管理 Jenkins (Manage Jenkins) → 插件管理 (Plugin Manager)
2. 點擊「可用的 (Available plugins)」
3. 搜索並安裝以下插件：
   - Docker Pipeline
   - Docker
4. 安裝完成後重啟 Jenkins

---

### 步驟 6：讓 Jenkins 容器能執行 Docker 指令

打開 PowerShell，執行：

```powershell
# 進入 Jenkins 容器
docker exec -it -u root jenkins bash

# 在容器內執行以下命令：
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

1. 在 Jenkins 首頁點擊「新增作業」(New Item)
2. 輸入作業名稱（例如：`demo-app-pipeline`）
3. 選擇「Pipeline」，點擊「確定」(OK)
4. 在「Pipeline」區塊選擇「Pipeline script from SCM」
5. SCM 選擇「Git」
6. 輸入倉庫 URL
7. Script Path 填入：`Jenkinsfile`
8. 點擊「儲存」(Save)

6. 點擊「儲存」(Save)

### 執行 Pipeline

1. 點擊「立即建置」(Build Now)
2. 查看建置過程和日誌
3. 建置成功後，訪問 `http://localhost:8080/hello`

---

## 部署方式

### 🔧 Jenkins 自動化部署

1. 推送代碼到 Git 倉庫
2. 在 Jenkins 中點擊「立即建置」
3. Jenkins 自動執行：
   - 拉取最新代碼
   - 建置 Docker 映像
   - 停止舊容器
   - 啟動新容器