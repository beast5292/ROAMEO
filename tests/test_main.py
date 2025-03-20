import sys
import os
import unittest
from fastapi.testclient import TestClient

# Ensure the backend folder is in the path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app  # Import FastAPI app

client = TestClient(app)

class TestFastAPI(unittest.TestCase):
    def test_add_sights(self):
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
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["message"], "Sightseeing mode added successfully")

if __name__ == "__main__":
    unittest.main()
