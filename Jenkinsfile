pipeline {
  agent any

  parameters {
    string(name: 'IMAGE_TAG', defaultValue: 'v1', description: 'Docker image version tag')
  }

  environment {
    REGISTRY     = "docker.io/purveshpeche"
    EC2_HOST     = "ubuntu@44.201.178.175"
    PROJECT_DIR  = "/home/ubuntu/python-and-node.js-app"
    GIT_REPO     = "git@github.com:purveshpeche/python-and-node.js-app.git"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Images') {
      steps {
        sh '''
          docker build -t $REGISTRY/python-app:${IMAGE_TAG} -f python-app/Dockerfile python-app
          docker build -t $REGISTRY/nodejs-app:${IMAGE_TAG} -f nodejs-app/Dockerfile nodejs-app
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub',
          usernameVariable: 'DOCKERHUB_USER',
          passwordVariable: 'DOCKERHUB_PASS'
        )]) {
          sh '''
            echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
            docker push $REGISTRY/python-app:${IMAGE_TAG}
            docker push $REGISTRY/nodejs-app:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Deploy on EC2') {
      steps {
        sshagent(['ec2-ssh-key']) {
          sh """
            ssh -o StrictHostKeyChecking=no ${EC2_HOST} 'bash -s' <<EOF
              set -e

              # Remove old repo if it exis

