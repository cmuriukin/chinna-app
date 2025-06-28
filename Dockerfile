FROM tomcat:latest

COPY target/hiring*.war /usr/local/tomcat/webapps/hiring.war
