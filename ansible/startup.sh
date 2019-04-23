az login --identity --allow-no-subscriptions

export PIPELINE_mykafka_saslPassword=`az keyvault secret show --vault-name anzoloch-test-keyvault --id https://anzoloch-test-keyvault.vault.azure.net/secrets/pipeline-mykafka-saslPassword --query value`
export PIPELINE_mykafka_brokers=`az keyvault secret show --vault-name anzoloch-test-keyvault --id https://anzoloch-test-keyvault.vault.azure.net/secrets/pipeline-mykafka-brokers --query value`

touch /etc/pipeline/pipeline.log
/etc/pipeline/pipeline -log=/etc/pipeline/pipeline.log -config=/etc/pipeline/pipeline.conf