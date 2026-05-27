pipeline {
    agent any
    environment {
        AWS_REGION = "ap-south-1"
    }

perameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Terraform Action'
        )
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform') {
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