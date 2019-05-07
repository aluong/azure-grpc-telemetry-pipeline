#!/bin/sh
set -euo pipefail

CONFIG_PATH=''
BROKERS=''
SECRET_ID=''

show_usage() {
  echo "Usage: startup.sh --config <config_path>"
  echo "Config should be in the following format, then base64 encoded:\n"
  echo "BROKERS=myeventhubnamespace.servicebus.windows.net:9093"
  echo "SECRET_ID=https://mykeyvault.vault.azure.net/secrets/mysecret/myversion"
}

parse_arguments() {
  PARAMS=""
  while (( $# )); do
    case "$1" in
      -h|--help)
        show_usage
        exit 0
        ;;
      -c|--config)
        CONFIG_PATH=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*|--*)
        echo "Unsupported flag $1" >&2
        exit 1
        ;;
      *)
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
  done
}

validate_arguments() {
  if [[ -z $CONFIG_PATH ]]; then
    show_usage
    exit 1
  fi

  CONFIG=$(cat $CONFIG_PATH | base64 -d)
  eval $CONFIG

  if [[ -z $BROKERS || -z $SECRET_ID ]]; then
    show_usage
    exit 1
  fi
}

start() {
    az login --identity --allow-no-subscriptions

    HOSTNAME=`hostname`
    openssl req -newkey rsa:4096 -nodes -keyout /etc/pipeline/pipeline_vm_key.pem -x509 -out /etc/pipeline/pipeline_vm_cert.pem  -subj "/CN=${HOSTNAME}" 

    export PIPELINE_gRPCDialout_tls_servername=$HOSTNAME

    export PIPELINE_kafkaProducer_saslPassword=`az keyvault secret show --id $SECRET_ID --query value --output tsv`
    export PIPELINE_kafkaProducer_brokers=$BROKERS

    touch /etc/pipeline/pipeline.log
    /etc/pipeline/pipeline -log=/etc/pipeline/pipeline.log -config=/etc/pipeline/pipeline.conf
}

parse_arguments "$@"
validate_arguments
start