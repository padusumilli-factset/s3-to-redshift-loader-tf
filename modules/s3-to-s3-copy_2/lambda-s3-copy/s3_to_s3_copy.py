import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("event collected is {}".format(event))

    # copy from s3 using the access point
    src_bucket = os.getenv("src_bucket")
    dst_bucket = os.getenv("dst_bucket")
    topic_arn = os.getenv("topic_arn")

    extra_args = {
        'RequestPayer': 'requester'
    }

    s3 = boto3.resource('s3')
    sns = boto3.resource('sns')

    for record in event['Records']:
        s3_key = _get_file_location(record)
        copy_source = {
            'Bucket': src_bucket,
            'Key': s3_key
        }
        logger.info(f'CopySource={copy_source}, Bucket={dst_bucket}, Key={s3_key}, ExtraArgs={extra_args}')
        try:
            s3.meta.client.copy(CopySource=copy_source, Bucket=dst_bucket, Key=s3_key, ExtraArgs=extra_args)
            logger.info(f'Copied file successfully {copy_source}')

            m_body = json.dumps({
                "src_path": f"{dst_bucket}/{s3_key}"
            })
            m_group_id = "folder_path"
            m_attrs = {}
            topic = sns.Topic(topic_arn)
            logger.info(m_body)
            response = topic.publish(
                Message=m_body,
                MessageAttributes=m_attrs,
                MessageGroupId=m_group_id
            )
        except Exception as e:
            logger.error(e)


def _get_file_location(record):
    file_location = None
    try:
        body = record["body"]
        location = body.split(',')[0]
        file_location = location.split('=')[1]
    except Exception as e:
        logger.error(f'Unable to parse the S3 file location from the message event \n {e}, \n {record}')

    return file_location
