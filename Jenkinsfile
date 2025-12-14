pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
  }

  triggers {
    pollSCM('H/1 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/zamfirflorin/devops-contapics-main.git',
            credentialsId: 'ssh-key-id'   // un singur ID valid
      }
    }

    stage('Build & Test Backend') {
      when { branch 'main' }
      steps {
        dir('backend') {
          sh 'mvn clean verify'
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
          sh 'npm ci'
          sh 'npm test'
          sh 'npm run build'
        }
      }
    }

    stage('Deploy Backend') {
      when {
        branch 'main'
        changeset "backend/**"
      }
      steps {
        echo 'Deploy backend...'
        // sh './deploy-backend.sh'
      }
    }

    stage('Deploy Frontend') {
      when {
        branch 'main'
        changeset "frontend/**"
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
