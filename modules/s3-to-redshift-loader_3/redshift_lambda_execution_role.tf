resource "aws_iam_role" "redshift_lambda_execution" {
  name               = "redshift_lambda_execution_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : ["redshift.amazonaws.com", "lambda.amazonaws.com"]
          }
          "Action" : "sts:AssumeRole"
        }
      ]
    })
  tags = {
    tag-key = "redshift-lambda-execution"
  }
}

resource "aws_iam_role_policy" "redshift_access" {
  name = "redshift_lambda_execution_policy"
  role = aws_iam_role.redshift_lambda_execution.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "KMSDecrypt",
          "Effect" : "Allow",
          "Action" : "kms:Decrypt",
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
          "Sid" : "EC2VPCAccess",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    })
}