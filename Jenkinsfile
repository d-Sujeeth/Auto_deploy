pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/d-Sujeeth/Auto_deploy.git' , branch: 'main'
            }
        }
        stage('Build') {
            steps {
                script {
                    docker.build("sujeethcloud/image")
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub_credentials_id') {
                        docker.image("sujeethcloud/image").push("latest")
                    }
                }
            }
        }
    }
}

