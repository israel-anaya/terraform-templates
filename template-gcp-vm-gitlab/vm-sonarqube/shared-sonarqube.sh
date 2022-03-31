#!/bin/sh
CONTAINER_NAME="shared-sonarqube"
DATABASE_HOST="cehd-workers"
DATABASE_PORT_NUMBER="5432"
DATABASE_USER="sonarqube"
DATABASE_PASSWORD="90ct3pRpsARz58lL"
DATABASE_NAME="cehd-shared-sonarqube-production"
LISTEN_PORT=9000

createContainer() {
    echo "Creating $CONTAINER_NAME..."

    docker volume create --name $CONTAINER_NAME

    docker run -d --name $CONTAINER_NAME --restart always \
        -v shared-sonarqube:/bitnami/sonarqube \
        -p $LISTEN_PORT:9000 \
        -e SONARQUBE_DATABASE_HOST=$DATABASE_HOST \
        -e SONARQUBE_DATABASE_PORT_NUMBER=$DATABASE_PORT_NUMBER \
        -e SONARQUBE_DATABASE_USER=$DATABASE_USER \
        -e SONARQUBE_DATABASE_PASSWORD=$DATABASE_PASSWORD \
        -e SONARQUBE_DATABASE_NAME=$DATABASE_NAME \
        bitnami/sonarqube:9.3.0
}

stopContainer() {
    echo "Stoping $CONTAINER_NAME..."
    docker container stop $CONTAINER_NAME
}

restartContainer() {
    echo "Restarting $CONTAINER_NAME..."
    docker container restart $CONTAINER_NAME
}

deleteContainer() {
    echo "Deleting $CONTAINER_NAME..."
    docker container rm -f $CONTAINER_NAME
    docker volume rm $CONTAINER_NAME
}

viewLogs() {
    echo "logs"
    docker logs -f $CONTAINER_NAME
}

help() {
    echo "Usage: \"sudo ./shared-sonarqube [action]\""
    echo "actions: \r\n"
    echo "  create:   Create and start shared SonarQube container"
    echo "  delete:   Stop and delete shared SonarQube container"
    echo "  restart:  Stop and start shared SonarQube container"
    echo "  logs:     Show logs on realtime from shared SonarQube container"
    echo "\r\n"
}

main() {
    case $1 in
        create)
            createContainer
        ;;
        delete)
            deleteContainer
        ;;
        stop)
            stopContainer
        ;;
        restart)
            restartContainer
        ;;
        logs)
            viewLogs
        ;;
        *)
            help
        ;;
    esac
}

# call main function
main $1