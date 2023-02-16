terraform {
  required_version = "> 1.3"
}

# provider "aws" {
#   profile = var.aws_profile
#   region  = var.aws_region
# }

resource "aws_iam_role" "fds_resources_access_role" {
  name = var.fds_resources_access_role
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com", "sqs.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "fds_resources_access" {
  name = "${var.fds_resources_access_role}_policy"
  role = aws_iam_role.fds_resources_access_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "KMSDecrypt",
        "Effect" : "Allow",
        "Action" : "kms:Decrypt",
        "Resource" : "*"
      },
      {
        "Sid" : "SNSSubscription",
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3ObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject*",
          "s3:PutObject*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3List",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "BasicSQSPolicy",
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "BasicLambdaExecution",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
    }
  )
}

