import json
import requests
import traceback

def lambda_handler(event, context):
    """
    This function calls the timeapi.io service to get the current time for Singapore
    and returns it in the response.
    """
    api_url = "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Singapore"
    
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        
        time_data = response.json()
        
        current_time = time_data.get("dateTime")

        return {
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps({
                "message": "Successfully fetched the time for Singapore!",
                "currentTime": current_time
            })
        }

    except requests.exceptions.RequestException as e:
        print(f"Error calling API: {e}")
        traceback.print_exc()
        
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Failed to fetch time: {e}"})
        }