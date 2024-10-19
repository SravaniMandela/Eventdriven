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

