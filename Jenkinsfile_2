pipeline {

agent {
        label 'agent1' // Use the label 'agent' to target your Jenkins slave
    }
    environment {
        GIT_REPO = 'git@github.com:zaftechnologies/git-practice.git'
        DIRECTORY_NAME = 'artifact'  // Name of the directory where repo will be cloned
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
                sh 'ls hello_world.sh'
                sh 'ls'  // List the contents to confirm the repo is
                sh 'pwd'
                sh 'mkdir -p artifact'
                sh 'echo Hello > artifact/test.txt'
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
