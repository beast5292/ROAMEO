from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware  
from pydantic import BaseModel
from typing import Dict
import bcrypt

app = FastAPI()

# CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

# Simulated user database
users_db: Dict[str, str] = {}  # Stores {username: hashed_password}

class User(BaseModel):
    username: str
    password: str

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed_password.encode())

@app.post("/signup")
def signup(user: User):
    if user.username in users_db:
        raise HTTPException(status_code=400, detail="User already exists")
    users_db[user.username] = hash_password(user.password)
    return {"message": "User registered successfully"}

@app.post("/signin")
def signin(user: User):
    if user.username not in users_db or not verify_password(user.password, users_db[user.username]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    return {"message": "Signin successful"}
