if(isSCMTrigger{}) {
    return
}

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    echo '[INFO] Building the docker image...'
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker build -t ${DOCKER_USER}/helloapp:latest ."
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh "docker push ${DOCKER_USER}/helloapp:latest"
                    }
                } 
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo '[INFO] Deploying to Minikube cluster...'
                    sh "helm upgrade --install helloapp charts -f charts/values.yaml"
                }
            }
        }
    }
}

