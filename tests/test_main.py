import pytest
from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

def test_add_sights():
    response = client.post("/sights/", json=[{"name": "Eiffel Tower", "location": "Paris", "description": "Famous landmark."}])
    assert response.status_code == 200
    assert response.json()["message"] == "Sightseeing mode added successfully"

def test_get_sights():
    response = client.get("/sights/")
    assert response.status_code == 200
    assert "sights" in response.json()

def test_signup():
    response = client.post("/signup", json={
        "username": "testuser",
        "email": "test@example.com",
        "dob": "2000-01-01",
        "password": "password123"
    })
    assert response.status_code == 200
    assert "token" in response.json()

def test_login():
    response = client.post("/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 200
    assert "token" in response.json()

def test_user_endpoint():
    login_response = client.post("/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    token = login_response.json()["token"]
    
    response = client.get("/user", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert "user" in response.json()
