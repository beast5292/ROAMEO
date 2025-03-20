import sys
import os
import unittest
from fastapi.testclient import TestClient

# Ensure the backend folder is in the path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app  

client = TestClient(app)

class TestFastAPI(unittest.TestCase):
    def test_add_sights(self):
        response = client.post("/sights/", json=[{
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
    
    def test_get_sights(self):
        response = client.get("/sights/")
        self.assertEqual(response.status_code, 200)
        self.assertIn("sights", response.json())  # Checking for correct response structure

    def test_get_sight_by_id(self):
        # First, add a sight to get a valid document ID
        add_response = client.post("/sights/", json=[{
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
        self.assertEqual(add_response.status_code, 200)

        # Get all sights to retrieve a valid document ID
        get_response = client.get("/sights/")
        self.assertEqual(get_response.status_code, 200)
        sights = get_response.json()["sights"]
        self.assertTrue(len(sights) > 0)

        doc_id = sights[0]["id"]  # Get the first document ID
        response = client.get(f"/sights/{doc_id}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["id"], doc_id)

    def test_register_user(self):
        response = client.post("/signup", json={
            "username": "beast5292",
            "email": "beast@example.com",
            "dob": "2004/01/04",
            "password": "beast123"
        })
        self.assertEqual(response.status_code, 200)  # Should be 200, not 201
        self.assertEqual(response.json()["message"], "User registered successfully")
        self.assertIn("token", response.json())

    def test_login_user(self):
        response = client.post("/login", json={
            "email": "beast@example.com",
            "password": "beast123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.json())

if __name__ == "__main__":
    unittest.main()
