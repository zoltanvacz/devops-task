def config = [:]

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    echo '[INFO] Building the docker image...'
                    config = readYaml file: 'pipeline-config.yaml'
                    def imageName = config.pipeline.image.name
                    def repository = config.pipeline.image.repository
                    def tag = "1.2.3"

                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker build -t ${repository}/${imageName}:${tag} ."
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh "docker push ${repository}/${imageName}:${tag}"
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
                    def repository = config.pipeline.image.repository
                    def imageName = config.pipeline.image.name
                    def tag = "1.2.3"

                    sh "helm upgrade --install helloapp charts -f charts/values.yaml --set image.repository=${repository}/${imageName} --set image.tag=${tag}"
                }
            }
        }
    }
}

