from fastapi.testclient import TestClient

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app

client = TestClient(app)

def test_add_sights():
    response = client.post("/sights/", json=[{
        "id": "1",
        "name": "Eiffel Tower",
        "description": "Famous landmark.",
        "modeName": "Tourist Spot",
        "modeDescription": "Iconic place to visit.",
        "username": "testuser",
        "tags": ["historical", "popular"],
        "lat": 48.8584,
        "long": 2.2945,
        "imageUrls": ["https://example.com/eiffel.jpg"]
    }])
    assert response.status_code == 200
    assert response.json()["message"] == "Sightseeing mode added successfully"
