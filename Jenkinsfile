// Jenkins Pipeline 腳本
pipeline {
    // 在任何可用的 Jenkins agent 上執行
    agent any

    stages {
        // ========== 階段 1：建置 Docker 映像 ==========
        stage('建置 Docker 映像') {
            steps {
                // 執行 docker build 命令
                // -t demo-app: 將映像命名為 demo-app
                // .: 使用當前目錄的 Dockerfile
                sh 'docker build -t demo-app .'
            }
        }

        // ========== 階段 2：部署應用程式 ==========
        stage('部署') {
            steps {
                // 停止舊的容器（如果存在）
                // || true: 即使容器不存在也不會報錯
                sh 'docker stop demo-app || true'

                // 刪除舊的容器（如果存在）
                sh 'docker rm demo-app || true'

                // 啟動新的容器
                // -d: 在背景執行
                // --name demo-app: 容器名稱為 demo-app
                // -p 8080:8080: 將主機的 8080 映射到容器的 8080
                // demo-app: 使用剛才建置的映像
                sh 'docker run -d --name demo-app -p 8080:8080 demo-app'
            }
        }
    }
}
