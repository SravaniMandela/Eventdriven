terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "4.36.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
    region = var.aws_region
}

resource "aws_iam_policy" "thumbnail_s3_policy" {
    name = "thumbnail_s3_policy"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::cp-original-image-bucket/*"
        }, {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::cp-thumbnail-image-bucket/*"
        }]
    })
}

resource "aws_iam_role" "thumbnail_lambda_role" {
    name = "thumbnail_lambda_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }]
    }) 
}

resource "aws_iam_policy_attachment" "thumbnail_role_s3_policy_attachment" {
    name = "thumbnail_role_s3_policy_attachment"
    roles = [ aws_iam_role.thumbnail_lambda_role.name ]
    policy_arn = aws_iam_policy.thumbnail_s3_policy.arn
}

resource "aws_iam_policy_attachment" "thumbnail_role_lambda_policy_attachment" {
    name = "thumbnail_role_lambda_policy_attachment"
    roles = [ aws_iam_role.thumbnail_lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

