import json
import boto3
import uuid
import datetime
import os

# Rolle definieren
ADMIN_ROLE = "Admins-role"

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    try:
        # Routing basiert auf HTTP Methode
        if event['path'] == '/erstellen' and event['httpMethod'] == 'POST':
            return create_gast(event)
        elif event['path'] == '/loeschen' and event['httpMethod'] == 'POST':
            return delete_gast(event)
        else:
            return {
                'statusCode': 405,
                'body': json.dumps({'fehler': 'Methode nicht erlaubt'})
            }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'fehler': 'Interner Serverfehler beim Routing'})
        }

#Gast erstellen
def create_gast(event):
    try:
        body = json.loads(event['body'])
        name = body["name"]
        message = body["message"]

        # Validate input
        if not name or not message:
            return {
                'statusCode': 400,
                'body': json.dumps({'fehler': 'Name and message sind erforderlich'})
            }

        # Generate unique ID
        gast_id = str(uuid.uuid4())

        # Create new entry
        table.put_item(
            Item={
                'id': gast_id,
                'name': name,
                'message': message,
                'created_at': datetime.datetime.now().isoformat(),
            }
        )

        return {
            'statusCode': 201,
            'body': json.dumps({'id': gast_id, 'name': name, 'message': message})
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'fehler': 'Interner Serverfehler bei Erstellen'})
        }

def delete_gast(event):
    try:
        user_arn = event['requestContext']['identity']['userArn']
        body = json.loads(event['body'])
        gast_id = body["id"]

        # Get gast entry
        response = table.get_item(Key={'id': gast_id})
        item = response.get('Item')
            
        # Check if entry exists
        if not item:
            return {
                'statusCode': 404,
                'body': json.dumps({'fehler': 'Gast nicht gefunden'})
            }
        

        # Check if user is admin
        if user_arn and (ADMIN_ROLE in user_arn):
            is_admin = True
        else:
            is_admin = False

        #Nur Administratoren koennen Einträge loeschen
        if not is_admin:
            return {
                'statusCode': 403,
                'body': json.dumps({'fehler': 'Nur Administratoren koennen Einträge loeschen'})
            }

        # Gast loeschen
        table.delete_item(Key={'id': gast_id})

        return {
            'statusCode': 204,
            'body': json.dumps({'Ergebnis': 'Gast geloescht!'})
        }
        return True
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'fehler': 'Interner Serverfehler bein Loeschen'})
        }