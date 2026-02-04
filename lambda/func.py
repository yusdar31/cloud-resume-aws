import json
import boto3
import os

# Inisialisasi koneksi ke DynamoDB
dynamodb = boto3.resource('dynamodb')
# Nama tabel diambil dari Environment Variable (diset via Terraform nanti)
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def handler(event, context):
    # Update item: tambah hitungan (atomic counter)
    response = table.update_item(
        Key={'id': 'visitor_count'}, # Kunci utama (Primary Key)
        UpdateExpression="ADD #v :inc",
        ExpressionAttributeNames={'#v': 'count'},
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW"
    )
    
    # Ambil nilai terbaru
    visitor_count = int(response['Attributes']['count'])
    
    # Kirim respon balik ke website (dengan Header CORS)
    return {
        'statusCode': 200,
        # Hapus bagian 'headers' sama sekali
        'body': json.dumps({"count": visitor_count})
    }