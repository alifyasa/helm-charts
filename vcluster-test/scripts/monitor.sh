#!/bin/bash

# Default values
NAMESPACE="default"
MAX_AGE_MINUTES=5
STATUS="Succeeded"

# Positional arguments
RESOURCE_TYPE="$1"
RESOURCE_NAME="$2"
shift 2

# Parse command-line options
while getopts ":n:t:s:" opt; do
    case $opt in
        n) NAMESPACE="$OPTARG" ;;
        t) MAX_AGE_MINUTES="$OPTARG" ;;
        s) STATUS="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 <resource_type> <resource_name> [-n namespace] [-t max_age_minutes] [-s status]"
            exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2
           exit 1 ;;
    esac
done

# Ensure positional arguments are provided
if [[ -z "$RESOURCE_TYPE" || -z "$RESOURCE_NAME" ]]; then
    echo "Usage: $0 <resource_type> <resource_name> [-n namespace] [-t max_age_minutes] [-s status]"
    exit 1
fi

# Debug echo to see what values are being used
echo "Using NAMESPACE=$NAMESPACE, MAX_AGE_MINUTES=$MAX_AGE_MINUTES, STATUS=$STATUS"

# Convert MAX_AGE_MINUTES to seconds
MAX_AGE_SECONDS=$((MAX_AGE_MINUTES * 60))

get_resource_info() {
    kubectl get "$RESOURCE_TYPE" "$RESOURCE_NAME" -n "$NAMESPACE" -o json
}

start_time=$(date +%s)
while true; do
    resource_info=$(get_resource_info)

    if [[ -z "$resource_info" ]]; then
        echo "Resource $RESOURCE_TYPE $RESOURCE_NAME not found in namespace $NAMESPACE."
        exit 1
    fi

    status=$(echo "$resource_info" | jq -r '.status.phase')
    creation_time=$(echo "$resource_info" | jq -r '.metadata.creationTimestamp')

    current_time=$(date +%s)
    creation_time_seconds=$(date -d "$creation_time" +%s)
    resource_age_seconds=$((current_time - creation_time_seconds))

    echo "Resource status: $status, Age: $((resource_age_seconds / 60)) minutes"

    if [[ "$status" == "$STATUS" ]]; then
        echo "Resource $RESOURCE_TYPE $RESOURCE_NAME has reached the status $STATUS."
        exit 0
    fi

    if [[ "$resource_age_seconds" -gt "$MAX_AGE_SECONDS" ]]; then
        echo "Resource $RESOURCE_TYPE $RESOURCE_NAME exceeded the maximum age of $MAX_AGE_MINUTES minutes."
        exit 1
    fi

    sleep 10
done
