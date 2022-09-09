
#! /bin/sh

REGISTRATION_TOKEN="qTxnRSCCbhX6KwopzvYJ"

startSharedCache() {   
    if ( validateRunnerName "$1" )
    then

        echo "Creating $RUNNER_NAME..."
        docker run -itd --name minio --restart always \
            -p 9005:9000 \
            -v D:\minio:/root/.minio \
            -v D:\minio\export:/export \             
            minio/minio:latest server /export
        
        docker volume create $RUNNER_NAME

        docker run -d --name $RUNNER_NAME --restart always \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v $RUNNER_NAME:/etc/gitlab-runner \
            gitlab/gitlab-runner:latest
    fi
}

stopSharedCache() {
    if ( validateRunnerName "$1" )
    then
        RUNNER_NAME="$RUNNER_BASE_NAME-$1"

        echo "Stoping $RUNNER_NAME..."
        docker container stop $RUNNER_NAME
    fi
}

restartSharedCache() {
    if ( validateRunnerName "$1" )
    then
        RUNNER_NAME="$RUNNER_BASE_NAME-$1"

        echo "Restarting $RUNNER_NAME..."
        docker container restart $RUNNER_NAME
    fi
}

deleteSharedCache() {
    if ( validateRunnerName "$1" )
    then
        RUNNER_NAME="$RUNNER_BASE_NAME-$1"

        echo "Deleting $RUNNER_NAME..."
        
        docker container rm -f $RUNNER_NAME
        
        docker volume rm -f $RUNNER_NAME
    fi
}

viewLogs() {
    if ( validateRunnerName "$1" )
    then
        RUNNER_NAME="$RUNNER_BASE_NAME-$1"
   
        docker logs -f $RUNNER_NAME
    fi
}

help() {
    echo "Usage: \"sudo ./shared-runner [action] [runner-name]\""
    echo "actions: \r\n"
    echo "  create:   Create and start a new shared-runner container"
    echo "  delete:   Stop and delete a shared-runner container"
    echo "  restart:  Stop and start a shared-runner container"
    echo "  logs:     Show logs on realtime from a shared-runner container"
    echo "  register: Register shared-runner container in gitlab server"
    echo "\r\n"
}

main() {    
    case $1 in
        create)
            createSharedRunner $2
        ;;
        delete)
            deleteSharedRunner $2
        ;;
        stop)
            stopSharedRunner $2
        ;;
        restart)
            restartSharedRunner $2
        ;;
        logs)
            viewLogs $2
        ;;
        register)
            registerSharedRunner $2
        ;;
        *)
            help
        ;;
    esac
}

# call main function
main $1 $2

