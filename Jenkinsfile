pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose Terraform Action'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {

        stage('Clone Code') {
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
                sh "terraform plan"
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh 'terraform apply -auto-approve'
                    } else if (params.ACTION == 'destroy') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}