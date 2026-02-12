import json
import boto3
import os
import uuid
import time
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    http_method = event.get('httpMethod')
    path = event.get('path')
    resource = event.get('resource') # e.g. /blogs or /blogs/{id}
    
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
    }

    try:
        if http_method == 'GET':
            if resource == '/blogs':
                # Scan all blogs (for small scale this is fine)
                # For larger scale, use Query with an index
                response = table.scan()
                items = response.get('Items', [])
                # Sort by created_at desc
                items.sort(key=lambda x: x.get('created_at', 0), reverse=True)
                
                return {
                    'statusCode': 200,
                    'headers': headers,
                    'body': json.dumps(items, default=str)
                }
            elif resource == '/blogs/{id}':
                path_params = event.get('pathParameters', {})
                blog_id = path_params.get('id')
                if not blog_id:
                     return {
                        'statusCode': 400,
                        'headers': headers,
                        'body': json.dumps({'error': 'Missing id parameter'})
                    }
                
                response = table.get_item(Key={'id': blog_id})
                item = response.get('Item')
                
                if item:
                    return {
                        'statusCode': 200,
                        'headers': headers,
                        'body': json.dumps(item, default=str)
                    }
                else:
                    return {
                        'statusCode': 404,
                        'headers': headers,
                        'body': json.dumps({'error': 'Blog post not found'})
                    }

        elif http_method == 'POST':
            # Create new blog post
            try:
                body = json.loads(event.get('body', '{}'))
            except:
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({'error': 'Invalid JSON body'})
                }
            
            title = body.get('title')
            content = body.get('content')
            summary = body.get('summary')
            author = body.get('author', 'Admin')
            tags = body.get('tags', []) # List of strings
            
            if not title or not content:
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({'error': 'Title and content are required'})
                }
            
            blog_id = str(uuid.uuid4())
            timestamp = int(time.time())
            date_str = time.strftime('%Y-%m-%d', time.localtime(timestamp))
            
            item = {
                'id': blog_id,
                'title': title,
                'content': content,
                'summary': summary if summary else content[:100] + '...',
                'author': author,
                'tags': tags,
                'created_at': timestamp,
                'date': date_str
            }
            
            table.put_item(Item=item)
            
            return {
                'statusCode': 201,
                'headers': headers,
                'body': json.dumps(item)
            }
            
        elif http_method == 'OPTIONS':
             return {
                'statusCode': 200,
                'headers': headers,
                'body': ''
            }

        return {
            'statusCode': 400,
            'headers': headers,
            'body': json.dumps({'error': f'Unsupported method {http_method}'})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({'error': str(e)})
        }
