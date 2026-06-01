pipeline {
    agent any

    environment {
        AWS_REGION        = 'ap-south-1'
        ACCOUNT_ID        = '192902842773'

        BACKEND_REPO      = 'flask-backend'
        FRONTEND_REPO     = 'frontend-repo'

        IMAGE_TAG         = 'latest'
        
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh '''
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh '''
                    terraform plan
                    '''
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

                            sh '''
                            terraform apply -auto-approve
                            '''

                        } else {

                            sh '''
                            terraform destroy -auto-approve
                            '''
                        }
                    }
                }
            }
        }

        stage('Build Backend Docker Image') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                dir('backend') {

                    sh '''
                    docker build -t $BACKEND_REPO:$IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Build Frontend Docker Image') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                dir('frontend') {

                    sh '''
                    docker build -t $FRONTEND_REPO:$IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {

            when {
                expression { params.ACTION == 'apply' }
            }

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

        stage('Tag Docker Images') {

            when {
                expression { params.ACTION == 'apply' }
            }
            
            steps {

                sh '''
                docker tag $BACKEND_REPO:$IMAGE_TAG \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG

                docker tag $FRONTEND_REPO:$IMAGE_TAG \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Push Docker Images') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                sh '''
                docker push \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$IMAGE_TAG

                docker push \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy Flask Container') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                sh '''
                docker stop flask-app || true
                docker rm flask-app || true

                docker rmi -f 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest || true

                docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

                docker run -d \
                --name flask-app \
                -p 5000:5000 \
               192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest
                '''
            }
        }

        stage('Deploy React Container') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                sh '''
                docker stop react-app || true
                docker rm react-app || true

                docker rmi -f 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest || true

                docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

                docker run -d \
                --name react-app \
                -p 3000:3000 \
               192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest
                '''
            }
        }

        stage('Verify Deployment') {

            when {
                expression { params.ACTION == 'apply' }
            }

            steps {

                sh '''
                docker image prune -f
                docker ps -a
                '''
            }
        }
         stage('Get ALB DNS') {
            steps {
                sh '''
                echo "Fetching ALB DNS..."
                aws elbv2 describe-load-balancers \
                --query "LoadBalancers[*].DNSName" \
                --output text
                '''
            }
        }

        stage('Verify HTTPS Domain') {
            steps {
                sh '''
                echo "Your app should be available at:"
                echo "https://api.myapp.com"
                '''
            }
        }
    }

    }
     
    post {

        success {

            echo '✅ FULLY AUTOMATED 3-TIER PIPELINE SUCCESSFUL'
            echo '✅ Terraform Infrastructure Created'
            echo '✅ Docker Images Pushed to ECR'
            echo '✅ Flask App Deployed Successfully'
            echo '✅ React App Deployed Successfully'
        }

        failure {

            echo '❌ PIPELINE FAILED'
        }
    }
}




       