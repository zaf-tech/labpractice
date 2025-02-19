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
                             
stage('Terraform apply and Get Public IP') {
    steps {
        script {
            def publicIp = "" // Initialize publicIp

            dir('terraform') {
                sh 'terraform apply --auto-approve'

                // Capture the public IP – handle potential errors
                try {
                    publicIp = sh(returnStdout: true, script: 'terraform output instance_public_ip').trim()
                    echo "Public IP: ${publicIp}"
                } catch (err) {
                    echo "Error getting public IP: ${err.message}"
                    // Handle the error appropriately, e.g., throw it to fail the build
                    throw err // Or provide a default IP if you have one
                }
            }


            // Run Linux commands on the instance using the obtained IP
            // Wait until SSH is available
            waitUntil(timeout: 60, unit: 'SECONDS') { // Timeout after 1 minute
                try {
                    sh "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@${publicIp} 'exit 0'" // Try connecting
                    return true // SSH connection successful
                } catch (Exception e) {
                    echo "SSH not yet available. Retrying..."
                    return false // SSH connection failed, retry
                }
            }


            sshagent(credentials: ['ec2-user']) {
                sh """
                    ssh -o StrictHostKeyChecking=no -o ec2-user@${publicIp} << EOFSSH
                        #!/bin/bash
                        yum install -y ansible
                        yum install -y git
EOFSSH
                """

            }
        }
    }
} 

stage('sleep') {
            steps {
                // Print HelloWorld
                sh 'sleep 5'
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
