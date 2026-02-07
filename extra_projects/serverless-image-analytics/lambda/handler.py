import json
import boto3
import os
import time

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # 1. Get incoming file details from S3 Event
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            
            print(f"Processing image: {key} from bucket: {bucket}")

            # 2. Call AWS Rekognition to detect labels
            response = rekognition.detect_labels(
                Image={'S3Object': {'Bucket': bucket, 'Name': key}},
                MaxLabels=10,
                MinConfidence=75
            )
            
            labels = [{'Name': label['Name'], 'Confidence': float(label['Confidence'])} for label in response['Labels']]
            print(f"Detected labels: {json.dumps(labels)}")

            # 3. Save Analysis Result to DynamoDB
            item = {
                'image_id': key,
                'timestamp': int(time.time()),
                'bucket': bucket,
                'labels': labels,
                'status': 'PROCESSED'
            }
            
            table.put_item(Item=item)
            print(f"Successfully saved metadata to DynamoDB table: {table_name}")

        return {
            'statusCode': 200,
            'body': json.dumps('Image processed successfully!')
        }

    except Exception as e:
        print(f"Error processing image: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
