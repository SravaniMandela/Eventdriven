event["Records"]: This refers to a list of records in the event. When something happens in S3 (like uploading a file), AWS creates an event, and that event has a list of "records" with details about what happened.

[0]: This grabs the first record from that list (since the list can contain multiple records, but here we're just looking at the first one).

["s3"]: This accesses the part of the record related to the S3 bucket (since the event can include other information).

["bucket"]["name"]: This gets the name of the bucket from that S3 information.

Why Use S3 Client?
S3 client is useful because it allows the Lambda function to programmatically interact with S3.

To use s3 client we need to import boto3 - to interact with s3
extract the body and read it in byte io
ByteIO(img)--> load the image in memory
Pillow Library: The image is processed using Pillow to create a thumbnail.
PIL library (now maintained as Pillow) to open an image from a byte stream
Image.open: This opens an image file. In this case, instead of providing a file path, it opens the image from a byte stream.
BytesIO(file_byte_string): This converts the byte string (which contains the image data) into an in-memory file-like object that Pillow can read.
Archive provider - which is required for bundling the source into a zip file and then upload into the lambda
data archive -> to archive the source code

aws lambda permission resource: assigning permission to trigger lambda when there is an upload to s3

aws_s3_bucket_notification = to trigger lambda from source bucket we need to do the actual process in this.