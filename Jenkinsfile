pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = '192902842773'

        BACKEND_REPO = 'flask-backend'
        FRONTEND_REPO = 'frontend-repo'

        IMAGE_TAG = 'latest'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Terraform Action'
        )
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main',
                url: 'https://github.com/ravindrachuadhary01/Terraform-GitHub-Jenkins-.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh 'terraform apply -auto-approve'
                    } else {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }

        stage('Build Backend Image') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                dir('backend') {
                    sh """
                    docker build -t ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${BACKEND_REPO}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Build Frontend Image') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                dir('frontend') {
                    sh """
                    docker build -t ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_REPO}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Login to ECR') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin \
                ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Push Images') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh """
                docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${BACKEND_REPO}:${IMAGE_TAG}
                docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy Backend Container') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh """
                docker stop flask-app || true
                docker rm flask-app || true

                docker run -d \
                --name flask-app \
                -p 5000:5000 \
                ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${BACKEND_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Verify') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh 'docker ps'
            }
        }
    }

    post {
        success {
            echo "✅ PIPELINE SUCCESS - FULL 3 TIER DEPLOYED"
        }

        failure {
            echo "❌ PIPELINE FAILED - CHECK LOGS"
        }
    }
}