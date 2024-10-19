# DynamoDB table creation in Terraform
resource "aws_dynamodb_table" "image_metadata_table" {
  name           = "ImageMetadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ImageName"     

  attribute {
    name = "ImageName"
    type = "S"
  }

  attribute {
    name = "ThumbnailName"
    type = "S" 
  }

  attribute {
    name = "OriginalSize"
    type = "S" 
  }

  attribute {
    name = "ThumbnailSize"
    type = "S" 
  }

  global_secondary_index {
     name               = "ThumbnailNameIndex"
    hash_key           = "ThumbnailName" # Partition key for the GSI
    projection_type    = "ALL"  # Project all attributes into the index
    read_capacity      = 5
    write_capacity     = 5
  }

  global_secondary_index {
    name               = "ThumbnailSizeIndex"
    hash_key           = "ThumbnailSize" # Partition key for the GSI
    projection_type    = "ALL"  # Project all attributes into the index
    read_capacity      = 5
    write_capacity     = 5
  }

  # Global Secondary Index (GSI) for querying by OriginalSize
  global_secondary_index {
    name               = "OriginalSizeIndex"
    hash_key           = "OriginalSize" # Partition key for the GSI
    projection_type    = "ALL"  # Project all attributes into the index
    read_capacity      = 5
    write_capacity     = 5
  }

  tags = {
    Name = "ImageMetadataTable"
  }
}

# Update to add permissions for DynamoDB to the Lambda role
resource "aws_iam_policy" "thumbnail_dynamodb_policy" {
  name   = "thumbnail_dynamodb_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem",        # Allow PutItem action
          "dynamodb:GetItem"       # (Optional) If you want Lambda to read from DynamoDB as well
        ],
        "Resource": "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/ImageMetadata" 
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_policy_attachment" "thumbnail_dynamodb_policy_attachment" {
  name       = "thumbnail_dynamodb_policy_attachment"
  roles      = [aws_iam_role.thumbnail_lambda_role.name]
  policy_arn = aws_iam_policy.thumbnail_dynamodb_policy.arn
}
