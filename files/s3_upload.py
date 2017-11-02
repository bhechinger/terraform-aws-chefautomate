#!/usr/bin/env python

import boto3, sys

bucket_name = sys.argv[1]
validator_key = sys.argv[2]
admin_key = sys.argv[3]
region = sys.argv[4]

s3 = boto3.client('s3')
s3.create_bucket(Bucket=bucket_name)

s3.upload_file(validator_key, bucket_name, "{r}-{k}".format(r=region, k=validator_key))
s3.upload_file(admin_key, bucket_name, "{r}-{k}".format(r=region, k=admin_key))
