from fastapi import FastAPI, HTTPException, Query, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List
from backend.Sight_info import Sight
from backend.user_model import User
from backend.login_model import LoginRequest
import bcrypt
import jwt
import datetime
import os
import json
from firebase_admin import credentials, firestore, initialize_app

# Load Firebase credentials from environment variable
firebase_credentials = os.getenv("FIREBASE_CREDENTIALS")
if not firebase_credentials:
    raise ValueError("FIREBASE_CREDENTIALS environment variable is not set")

# Parse JSON credentials
cred_dict = json.loads(firebase_credentials)
cred = credentials.Certificate(cred_dict)
initialize_app(cred)

# Firestore client initialization
db = firestore.client()

app = FastAPI()

security = HTTPBearer()
JWT_SECRET = "CItLOTX5KLDS2VLeitv2n5tsftt5m9SwJNIrQsQsyjc="

# Temporary storage for sights
sights_db = []

# Add a sight to the database
@app.post("/sights/")
async def add_sights(sights: List[Sight]):
    sight_dicts = [sight.dict() for sight in sights]
    doc_ref = db.collection("sights").document()
    doc_ref.set({"sights": sight_dicts})
    sights_db.append(sight_dicts)
    return {"message": "Sightseeing mode added successfully", "document_id": doc_ref.id}

# Get all sights from the database
@app.get("/sights/")
async def get_sights():
    return_sights = []
    docs = db.collection("sights").stream()
    for doc in docs:
        sight_data = doc.to_dict().get("sights", [])
        return_sights.append({"id": doc.id, "sights": sight_data})
    return {"sights": return_sights}

# Get a sight by document ID
@app.get("/sights/{docId}")
async def get_sight_by_id(docId: str):
    doc = db.collection("sights").document(docId).get()
    if doc.exists:
        return {"id": doc.id, "sights": doc.to_dict().get("sights", [])}
    raise HTTPException(status_code=404, detail="Sight not found")

# Password hashing and verification
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

# JWT Token Handling
def create_jwt_token(email: str):
    payload = {"sub": email, "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)}
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

def verify_jwt_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        return jwt.decode(credentials.credentials, JWT_SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Signup endpoint
@app.post("/signup")
async def signup(user: User):
    try:
        user_ref = db.collection("users").document()
        user_ref.set({
            "username": user.username,
            "email": user.email,
            "dob": user.dob,
            "password": hash_password(user.password)
        })
        return {"message": "User registered successfully", "token": create_jwt_token(user.email)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Login endpoint
@app.post("/login")
async def login(user: LoginRequest):
    try:
        user_ref = db.collection("users").where("email", "==", user.email).stream()
        user_doc = next(user_ref, None)
        if not user_doc:
            raise HTTPException(status_code=400, detail="Invalid email or password")
        user_data = user_doc.to_dict()
        if not verify_password(user.password, user_data["password"]):
            raise HTTPException(status_code=400, detail="Invalid email or password")
        token = create_jwt_token(user.email)
        user_doc.reference.update({"token": token})
        return {"message": "Login successful", "token": token}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Get user endpoint
@app.get("/user")
async def get_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_email = verify_jwt_token(credentials).get("sub")
        user_ref = db.collection("users").where("email", "==", user_email).stream()
        user_doc = next(user_ref, None)
        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")
        return {"user": user_doc.to_dict()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
