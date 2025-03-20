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
        self.assertIn("sights", response.json())

    def test_get_sight_by_id(self):
        doc_id = "some_valid_doc_id" 
        response = client.get(f"/sights/{doc_id}")
        if response.status_code == 200:
            self.assertIn("sights", response.json())
        else:
            self.assertEqual(response.status_code, 404)

    def test_signup(self):
        response = client.post("/signup", json={
            "username": "testuser",
            "email": "test@example.com",
            "dob": "2000-01-01",
            "password": "securepassword"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.json())

    def test_login(self):
        response = client.post("/login", json={
            "email": "test@example.com",
            "password": "securepassword"
        })
        self.assertIn(response.status_code, [200, 400, 401])  
        if response.status_code == 200:
            self.assertIn("token", response.json())

    def test_get_user(self):
        login_response = client.post("/login", json={
            "email": "test@example.com",
            "password": "securepassword"
        })
        if login_response.status_code == 200:
            token = login_response.json()["token"]
            headers = {"Authorization": f"Bearer {token}"}
            response = client.get("/user", headers=headers)
            self.assertEqual(response.status_code, 200)
            self.assertIn("user", response.json())
        else:
            self.assertIn(login_response.status_code, [400, 401])  

if __name__ == "__main__":
    unittest.main()