pipeline {
    agent any

    environment {
        REGISTRY_URL = 'nexus.mycompany.com'
        IMAGE_NAME = 'my-app'
        GIT_DEPLOY_REPO = 'https://github.com/chuvannam02/CI-CD.git'
        GIT_SOURCE_APP = 'https://github.com/chuvannam02/practiceSpringBoot.git'

        SONAR_HOST_URL = 'https://sonarcloud.io'
        SONAR_LOGIN = credentials('sonar-token')
        SONAR_ORG = 'your_organization_key'      
        SONAR_PROJECT_KEY = '387fd948e98b992ac4928e6a5a4169d32d5aa247'

        SLACK_CHANNEL = '#ci-cd'

        NEXUS_USER = credentials('nexus-user')   // tạo trong Jenkins
        NEXUS_PASS = credentials('nexus-pass')
    }

    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'main', url: ${GIT_SOURCE_APP}
            }
        }

        stage('Build & Test') {
            steps {
                sh 'docker build -t my-app -f Dockerfile-prod .'
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                sh """
                    mvn sonar:sonar \
                      -Dsonar.organization=${SONAR_ORG} \
                      -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                      -Dsonar.host.url=${SONAR_HOST_URL} \
                      -Dsonar.login=${SONAR_LOGIN}
                """
            }
        }

        stage('Wait for Sonar Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def IMAGE_TAG = "${BUILD_NUMBER}"
                    sh """
                        echo "${NEXUS_PASS}" | docker login ${REGISTRY_URL} -u "${NEXUS_USER}" --password-stdin
                        docker build -t ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout ${REGISTRY_URL}
                    """
                    env.IMAGE_TAG = IMAGE_TAG
                }
            }
        }

        stage('Update Deploy Repo') {
            steps {
                script {
                    sh '''
                        rm -rf infra-deploy
                        git clone ${GIT_DEPLOY_REPO}
                        cd infra-deploy/k8s/my-app
                        sed -i "s|image: .*|image: ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml
                        git config user.email "jenkins@ci.local"
                        git config user.name "jenkins"
                        git commit -am "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
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
