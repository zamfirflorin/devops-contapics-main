pipeline {
    agent any
    triggers {
           pollSCM('H/1 * * * *')
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/zamfirflorin/devops-contapics-main.git', credentialsId: 'github-contapics-token'
            }
        }

        stage('Build & Test Backend') {
            when {
                branch 'main'
                changeset "backend/**"
            }
            steps {
                dir('backend') {
                    sh 'mvn clean package'
                    sh 'mvn test'
                }
            }
        }

        stage('Build & Test Frontend') {
            when {
                branch 'main'
                changeset "frontend/**"
            }
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'npm run build'
                    sh 'npm test'
                }
            }
        }

        stage('Deploy Backend') {
            when {
                branch 'main'
                //changeset "backend/**"
            }
            steps {
                echo 'Deploy backend...'
                // sh './deploy-backend.sh'
            }
        }
        //test
        stage('Deploy Frontend') {
            when {
                branch 'main'
                //changeset "frontend/**"
            }
            steps {
                echo 'Deploy frontend...'
                // sh './deploy-frontend.sh'
            }
        }
    }

    post {
        success { echo 'Pipeline complet executat cu succes!' }
        failure { echo 'Pipeline eșuat :(' }
    }
}
