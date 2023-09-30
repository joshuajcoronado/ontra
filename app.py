import json
import time


def handler(event, context):
    response = {
        "statusCode": 200,
        "body": json.dumps({"The current epoch time": int(time.time())}),
        "headers": {
            "Content-Type": "application/json"
        }
    }

    return response
