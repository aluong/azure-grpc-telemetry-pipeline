#!/bin/bash

hash databricks >/dev/null 2>&1 || { echo >&2 "This script requires the databricks-cli but it is not installed.  Aborting."; exit 1; }

declare token=
declare host=

while getopts "t:h:" arg; do
    case "${arg}" in
        t) 
            token=${OPTARG};;
        h) 
            host=${OPTARG};;
    esac
done

if [[ -z "$token" ]]; then
	echo "Enter the Databricks token:"
	read token
fi

if [[ -z "$host" ]]; then
	echo "Enter the Databricks host url (e.g. https://westus2.azuredatabricks.net):"
	read host
fi

( echo $host && echo $token )| databricks configure --token

# Upload notebooks
echo "Uploading notebooks..."
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $parent_path
databricks workspace import_dir "./notebooks" "/notebooks" --overwrite

# Run job
echo "Submitting a job to run..."
databricks runs submit --json-file eventhub.ingestion.job.json
