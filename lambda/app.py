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
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown"
    }
    try:
        response = requests.post(telegram_api_url, json=payload)
        response.raise_for_status()
        print(f"Successfully sent message to chat_id: {chat_id}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending message to Telegram: {e}")

def lambda_handler(event, context):
    """Handles incoming messages from Telegram via API Gateway."""
    bot_token = get_bot_token()
    if not bot_token:
        # If we can't get the token, we can't do anything.
        return {"statusCode": 500, "body": "Internal server error: Bot token not configured."}

    try:
        print("Received event:", json.dumps(event))
        
        body = json.loads(event.get("body", "{}"))
        message = body.get("message", {})
        chat_id = message.get("chat", {}).get("id")
        user_text = message.get("text", "").strip().lower()

        if not chat_id:
            print("Event is not a recognizable Telegram message.")
            return {"statusCode": 200, "body": "Not a Telegram message"}

        # --- Bot Logic ---
        if user_text == "/start":
            reply_text = "Hello! I am a Lambda-powered bot. Try the `/time` command."
        elif user_text == "/time":
            time_api_url = "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Singapore"
            time_response = requests.get(time_api_url)
            time_response.raise_for_status()
            time_data = time_response.json()
            current_time = time_data.get("dateTime")
            reply_text = f"The current time in Singapore is: *{current_time}*"
        else:
            reply_text = "Sorry, I don't understand that command. Try `/start` or `/time`."

        send_message(chat_id, reply_text, bot_token)

    except Exception as e:
        print(f"An unhandled error occurred in the main handler: {e}")
        traceback.print_exc()

    return {"statusCode": 200, "body": "Message processed"}