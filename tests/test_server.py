from fastapi import FastAPI
from fastapi.testclient import TestClient
from ontra.server import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "The current epoch time" in response.json()
    assert isinstance(response.json()["The current epoch time"], int)


def test_get_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
