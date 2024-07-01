pipeline{
    agent{
        node{
            label 'Build-server'
        }
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('Akash_Access_ID')
        AWS_SECRET_ACCESS_KEY = credentials('Akash_Secret_Access_ID')
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME   = 'Prod-eks'
        PROFILE        =  'Akash-user'
        KUBECONFIG     = '/var/lib/jenkins/.kube/config'
    }
    stages{
        stage('Checkout SCM'){
            steps{
                script{
                    checkout scmGit(branches: [[name: '*/eks-prod']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/AkashRawat01/CICD-terraform.git']]) //Generate  using pipeline syntax
                }
            }
        }
        stage('Initializing Terraform'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform init'
                    }
                }
            }
        }
        stage('Formating terraform code'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform fmt'
                    }
                }
            }
        }
        stage('Validating Terraform'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform validate'
                    }
                }
            }
        }
        stage('Previewing the infrastructure'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform plan'
                    }
                }
            }
        }
        stage('Creating an EKS cluster'){
            when{
                environment name:'CREATE EKS CLUSTER',value: 'true'
            }
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform apply --auto-approve'
                         sh 'aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME} --kubeconfig ${KUBECONFIG} --profile ${PROFILE}'
                         sh 'kubectl create ns application'
                         sh 'kubectl get ns'
                    }
                }
            }
        }
        stage('Destroying an EKS cluster'){
            when{
                environment name:'DESTROY EKS CLUSTER',value: 'true'
            }
            steps{
                script{
                    dir('EKS'){
                         //sh 'kubectl delete ns application'
                         sh 'terraform destroy --auto-approve'
                         sh 'rm -rf *'
                    }
                }
            }
        }
    }
}
