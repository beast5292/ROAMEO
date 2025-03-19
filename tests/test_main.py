import pytest
from httpx import AsyncClient
from backend.main import app


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


@pytest.mark.asyncio
async def test_add_sight():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/sights/", json=[
            {"name": "Eiffel Tower", "location": "Paris", "description": "Famous tower in France"}
        ])
        assert response.status_code == 200
        assert response.json()["message"] == "Sightseeing mode added successfully"


@pytest.mark.asyncio
async def test_get_sights():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/sights/")
        assert response.status_code == 200
        assert "sights" in response.json()
