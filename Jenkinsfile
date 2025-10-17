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
                script {
                    testDockerImage(config)
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    deployToK8s(config)
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

def deployToK8s(config) {
    def imageName = config.pipeline.image.name
    def repository = config.pipeline.image.repository
    def tag = currentBuild.displayName

    echo "[INFO] Deploying to Minikube cluster..."

    sh "helm upgrade --install helloapp charts -f charts/values.yaml --set image.repository=${repository}/${imageName} --set image.tag=${tag}"
}

def testDockerImage(config) {
    def imageName = config.pipeline.image.name
    def repository = config.pipeline.image.repository
    def tag = currentBuild.displayName
    //def containerName = config.pipeline.app.name
    def containerName = "test-container"

    echo "[INFO] Testing Docker image: ${repository}/${imageName}:${tag}"

    sh "docker run -d --name ${containerName} ${repository}/${imageName}:${tag} -c ./test.sh"
    sh "docker wait test-container"
    def testResult = sh(script: "docker logs ${containerName} 2>&1", returnStdout: true).trim()
    sh "docker rm -f ${containerName}"

    validateTestResult(testResult)
}

def validateTestResult(testResult) {
    if (!testResult.contains("OK")) {
        echo "[ERROR] Test output:\n${testResult}"
        error "[ERROR] Tests failed."
    } else {
        echo "[INFO] Tests passed."
    }
}