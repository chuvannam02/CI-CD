pipeline {
    agent any

    environment {
        REGISTRY_URL = 'nexus.mycompany.com'
        IMAGE_NAME = 'my-app'
        GIT_DEPLOY_REPO = 'git@github.com:your-org/app-deploy.git'
        SONAR_HOST_URL = 'http://sonarqube.local:9000'
        SONAR_LOGIN = credentials('sonar-token')
        SLACK_CHANNEL = '#ci-cd'
    }

    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/app-source.git'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh 'mvn clean package -DskipTests=false'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn sonar:sonar -Dsonar.login=${SONAR_LOGIN}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def IMAGE_TAG = "${BUILD_NUMBER}"
                    sh """
                        docker build -t ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    env.IMAGE_TAG = IMAGE_TAG
                }
            }
        }

        stage('Update Deploy Repo') {
            steps {
                script {
                    sh '''
                        rm -rf app-deploy
                        git clone ${GIT_DEPLOY_REPO}
                        cd app-deploy
                        sed -i "s|image: .*$|image: ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml
                        git config user.email "jenkins@ci.local"
                        git config user.name "jenkins"
                        git commit -am "Update image tag to ${IMAGE_TAG}"
                        git push origin main
                    '''
                }
            }
        }
    }

    post {
        success {
            slackSend channel: "${SLACK_CHANNEL}", message: "✅ Build #${BUILD_NUMBER} succeeded. Image tag: ${IMAGE_TAG}"
        }
        failure {
            slackSend channel: "${SLACK_CHANNEL}", message: "❌ Build #${BUILD_NUMBER} failed at stage: ${env.STAGE_NAME}"
        }
    }
}
