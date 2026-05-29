pipeline {
agent any

```
environment {
    AWS_REGION = 'ap-south-1'
    ECR_REPO   = 'flask-backend'
    ACCOUNT_ID = '192902842773'
    IMAGE_TAG  = 'latest'
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

    stage('Build Flask Docker Image') {

        when {
            expression { params.ACTION == 'apply' }
        }

        steps {

            dir('backend') {

                sh '''
                docker build -t $ECR_REPO:$IMAGE_TAG .
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

    stage('Tag Docker Image') {

        when {
            expression { params.ACTION == 'apply' }
        }

        steps {

            sh '''
            docker tag $ECR_REPO:$IMAGE_TAG \
            $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
            '''
        }
    }

    stage('Push Docker Image to ECR') {

        when {
            expression { params.ACTION == 'apply' }
        }

        steps {

            sh '''
            docker push \
            $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
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

            docker run -d \
            --name flask-app \
            -p 5000:5000 \
            $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
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

            docker run -d \
            --name react-app \
            -p 3000:3000 \
            ravindrasingh45/frontend:v1
            '''
        }
    }

    stage('Verify Deployment') {

        when {
            expression { params.ACTION == 'apply' }
        }

        steps {

            sh '''
            docker ps -al
            '''
        }
    }
}

post {

    success {

        echo '✅ FULLY AUTOMATED 3-TIER PIPELINE SUCCESSFUL'
        echo '✅ Terraform Infrastructure Created'
        echo '✅ Docker Image Pushed to ECR'
        echo '✅ Flask App Deployed Successfully'
        echo '✅ React App Deployed Successfully'
    }

    failure {

        echo '❌ PIPELINE FAILED'
    }
}
```

}
