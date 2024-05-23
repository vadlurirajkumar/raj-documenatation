pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "${env.AWS_ACCOUNT_ID}"
        AWS_DEFAULT_REGION = "${env.AWS_DEFAULT_REGION}"
        GIT_URL = "https://github.com/RiskSek/documentation-portal.git"
        IMAGE_REPO_NAME = "documentation-portal"
        IMAGE_TAG = "${BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        DOCKER_CONTAINER_NAME ="documentation-portal"
        DEV_SVC1_DOCKER_HOST = "${env.DEV_SVC1_DOCKER_HOST}"
        DEV_SVC2_DOCKER_HOST = "${env.DEV_SVC2_DOCKER_HOST}"
        QA_SVC1_DOCKER_HOST = "${env.QA_SVC1_DOCKER_HOST}"
        QA_SVC2_DOCKER_HOST = "${env.QA_SVC2_DOCKER_HOST}"
        PROD_SVC1_DOCKER_HOST = "${env.PROD_SVC1_DOCKER_HOST}"
        PROD_SVC2_DOCKER_HOST = "${env.PROD_SVC2_DOCKER_HOST}"
        DEV_IMAGE = "develop"
        RELEASE_IMAGE = "release"
        PORT = "5018:3000"
        DEPLOY_ENV_DEV = "dev"
        DEPLOY_ENV_QA = "qa"
        DEPLOY_ENV_PROD = "prod"
    }
    stages {
        stage("Checkout Develop Branch") {
            when {
                branch "develop"
            }
            steps {
                git branch: 'develop', credentialsId: 'github-credentials', url: "${GIT_URL}"
            }
        }
        stage("Build Develop Image") {
            when {
                branch "develop"
            }
            steps {
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${DEV_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Push Develop Image to ECR") {
            when {
                branch "develop"
            }
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_REPO_NAME}:${DEV_IMAGE}-${IMAGE_TAG} ${REPOSITORY_URI}:${DEV_IMAGE}-${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:${DEV_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Deploy Develop Image to DEV Server") {
            when {
                branch "develop"
            }
            steps {
                script {
                    sh "docker -H ${DEV_SVC2_DOCKER_HOST} pull ${REPOSITORY_URI}:${DEV_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Stop and Remove DEV Old Containers") {
            when {
                branch "develop"
            }
            steps {
                script {
                    sh "docker -H ${DEV_SVC2_DOCKER_HOST} stop ${DOCKER_CONTAINER_NAME} || true"
                    sh "docker -H ${DEV_SVC2_DOCKER_HOST} rm ${DOCKER_CONTAINER_NAME} || true"
                }
            }
        }
        stage("Run DEV Containers") {
            when {
                branch "develop"
            }
            steps {
                script {
                    sh "docker -H ${DEV_SVC2_DOCKER_HOST} run -d --name ${DOCKER_CONTAINER_NAME} -p ${PORT} -v /app/data:/app/data --restart=always ${REPOSITORY_URI}:${DEV_IMAGE}-${IMAGE_TAG}"
                    environmentDashboard(addColumns: false, buildJob: '', buildNumber: "${DEV_IMAGE}-${IMAGE_TAG}", componentName: "${IMAGE_REPO_NAME}", data: [], nameOfEnv: "${DEPLOY_ENV_DEV}", packageName: ''){}
                }
            }
        }
        stage("Checkout Release Branch") {
            when {
                branch "release"
            }
            steps {
                git branch: 'release', credentialsId: 'github-credentials', url: "${GIT_URL}"
            }
        }
        stage("Build Release Image") {
            when {
                branch "release"
            }
            steps {
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Push Release Image to ECR") {
            when {
                branch "release"
            }
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_REPO_NAME}:${RELEASE_IMAGE}-${IMAGE_TAG} ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Deploy Release Image to QA Server") {
            when {
                branch "release"
            }
            steps {
                script {
                    sh "docker -H ${QA_SVC2_DOCKER_HOST} pull ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Stop and Remove QA Old Containers") {
            when {
                branch "release"
            }
            steps {
                script {
                    sh "docker -H ${QA_SVC2_DOCKER_HOST} stop ${DOCKER_CONTAINER_NAME} || true"
                    sh "docker -H ${QA_SVC2_DOCKER_HOST} rm ${DOCKER_CONTAINER_NAME} || true"
                }
            }
        }
        stage("Run QA Containers") {
            when {
                branch "release"
            }
            steps {
                script {
                    sh "docker -H ${QA_SVC2_DOCKER_HOST} run -d --name ${DOCKER_CONTAINER_NAME} -p ${PORT} -v /app/data:/app/data --restart=always ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                    environmentDashboard(addColumns: false, buildJob: '', buildNumber: "${RELEASE_IMAGE}-${IMAGE_TAG}", componentName: "${IMAGE_REPO_NAME}", data: [], nameOfEnv: "${DEPLOY_ENV_QA}", packageName: ''){}
                }
            }
        }
        stage("Checkout Main Branch") {
            when {
                branch "main"
            }
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: "${GIT_URL}"
            }
        }
        stage("Deploy Release Image to PROD Server") {
            when {
                branch "main"
            }
            steps {
                script {
                    sh "docker -H ${PROD_SVC2_DOCKER_HOST} pull ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                }
            }
        }
        stage("Stop and Remove PROD Old Containers") {
            when {
                branch "main"
            }
            steps {
                script {
                    sh "docker -H ${PROD_SVC2_DOCKER_HOST} stop ${DOCKER_CONTAINER_NAME} || true"
                    sh "docker -H ${PROD_SVC2_DOCKER_HOST} rm ${DOCKER_CONTAINER_NAME} || true"
                }
            }
        }
        stage("Run PROD Containers") {
            when {
                branch "main"
            }
            steps {
                script {
                    sh "docker -H ${PROD_SVC2_DOCKER_HOST} run -d --name ${DOCKER_CONTAINER_NAME} -p ${PORT} -v /app/data:/app/data --restart=always ${REPOSITORY_URI}:${RELEASE_IMAGE}-${IMAGE_TAG}"
                    environmentDashboard(addColumns: false, buildJob: '', buildNumber: "${RELEASE_IMAGE}-${IMAGE_TAG}", componentName: "${IMAGE_REPO_NAME}", data: [], nameOfEnv: "${DEPLOY_ENV_PROD}", packageName: ''){}
                }
            }
        }
    }
    post {
        always {
            emailext (
                attachLog: true,
                subject: '$DEFAULT_SUBJECT',
                body: '$DEFAULT_CONTENT',
                to: '$DEFAULT_RECIPIENTS',
                mimeType: 'text/html'
            )
        }
    }
}