import json
import boto3

sns = boto3.client('sns')

TOPIC_ARN = "arn:aws:sns:ap-south-1:674113923575:root-login-alerts"

def lambda_handler(event, context):

    message = json.dumps(event, indent=2)

    sns.publish(
        TopicArn=TOPIC_ARN,
        Subject="AWS Root Account Login Detected",
        Message=message
    )

    return {
        "statusCode": 200,
        "body": "Alert sent"
    }