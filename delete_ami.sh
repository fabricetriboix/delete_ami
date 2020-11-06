#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: AWS_PROFILE=myprofile $0 {AMI_ID}"
    echo "  AWS_ID  ID(s) of the AMI(s) to delete"
    echo
    echo "Make sure you set the AWS_PROFILE environment variable"
    echo "prior to calling this script, or some other way to"
    echo "authenticate to AWS, in which case you must still set the"
    echo "AWS_DEFAULT_REGION environment variable."
    echo
    echo "Eg: AWS_PROFILE=myprofile $0 ami-01233245"
    exit 1
}

if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" || $1 == "help" ]]; then
    usage
fi
[[ -v AWS_PROFILE || -v AWS_DEFAULT_REGION ]] || usage

snapshot_ids=$(aws ec2 --output text describe-images --image-ids "$@" --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId')

for id in "$@"; do
    aws ec2 deregister-image --image-id "$id"
    echo "Successfully deregistered image $id"
done

for id in $snapshot_ids; do
    aws ec2 delete-snapshot --snapshot-id "$id"
    echo "Successfully deleted snapshot $id"
done
