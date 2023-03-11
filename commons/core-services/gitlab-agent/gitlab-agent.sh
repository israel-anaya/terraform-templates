#!/bin/sh
export NAMESPACE="gitlab-agent-ns"
export AGENT_TOKEN="GStMi5BSHQf_3BKfA8L-kUmxjs7HKkx9FyCyKWazhnxFYtdD8g"
export KAS_ADDRESS="wss://gitlab.cehd.devopsat.dev/-/kubernetes-agent/"
export HTTPS_PROXY="localhost:8888" #  For private GKE

registerGitLabAgent() {
    echo "Creating GitLab Agent..."
    docker run --pull=always --rm \
        registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate \
        --agent-token=$AGENT_TOKEN \
        --kas-address=$KAS_ADDRESS \
        --agent-version stable \
        --namespace $NAMESPACE | kubectl apply -f -
}

unregisterGitLabAgent() {
    echo "Deleting GitLab Agent..."

    docker run --pull=always --rm \
        registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate \
        --agent-token=$AGENT_TOKEN \
        --kas-address=$KAS_ADDRESS \
        --agent-version stable \
        --namespace $NAMESPACE | kubectl delete -f -

}

genfileGitLabAgent() {
    echo "Creating GitLab Agent..."
    docker run --pull=always --rm \
        registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate \
        --agent-token=$AGENT_TOKEN \
        --kas-address=$KAS_ADDRESS \
        --agent-version stable \
        --namespace $NAMESPACE > gitlab-agent.yaml
}

viewLogs() {
    echo "logs"
    kubectl logs -f -l=app=gitlab-agent -n $NAMESPACE
}

help() {
    echo "Usage: \"sudo ./gitlab-agent [action]\""
    echo "actions: \r\n"
    echo "  register:     Register and start GitLab Agent in kubernetes cluster"
    echo "  unregister:   Unregister previus GitLab Agent in kubernetes cluster"
    echo "  genfile:         Generate file gitLab-agent.yaml"
    echo "  logs:         Show logs on realtime from GitLab Agent"
    echo "\r\n"
}

main() {    
    case $1 in
        register)
            registerGitLabAgent
        ;;
        unregister)
            unregisterGitLabAgent
        ;;
        genfile)
            genfileGitLabAgent
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