import json
import requests

def lambda_handler(event, context):
    """
    This function calls the World Time API to get the current time for Singapore
    and returns it in the response.
    """
    try:
        # Call a public API
        response = requests.get("http://worldtimeapi.org/api/timezone/Asia/Singapore")
        response.raise_for_status()
        
        time_data = response.json()
        current_time = time_data.get("datetime")

        return {
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps({
                "message": "Successfully fetched the time for Singapore.",
                "currentTime": current_time
            })
        }

    except requests.exceptions.RequestException as e:
        # Handle potential network errors
        print(f"Error calling API: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Failed to fetch time: {e}"})
        }