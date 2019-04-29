az login --identity --allow-no-subscriptions

hostname=`hostname`
openssl req -newkey rsa:4096 -nodes -keyout /etc/pipeline/pipeline_vm_key.pem -x509 -out /etc/pipeline/pipeline_vm_cert.pem  -subj "/C=US/ST=WA/L=Redmond/O=Microsoft/CN=${hostname}" 

export TLS_SERVERNAME=$hostname

export PIPELINE_mykafka_saslPassword=`az keyvault secret show --vault-name anzoloch-test-keyvault --id https://anzoloch-test-keyvault.vault.azure.net/secrets/pipeline-mykafka-saslPassword --query value`
export PIPELINE_mykafka_brokers=`az keyvault secret show --vault-name anzoloch-test-keyvault --id https://anzoloch-test-keyvault.vault.azure.net/secrets/pipeline-mykafka-brokers --query value`


touch /etc/pipeline/pipeline.log
/etc/pipeline/pipeline -log=/etc/pipeline/pipeline.log -config=/etc/pipeline/pipeline.conf