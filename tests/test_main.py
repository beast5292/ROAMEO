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
    
    def test_get_sights(self):
        response = client.get("/sights/")
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)

    def test_get_sight_by_id(self):
        response = client.get("/sights/1")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["id"], "1")

    def test_update_sight(self):
        response = client.put("/sights/1", json={
            "id": "1",
            "name": "Updated Tower",
            "description": "Updated description.",
            "modeName": "Updated Mode",
            "modeDescription": "Updated details.",
            "username": "testuser",
            "tags": ["updated", "popular"],
            "lat": 48.8584,
            "long": 2.2945,
            "imageUrls": ["https://example.com/updated.jpg"]
        })
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["message"], "Sightseeing mode updated successfully")

    def test_delete_sight(self):
        response = client.delete("/sights/1")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["message"], "Sightseeing mode deleted successfully")

    def test_register_user(self):
        response = client.post("/users/register", json={
            "username": "testuser",
            "email": "test@example.com",
            "dob": "2000-01-01",
            "password": "securepassword"
        })
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()["message"], "User registered successfully")

    def test_login_user(self):
        response = client.post("/users/login", json={
            "email": "test@example.com",
            "password": "securepassword"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.json())

if __name__ == "__main__":
    unittest.main()
