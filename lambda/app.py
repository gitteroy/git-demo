import json
import os
import requests
import boto3
import traceback

SECRET_NAME = "timetosaygoodbye-telegram-bot-token"
REGION_NAME = "ap-southeast-1"

def get_bot_token():
    """Fetches the bot token from AWS Secrets Manager."""
    try:
        secrets_client = boto3.client('secretsmanager', region_name=REGION_NAME)
        secret_response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
        secret_dict = json.loads(secret_response['SecretString'])
        return secret_dict['TELEGRAM_BOT_TOKEN']
    except Exception as e:
        print(f"FATAL: Could not retrieve bot token from Secrets Manager: {e}")
        traceback.print_exc()
        return None

def send_message(chat_id, text, bot_token):
    """Sends a message back to the Telegram user."""
    telegram_api_url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": str(chat_id),  # Ensure chat_id is string
        "text": text,
        "parse_mode": "HTML"  # Optional: allows HTML formatting
    }
    
    try:
        print(f"Sending message to chat_id: {chat_id}")
        print(f"Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            telegram_api_url, 
            json=payload,
            timeout=10  # Add timeout to prevent hanging
        )
        
        print(f"Telegram API response status: {response.status_code}")
        print(f"Telegram API response: {response.text}")
        
        response.raise_for_status()
        print(f"Successfully sent message to chat_id: {chat_id}")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"Error sending message to Telegram: {e}")
        print(f"Response content: {e.response.text if e.response else 'No response'}")
        return False

def lambda_handler(event, context):
    """Handles incoming messages from Telegram via API Gateway."""
    print(f"Received event: {json.dumps(event, indent=2)}")
    
    bot_token = get_bot_token()
    if not bot_token:
        return {
            "statusCode": 500, 
            "body": json.dumps({"error": "Internal server error: Bot token not configured."})
        }

    try:
        # Parse the request body
        body = json.loads(event.get("body", "{}"))
        print(f"Parsed body: {json.dumps(body, indent=2)}")
        
        message = body.get("message", {})
        chat_id = message.get("chat", {}).get("id")
        user_text = message.get("text", "").strip().lower()
        
        print(f"Chat ID: {chat_id}")
        print(f"User text: '{user_text}'")

        if not chat_id:
            print("No chat_id found in message")
            return {
                "statusCode": 200, 
                "body": json.dumps({"message": "Not a valid Telegram message"})
            }

        # Generate response based on user input
        if user_text == "/start":
            reply_text = "Hello! I am a simple Lambda-powered bot. Try the `/about` command."
        elif user_text == "/about":
            reply_text = "This bot runs on AWS Lambda and is now fast enough to avoid timeouts! 🚀"
        else:
            reply_text = "Sorry, I only understand `/start` and `/about`."

        # Send the message
        success = send_message(chat_id, reply_text, bot_token)
        
        if success:
            return {
                "statusCode": 200, 
                "body": json.dumps({"message": "Message sent successfully"})
            }
        else:
            return {
                "statusCode": 500, 
                "body": json.dumps({"error": "Failed to send message"})
            }

    except Exception as e:
        print(f"An unhandled error occurred in the main handler: {e}")
        traceback.print_exc()
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }