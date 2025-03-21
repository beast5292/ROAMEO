import sys
import os
import unittest
from fastapi.testclient import TestClient

# Confirming that the backend folder is in the path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app  

client = TestClient(app)

class TestFastAPI(unittest.TestCase):
    def test_signup(self):
        # Change this data when making push request, as it will be stored in firestore db
        user_data = {
            "username": "testuser",
            "email": "testuser@example.com",
            "dob": "1990-01-01",
            "password": "password123"
        }
        
        response = client.post("/signup", json=user_data)
        
        self.assertEqual(response.status_code, 200)
        
        self.assertIn("message", response.json())
        self.assertEqual(response.json()["message"], "User registered successfully")
        self.assertIn("token", response.json())

if __name__ == "__main__":
    unittest.main()
