#! /bin/sh
export SQL_CLOUD_INSTANCE=${connection_name}
CONTAINER_NAME="proxy-sql"

createContainer() {
    echo "Creating $CONTAINER_NAME..."
    docker run -d --name $CONTAINER_NAME --restart always \
        -v /home/workers/stateful/cloudsql:/cloudsql \
        -p 5432:5432 \
        gcr.io/cloudsql-docker/gce-proxy:1.19.1 \
        /cloud_sql_proxy \
        -instances=$SQL_CLOUD_INSTANCE=tcp:0.0.0.0:5432 \
        -ip_address_types=PRIVATE
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
}

viewLogs() {
    echo "logs"
    docker logs -f $CONTAINER_NAME
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