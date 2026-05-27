import json
import boto3

sns = boto3.client('sns')

TOPIC_ARN = "arn:aws:sns:ap-south-1:674113923575:root-login-alerts:6a55b5ff-53dd-4120-a7af-5f15b558ec86"

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