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
            "name": "Statue of Liberty",
            "description": "Symbol of freedom and democracy.",
            "modeName": "Historical Landmark",
            "modeDescription": "A significant monument in the USA.",
            "username": "testuser",
            "tags": ["monument", "USA", "history"],
            "lat": 40.6892,
            "long": -74.0445,
            "imageUrls": ["https://example.com/statueofliberty.jpg"]
        }])
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["message"], "Sightseeing mode added successfully")
    
    def test_register_user(self):
        response = client.post("/signup", json={
            "username": "beast1234",
            "email": "beast@example.com",
            "dob": "2004/01/04",
            "password": "beast123"
        })
        self.assertEqual(response.status_code, 200) 
        self.assertEqual(response.json()["message"], "User registered successfully")
        self.assertIn("token", response.json())

if __name__ == "__main__":
    unittest.main()
