import sys
import os
import unittest
from fastapi.testclient import TestClient

# Ensure the backend folder is in the path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.main import app  # Import FastAPI app

client = TestClient(app)

class TestFastAPI(unittest.TestCase):
    def test_get_sight_by_id(self):
        doc_id = "1"
        response = client.get(f"/sights/{doc_id}")
        
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["id"], doc_id)
        self.assertIn("sights", data)
        
        # Ensure expected sight data is present
        self.assertEqual(data["sights"].get("name"), "Eiffel Tower")
        self.assertEqual(data["sights"].get("description"), "Famous landmark.")
        self.assertEqual(data["sights"].get("modeName"), "Tourist Spot")
        self.assertEqual(data["sights"].get("modeDescription"), "Iconic place to visit.")
        self.assertEqual(data["sights"].get("username"), "testuser")
        self.assertEqual(data["sights"].get("tags"), ["historical", "popular"])
        self.assertEqual(data["sights"].get("lat"), 48.8584)
        self.assertEqual(data["sights"].get("long"), 2.2945)
        self.assertEqual(data["sights"].get("imageUrls"), ["https://example.com/eiffel.jpg"])

if __name__ == "__main__":
    unittest.main()