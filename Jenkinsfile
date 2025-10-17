def config = [:]

pipeline {
    agent any
    stages {
        stage('Prepare') {
            steps {
                script {
                    config = readYaml file: 'pipeline-config.yaml'
                    currentBuild.displayName = generateTag()
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    buildDockerImageAndPush(config)
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

//Methods
def buildDockerImageAndPush(config) {
    def imageName = config.pipeline.image.name
    def repository = config.pipeline.image.repository
    def tag = currentBuild.displayName

    echo "[INFO] Building Docker image: ${repository}/${imageName}:${tag}"

    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh "docker build -t ${repository}/${imageName}:${tag} ."
        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
        sh "docker push ${repository}/${imageName}:${tag}"
    }
}

def generateTag() {
    def commitID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    return "v-${env.BUILD_NUMBER}-${commitID}"
}