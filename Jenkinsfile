pipeline {

agent {
        label 'agent1' // Use the label 'agent' to target your Jenkins slave
    }

    environment {
        GIT_REPO = 'git@github.com:zaftechnologies/git-practice.git'
        DIRECTORY_NAME = 'artifact'  // Name of the directory where repo will be cloned
            AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
            AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
 
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout the Git repository with SSH key authentication
                git branch: 'main', 
                    credentialsId: 'github-ssh-key', 
                    url: "${GIT_REPO}"
            }
        }

        stage('verify') {
            steps {
                // Print the current working directory to debug
                sh 'ls'
                sh 'ls'
                sh 'ls /'
                sh 'ls hello_world.sh'
                sh 'ls -l'  // List the contents to confirm the repo is
                sh 'pwd'
                sh 'mkdir -p artifact'
                sh 'echo Hello > artifact/test.txt'
            }
        }        

        stage('terraform') {
            steps {
                // Print terraform
                sh 'terraform --version'
                sh 'echo Terraform installed version'
            }
        }        

        stage('Terraform Init') {
            steps {
                script {
                    // Change to the terraform subdirectory and run terraform init
                    dir('terraform') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform plan') {
            steps {
                script {
                    // Change to the terraform subdirectory and run terraform init
                    dir('terraform') {
                        sh  'terraform plan'
                    }
                }
            }
        }
                             
stage('Terraform apply and SSH to VM') {
    steps {
        script {
            def publicIp = ""

            dir('terraform') {
                sh 'terraform apply --auto-approve'

                try {
                    publicIp = sh(returnStdout: true, script: 'terraform output instance_public_ip').trim()
                    echo "Public IP: ${publicIp}"
                    echo "Public IP Test Talha: ${publicIp}"
                } catch (err) {
                    echo "Error getting public IP: ${err.message}"
                    throw err
                }
            }

            sshagent(['ec2-user']) {  // sshagent inside the *same* script block
                sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@${publicIp} << "EOF"
                        sudo yum install -y ansible
                        sudo yum install -y git
                        exit
                    EOF
                """
            }
        }
    }
}
        stage('sleep') {
            steps {
                // Print HelloWorld
                sh 'echo Complete'
            }
        } 

    
        stage('Terraform destroy') {
            steps {
                script {
                    // Change to the terraform subdirectory and run terraform init
                    dir('terraform') {
                    sh 'terraform destroy --auto-approve'                    
                    }
                }
            }
        }        
        stage('HelloWorld') {
            steps {
                // Print HelloWorld
                sh 'sh hello_world.sh'
            }
        }        

        stage('Create tar.gz Archive') {
            steps {
                script {
                    // Create zip file    
                    sh "tar -czf ${DIRECTORY_NAME}.tar.gz ${DIRECTORY_NAME}"
                }
            }
        }
        
        stage('Archive the tar.gz File') {
            steps {
                // Archive the tar.gz file as a build artifact
                archiveArtifacts artifacts: '*.tar.gz', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution complete.'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }

}
