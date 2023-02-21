import json
import os

import boto3


def lambda_handler(event, context):
    print("event collected is {}".format(event))

    # copy from s3 using the access point
    src_bucket = os.getenv("src_bucket")
    dst_bucket = os.getenv("dst_bucket")
    q_url = os.getenv("q_url")
    s3_key = _get_file_location(event)

    extra_args = {
        'RequestPayer': 'requester'
    }

    s3 = boto3.resource('s3')
    sqs = boto3.resource('sqs')

    copy_source = {
        'Bucket': src_bucket,
        'Key': s3_key
    }
    try:
        s3.meta.client.copy(CopySource=copy_source, Bucket=dst_bucket, Key=s3_key, ExtraArgs=extra_args)
        m_body = {
            "src_path": f"{dst_bucket}/{s3_key}",
            "file_name": s3_key
        }
        m_group_id = "folder_path"
        sqs.meta.client.send_message(MessageBody=m_body, MessageGroupId=m_group_id, QueueUrl=q_url)
    except Exception as e:
        print(e)


def _get_file_location(event):
    body = json.loads(event['Records'][0]["body"])
    message = body["Message"]
    location = message.split(',')[0]
    return location.split('=')[1]
