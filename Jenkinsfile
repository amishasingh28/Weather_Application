pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('docker-username')    // Jenkins credentials for Docker Hub username
        DOCKER_PASSWORD = credentials('docker-password')    // Jenkins credentials for Docker Hub password
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Jenkins credentials for AWS access key ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // Jenkins credentials for AWS secret access key
        AWS_REGION = 'us-west-2' // Replace with your AWS region
        EKS_CLUSTER_NAME = 'your-cluster-name' // Replace with your EKS cluster name
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    // Get the commit hash
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.VERSION = "v1.${BUILD_NUMBER}.${commitHash}"
                    env.TAGNAME = "weather-application-${VERSION}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with the tag
                    sh """
                    docker build -t ${DOCKER_USERNAME}/weather-node-local:${TAGNAME} .
                    """
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    sh """
                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                    docker push ${DOCKER_USERNAME}/weather-node-local:${TAGNAME}
                    """
                }
            }
        }

        stage('Set up AWS CLI and Kubernetes') {
            steps {
                script {
                    // Configure AWS CLI and Kubernetes using EKS
                    sh """
                    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                    aws configure set region ${AWS_REGION}
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Apply Kubernetes manifests for deployment
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                    sh 'kubectl apply -f k8s/ingress.yaml'
                }
            }
        }
    }
}
