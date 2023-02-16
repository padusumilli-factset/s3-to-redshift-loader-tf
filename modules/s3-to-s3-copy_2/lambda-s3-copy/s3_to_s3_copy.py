import json
import boto3
import os


def lambda_handler(event, context):
    print("event collected is {}".format(event))

    # copy from s3 using the access point
    src_bucket = os.getenv("src_bucket")
    #  "ffd-stg-amercent-385-cp38ffh58uxrajma475d9t14sc17guse1b-s3alias"
    dst_bucket = os.getenv("dst_bucket")
    # 'fdss3-aci-data-bucket'
    s3_key = _get_file_location(event)
    # "pa-analytics-demo/PAP_EXTRACT_CHARACTERISTICS.txt"

    extra_args = {
        'RequestPayer': 'requester'
    }

    s3 = boto3.resource('s3')
    copy_source = {
        'Bucket': src_bucket,
        'Key': s3_key
    }
    try:
        s3.meta.client.copy(CopySource=copy_source, Bucket=dst_bucket, Key=s3_key, ExtraArgs=extra_args)
    except Exception as e:
        print(e)

    # client = boto3.client('s3')

    # result= client.list_objects(Bucket=src_bucket,RequestPayer='requester')
    # for o in result['Contents']:
    #     print(o['Key'])   


def _get_file_location(event):
    body = json.loads(event['Records'][0]["body"])
    message = body["Message"]
    location = message.split(',')[0]
    return location.split('=')[1]
