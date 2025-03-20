from fastapi.testclient import TestClient
import sys
import os
import pytest

# Ensure the backend module is discoverable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend.main import app  # Import FastAPI app

client = TestClient(app)

@pytest.fixture
def sample_sight():
    """Provides sample data for sight creation."""
    return [{
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
    }]

def test_add_sights(sample_sight):
    """Tests adding a sightseeing mode via POST request."""
    response = client.post("/sights/", json=sample_sight)
    
    assert response.status_code == 200
    json_response = response.json()

    assert "message" in json_response
    assert json_response["message"] == "Sightseeing mode added successfully"
