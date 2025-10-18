def config      = [:]

pipeline {
    agent any
    parameters {
        choice(name: 'ENV', choices: ['dev','prod'], description: 'Select environment to deploy to')
    }
    stages {
        stage('Prepare') {
            steps {
                script {
                    config = generateConfig(config)
                    printConfig(config)
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

//Main Methods
def generateConfig(config) {
    def configFile              = readYaml file: 'pipeline-config.yaml'
    currentBuild.displayName    = generateTag()
    config.tag                  = currentBuild.displayName
    config.appName              = configFile.pipeline.app.name
    config.imageName            = configFile.pipeline.image.name
    config.repository           = configFile.pipeline.image.repository
    config.env                  = params.ENV

    return config
}

def buildDockerImageAndPush(config) {
    def imageName = config.imageName
    def repository = config.repository
    def tag = config.tag

    echo "[INFO] Building Docker image: ${repository}/${imageName}:${tag}"

    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh "docker build -t ${repository}/${imageName}:${tag} ."
        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
        sh "docker push ${repository}/${imageName}:${tag}"
    }
}

def deployToK8s(config) {
    def appName = config.appName
    def imageName = config.imageName
    def repository = config.repository
    def tag = config.tag
    def env = config.env
    def valuesFile = "charts/values-${env}.yaml"
    def namespace = readYaml(file: valuesFile).namespace 

    printHelmTemplate(appName, valuesFile, namespace)
    echo "[INFO] Deploying to Minikube cluster..."
    helmUpgrade(appName, valuesFile, namespace, repository, imageName, tag)
}

def testDockerImage(config) {
    def imageName = config.imageName
    def repository = config.repository
    def tag = config.tag
    def containerName = "test-container"

    echo "[INFO] Testing Docker image: ${repository}/${imageName}:${tag}"

    sh "docker run -d --name ${containerName} ${repository}/${imageName}:${tag} -c ./test.sh"
    sh "docker wait ${containerName}"
    def testResult = sh(script: "docker logs ${containerName} 2>&1", returnStdout: true).trim()
    sh "docker rm -f ${containerName}"

    validateTestResult(testResult)
}

//Helper methods
def validateTestResult(testResult) {
    if (!testResult.contains("OK")) {
        echo "[ERROR] Test output:\n${testResult}"
        error "[ERROR] Tests failed."
    } else {
        echo "[INFO] Tests passed."
    }
}

def printHelmTemplate(appName, valuesFile, namespace) {
    echo "[INFO] Printing Helm template for review..."
    sh "helm template ${appName} ./charts -f charts/values.yaml -f ${valuesFile} --namespace ${namespace}"
}

def helmUpgrade(appName, valuesFile, namespace, repository, imageName, tag) {
    sh "helm upgrade --install ${appName} ./charts -f charts/values.yaml -f ${valuesFile} --namespace ${namespace} --create-namespace --set image.repository=${repository}/${imageName} --set image.tag=${tag}"
}

def generateTag() {
    def commitID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    return "v-${env.BUILD_NUMBER}-${commitID}"
}

def printConfig(config) {
    def configOut = ''
    configOut += "[INFO] Deployment Configuration:\n"
    configOut += "==================================================="
    config.each { key, value ->
        configOut += "${key}: ${value}\n"
    }
    configOut += "==================================================="

    echo configOut
}