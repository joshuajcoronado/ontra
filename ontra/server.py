import time

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"The current epoch time": int(time.time())}


# Perform a health check, and return a JSON response with the status
@app.get("/health", status_code=200)
def get_health():
    return {"status": "ok"}
