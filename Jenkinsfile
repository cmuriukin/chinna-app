pipeline {
    agent any

    stages {
        stage('Checkout Git repo') {
            steps {
                git url: 'https://github.com/cmuriukin/chinna-app.git', branch: 'feature_class_25'
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('SonarQube Scanning') {
            steps {
                withSonarQubeEnv(installationName: 'sonarqube', credentialsId: 'sonar_token') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Upload Nexus to Artifactory') {
            steps {
                nexusArtifactUploader artifacts: [
                    [artifactId: 'hiring',
                    classifier: '',
                    file: 'target/hiring.war',
                    type: 'war']
                    ],
                    credentialsId: 'nexus_creds',
                    groupId: 'in.javahome',
                    nexusUrl: '13.135.254.20:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'hiring_app', 
                    version: '0.2'
            }
        }
        stage('Maven Docker image Build') {
            steps {
                sh 'docker build -t hiring:latest .'
            }
        }
        stage('Scan Docker Image') {
            steps {
                // sh 'trivy image --exit-code 1 --severity CRITICAL,HIGH $IMG:$IMAGE_TAG'
                sh 'trivy image hiring:latest'
            }
        }
        stage('Tag Docker Image') {
            steps {
                sh 'docker tag hiring:latest cmuriukin/class_27_jenkins:latest'
            }
        }
        stage('Push Docker Image to Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker_creds', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USER')]) {
                    sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin'
                    sh 'docker push cmuriukin/class_27_jenkins:latest'
                }
            }
        }
        stage('Deploy WAR file to tomcat container') {
            steps {
                sshagent(['key_pem']) {
                    sh"""
                    scp -o StrictHostKeyChecking=no target/*.war ubuntu@18.171.168.53:/home/ubuntu
                    ssh ubuntu@18.171.168.53 "docker cp /home/ubuntu/*.war tomcat-server:/bitnami/tomcat/webapps/hiring.war"
                    """
                }
             }
        }
    }
    post {
        success {
            slackSend color: 'good',
            message: "Docker Build ID $BUILD_NUMBER was pushed successfully",
            channel: '#class_27_devops',
            tokenCredentialId: 'slack_jenkins'
        }
        failure {
            slackSend color: 'danger',
            message: "Docker Build ID $BUILD_NUMBER Failed",
            channel: '#class_27_devops',
            tokenCredentialId: 'slack_jenkins'
        }
    }
}
