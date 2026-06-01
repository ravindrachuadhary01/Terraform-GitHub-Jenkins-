pipeline {
    agent any

    environment {
        AWS_REGION   = 'ap-south-1'
        ACCOUNT_ID   = '192902842773'

        BACKEND_REPO  = 'flask-backend'
        FRONTEND_REPO = 'frontend-repo'

        IMAGE_TAG     = 'latest'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Terraform Action'
        )
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                url: 'https://github.com/ravindrachuadhary01/Terraform-GitHub-Jenkins-.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -auto-approve'
                        } else {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Build Backend Image') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                dir('backend') {
                    sh 'docker build -t $BACKEND_REPO:$IMAGE_TAG .'
                }
            }
        }

        stage('Build Frontend Image') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                dir('frontend') {
                    sh 'docker build -t $FRONTEND_REPO:$IMAGE_TAG .'
                }
            }
        }

        stage('Login to ECR') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag Images') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh '''
                docker tag $BACKEND_REPO:$IMAGE_TAG \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG

                docker tag $FRONTEND_REPO:$IMAGE_TAG \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Push Images') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh '''
                docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG
                docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy Backend') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh '''
                docker stop flask-app || true
                docker rm flask-app || true

                docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG

                docker run -d \
                --name flask-app \
                -p 5000:5000 \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy Frontend') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh '''
                docker stop react-app || true
                docker rm react-app || true

                docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG

                docker run -d \
                --name react-app \
                -p 3000:3000 \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Verify') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh 'docker ps -a'
            }
        }
    }

    post {
        success {
            echo '✅ FULLY AUTOMATED PIPELINE SUCCESSFUL'
        }

        failure {
            echo '❌ PIPELINE FAILED'
        }
    }
}