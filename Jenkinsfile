pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/itsnabih/LoginApp.git'
            }
        }

        stage('Deploy to Local Server') {
            steps {
                sh '''
                echo "Starting Deployment..."
                sudo rm -rf /var/www/html/*
                sudo cp -r * /var/www/html/
                sudo systemctl restart nginx
                echo "Deployment Finished"
                '''
            }
        }
    }
}
