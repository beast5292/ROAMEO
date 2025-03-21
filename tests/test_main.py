import sys
import os
import unittest
from fastapi.testclient import TestClient

# Ensure the backend folder is in the path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app  

client = TestClient(app)

class TestFastAPI(unittest.TestCase):
    def test_signup(self):
        # Example data for testing signup
        user_data = {
            "username": "testuser",
            "email": "testuser@example.com",
            "dob": "1990-01-01",
            "password": "password123"
        }
        
        response = client.post("/signup", json=user_data)
        
        # Ensure the status code is 200
        self.assertEqual(response.status_code, 200)
        
        # Ensure the response contains a message and a token
        self.assertIn("message", response.json())
        self.assertEqual(response.json()["message"], "User registered successfully")
        self.assertIn("token", response.json())

if __name__ == "__main__":
    unittest.main()
