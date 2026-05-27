import json
import boto3

sns = boto3.client('sns')

TOPIC_ARN = "arn:aws:sns:ap-south-1:674113923575:root-login-alerts"

def lambda_handler(event, context):

    bucket = event["detail"]["requestParameters"]["bucketName"]

    sns.publish(
        TopicArn=TOPIC_ARN,
        Subject="S3 Bucket Made Public",
        Message=f"Warning! Bucket {bucket} may have been made public."
    )

    return {
        "statusCode": 200
    }