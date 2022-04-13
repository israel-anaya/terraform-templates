#! /bin/sh

CONTAINER_NAME="proxy-sql"

createContainer() {
    echo "Creating ${CONTAINER_NAME}..."
}

stopContainer() {
    echo "Stoping ${CONTAINER_NAME}..."
}

restartContainer() {
    echo "Restarting ${CONTAINER_NAME}..."
}

deleteContainer() {
    echo "Deleting ${CONTAINER_NAME}..."
}

viewLogs() {
    echo "logs"
}

help() {
    echo "Usage: \"sudo ./proxy-sql [action]\""
    echo "actions: \r\n"
    echo "  create:   Create and start proxy-sql container"
    echo "  delete:   Stop and delete proxy-sql container"
    echo "  restart:  Stop and start proxy-sql container"
    echo "  logs:     Show logs on realtime from proxy-sql container"
    echo "\r\n"

}

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