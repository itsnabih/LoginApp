pipeline {
    agent any
    
    environment {
        APP_NAME = "loginapp"
        DOCKER_IMAGE = "${APP_NAME}:${BUILD_NUMBER}"
        DOCKER_LATEST = "${APP_NAME}:latest"
        PORT = "8087"
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                // Explicit checkout dari branch main
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/itsnabih/LoginApp.git'
                    ]]
                ])
                echo "✅ Code checked out from main branch"
                sh 'ls -la'
            }
        }
        
        stage('Validate Files') {
            steps {
                script {
                    echo "🔍 Validating required files..."
                    sh '''
                        echo "Files in workspace:"
                        ls -la
                        
                        if [ ! -f "index.html" ]; then
                            echo "❌ index.html not found!"
                            exit 1
                        fi
                        
                        if [ ! -f "Dockerfile" ]; then
                            echo "❌ Dockerfile not found!"
                            exit 1
                        fi
                        
                        echo "✅ Required files are present"
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "🏗️  Building Docker image..."
                    // Menggunakan sudo untuk menjalankan docker commands
                    sh """
                        sudo docker build -t ${DOCKER_IMAGE} .
                        sudo docker tag ${DOCKER_IMAGE} ${DOCKER_LATEST}
                        echo "✅ Docker image built: ${DOCKER_IMAGE}"
                    """
                }
            }
        }
        
        stage('Test Container') {
            steps {
                script {
                    echo "🧪 Testing container..."
                    sh """
                        # Start test container
                        sudo docker run --rm -d --name test-${BUILD_NUMBER} -p 8081:80 ${DOCKER_IMAGE}
                        
                        # Wait for container to start
                        sleep 5
                        
                        # Health check
                        if curl -f http://localhost:8081/ > /dev/null 2>&1; then
                            echo "✅ Container health check passed"
                        else
                            echo "❌ Container health check failed"
                            sudo docker logs test-${BUILD_NUMBER}
                            exit 1
                        fi
                        
                        # Stop test container
                        sudo docker stop test-${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Deploy to Local Server') {
            steps {
                script {
                    echo "🚀 Deploying application..."
                    sh """
                        # Stop and remove old container if exists
                        sudo docker stop ${APP_NAME} || true
                        sudo docker rm ${APP_NAME} || true
                        
                        # Run new container
                        sudo docker run -d \\
                            --name ${APP_NAME} \\
                            -p ${PORT}:80 \\
                            --restart unless-stopped \\
                            ${DOCKER_IMAGE}
                        
                        # Verify deployment
                        sleep 3
                        if sudo docker ps | grep ${APP_NAME} > /dev/null; then
                            echo "✅ Container is running"
                            sudo docker ps | grep ${APP_NAME}
                        else
                            echo "❌ Container failed to start"
                            sudo docker logs ${APP_NAME}
                            exit 1
                        fi
                    """
                }
            }
        }
        
        stage('Post-Deploy Verification') {
            steps {
                script {
                    echo "🔍 Verifying deployment..."
                    sh """
                        sleep 5
                        
                        if curl -f http://localhost:${PORT}/ > /dev/null 2>&1; then
                            echo "✅ Application is accessible at http://localhost:${PORT}"
                        else
                            echo "❌ Application is not accessible"
                            sudo docker logs ${APP_NAME}
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
            🎉 DEPLOYMENT SUCCESS! 🎉
            
            📱 Application: http://localhost:${PORT}
            🐳 Container: ${APP_NAME}
            📦 Image: ${DOCKER_IMAGE}
            """
        }
        
        failure {
            echo "❌ DEPLOYMENT FAILED!"
            script {
                sh """
                    echo "🔄 Attempting rollback..."
                    sudo docker stop ${APP_NAME} || true
                    sudo docker rm ${APP_NAME} || true
                    
                    if sudo docker images ${DOCKER_LATEST} -q | head -1; then
                        sudo docker run -d --name ${APP_NAME} -p ${PORT}:80 --restart unless-stopped ${DOCKER_LATEST}
                        echo "📦 Rollback attempted"
                    fi
                """
            }
        }
        
        always {
            sh """
                sudo docker ps -a | grep test-${BUILD_NUMBER} | awk '{print \$1}' | xargs -r sudo docker rm -f || true
                echo "🧹 Cleanup completed"
            """
        }
    }
}