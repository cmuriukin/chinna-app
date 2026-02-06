pipeline {
    agent any

    stages {
        stage('Stage 1: Checkout the repository') {
            steps {
                git url: 'https://github.com/cmuriukin/chinna-app.git', branch: 'feature_class_25'
            }
        }
        stage('Stage 2: Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Stage 3: SonarQube Scanning') {
            steps {
                withSonarQubeEnv(installationName: 'sonarqube', credentialsId: 'hiring_token') {
                sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Stage 4: Upload Artifacts to Nexus') {
            steps {
                nexusArtifactUploader artifacts:[
                    [artifactId: 'hiring',
                    classifier: '',
                    file: 'target/hiring.war',
                    type: 'war']
                    ],
                    credentialsId: 'nexus',
                    groupId: 'in.javahome',
                    nexusUrl: '13.40.221.25:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'hiring',
                    version: '0.2'
            }
        }
        stage('Stage 5: SonarQube Scanning') {
            steps {
                sshagent(['sshkey']) {
                    // opt to use curl/wget to doenload artifact directly from Nexus link into the container
                sh """
                scp -o StrictHostKeyChecking=no target/*.war ubuntu@13.40.188.69:/home/ubuntu
                ssh ubuntu@13.40.188.69 "docker cp /home/ubuntu/*.war tomcat-server://bitnami/tomcat/webapps/hiring.war"
                """
                }
            }
        }
    }
post {
  success {
    slackSend channel: 'devops-team', 
    color: 'good', 
    message: "Pipeline build number $BUILD_NUMBER run seccessfully", 
    tokenCredentialId: 'slack_id'
  }
  failure {
    slackSend channel: 'devops-team', 
    color: 'danger', 
    message: "Pipeline build number $BUILD_NUMBER did not succeed", 
    tokenCredentialId: 'slack_id'
  }
}

}
