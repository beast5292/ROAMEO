import pytest
from httpx import AsyncClient
from backend.main import app 
from backend.Sight_info import Sight

@pytest.mark.asyncio
async def test_add_sights():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/sights/", json=[{"name": "Eiffel Tower", "location": "Paris"}])
        assert response.status_code == 200
        assert response.json()["message"] == "Sightseeing mode added successfully"

@pytest.mark.asyncio
async def test_get_sights():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/sights/")
        assert response.status_code == 200
        assert "sights" in response.json()


@pytest.mark.asyncio
async def test_get_sight_by_id():
    async with AsyncClient(app=app, base_url="http://test") as client:
        sights_response = await client.get("/sights/")
        sights = sights_response.json().get("sights", [])
        if sights:
            doc_id = sights[0]["id"]
            response = await client.get(f"/sights/{doc_id}")
            assert response.status_code == 200
            assert "sights" in response.json()


@pytest.mark.asyncio
async def test_signup():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/signup", json={
            "username": "testuser",
            "email": "testuser@example.com",
            "dob": "2000-01-01",
            "password": "password123"
        })
        assert response.status_code == 200
        assert "token" in response.json()

@pytest.mark.asyncio
async def test_login():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/login", json={
            "email": "testuser@example.com",
            "password": "password123"
        })
        assert response.status_code == 200
        assert "token" in response.json()

@pytest.mark.asyncio
async def test_get_user():
    async with AsyncClient(app=app, base_url="http://test") as client:
        login_response = await client.post("/login", json={
            "email": "testuser@example.com",
            "password": "password123"
        })
        token = login_response.json().get("token")
        headers = {"Authorization": f"Bearer {token}"}
        response = await client.get("/user", headers=headers)
        assert response.status_code == 200
        assert "user" in response.json()
