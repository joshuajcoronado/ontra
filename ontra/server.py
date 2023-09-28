import time

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root() -> dict[str, int]:
    return {"The current epoch time": int(time.time())}


# Perform a health check, and return a JSON response with the status
@app.get("/health", status_code=200)
def get_health() -> dict[str, str]:
    return {"status": "ok"}
