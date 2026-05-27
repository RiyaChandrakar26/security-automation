resource "aws_iam_role" "lambda_role" {
  name = "root-alert-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "root_alert" {
  function_name = "root-login-alert"

  filename         = "../lambdas/root_alert.zip"
  source_code_hash = filebase64sha256("../lambdas/root_alert.zip")

  role    = aws_iam_role.lambda_role.arn
  handler = "root_alert.lambda_handler"
  runtime = "python3.12"

  timeout = 10
}

resource "aws_cloudwatch_event_rule" "root_login" {
  name        = "root-login-detection"
  description = "Detect AWS root account login"

  event_pattern = jsonencode({
    source      = ["aws.signin"]
    detail-type = ["AWS Console Sign In via CloudTrail"]

    detail = {
      userIdentity = {
        type = ["Root"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.root_login.name
  target_id = "RootLoginLambda"
  arn       = aws_lambda_function.root_alert.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.root_alert.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.root_login.arn
}

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda-sns-publish-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = "arn:aws:sns:ap-south-1:674113923575:root-login-alerts"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "s3_alert" {
  function_name = "s3-public-alert"

  filename         = "../lambdas/s3_remediate.zip"
  source_code_hash = filebase64sha256("../lambdas/s3_remediate.zip")

  role    = aws_iam_role.lambda_role.arn
  handler = "s3_remediate.lambda_handler"
  runtime = "python3.12"

  timeout = 10
}

resource "aws_cloudwatch_event_rule" "s3_public" {
  name        = "s3-public-detection"
  description = "Detect S3 bucket policy changes"

  event_pattern = jsonencode({
    source = ["aws.s3"]

    detail-type = [
      "AWS API Call via CloudTrail"
    ]

    detail = {
      eventSource = [
        "s3.amazonaws.com"
      ]

      eventName = [
        "PutBucketPolicy",
        "PutBucketAcl"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_public.name
  target_id = "S3AlertLambda"
  arn       = aws_lambda_function.s3_alert.arn
}

resource "aws_lambda_permission" "allow_eventbridge_s3" {
  statement_id  = "AllowExecutionFromEventBridgeS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_alert.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.s3_public.arn
}

