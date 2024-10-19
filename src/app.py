import logging
import boto3
from io import BytesIO
from PIL import Image
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('ImageMetadata')

def lambda_handler(event, context):
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    
    # Get bucket and object key from the event
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    thumbnail_bucket = "cp-thumb-nail-image-bucket"
    thumbnail_name, thumbnail_ext = os.path.splitext(key)
    thumbnail_key = f"{thumbnail_name}_thumbnail{thumbnail_ext}"

    logger.info(f"Bucket name: {bucket}, file name: {key}, Thumbnail Bucket name: {thumbnail_bucket}, file name: {thumbnail_key}")

    s3_client = boto3.client('s3')

    # Load and open image from S3
    file_byte_string = s3_client.get_object(Bucket=bucket, Key=key)['Body'].read()
    img = Image.open(BytesIO(file_byte_string))
    original_size = img.size
    logger.info(f"Size before compression: {original_size}")

    # Generate thumbnail
    img.thumbnail((500, 500), Image.ANTIALIAS)
    thumbnail_size = img.size
    logger.info(f"Size after compression: {thumbnail_size}")

    # Dump and save image to S3
    buffer = BytesIO()
    img.save(buffer, "JPEG")
    buffer.seek(0)
    
    sent_data = s3_client.put_object(Bucket=thumbnail_bucket, Key=thumbnail_key, Body=buffer)

    if sent_data['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise Exception(f'Failed to upload image {key} to bucket {thumbnail_bucket}')

    # Store image metadata in DynamoDB
    try:
        table.put_item(
            Item={
                'ImageName': key,
                'ThumbnailName': thumbnail_key,
                'OriginalSize': str(original_size),  # Storing size as a string (width, height)
                'ThumbnailSize': str(thumbnail_size)
            }
        )
        logger.info(f"Image metadata stored in DynamoDB: {key}")
    except Exception as e:
        logger.error(f"Error storing image metadata in DynamoDB: {e}")
        raise e

    return event
