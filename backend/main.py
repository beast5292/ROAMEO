from fastapi import FastAPI,HTTPException
from typing import List
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app
from typing import List
import asyncio
import firebase_admin
from user_model import User
from login_model import LoginRequest
import bcrypt
import jwt
import datetime
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends

#Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate(r'C:\Users\Mindula\Desktop\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-1e1297f52f.json') 
initialize_app(cred)

#Firestore client initialization
db = firestore.client()

app = FastAPI()

security = HTTPBearer()
JWT_SECRET = "CItLOTX5KLDS2VLeitv2n5tsftt5m9SwJNIrQsQsyjc="

#temporary storage for sights
sights_db = []

#add a sight to the db
@app.post("/sights/")
async def add_sights(sights:List[Sight]): #type: ignore

    sight_dicts = [sight.dict() for sight in sights]

    # Save the whole array as one record in Firestore
    doc_ref = db.collection("sights").document()  #Firestore will auto-generate the document ID
    doc_ref.set({"sights": sight_dicts})  


    # Add to the local array
    sights_db.append(sight_dicts)
    print("Current sights_db:", sights_db)
    return {"message": "Sightseeing mode added successfully"}


#get all the sights from the db
@app.get("/sights/")
async def get_sights():

    print("Recieved sights")

    return_sights = []
    docs = db.collection("sights").stream()

    for doc in docs:

        #Include document ID and the data
        sight_data = doc.to_dict().get("sights", [])

        return_sights.append({
            #model the response
            "id": doc.id,  
            "sights": sight_data
        })

    return {"sights": return_sights}


#get selected sight by index
@app.get("/sights/{docId}")
async def get_sight_by_id(docId: str):
    # Fetch the specific document from Firestore using the docId
    doc = db.collection("sights").document(docId).get()

    if doc.exists:
        sight_data = doc.to_dict().get("sights", [])
        #Print the received sight data
        print("Received sight data:", sight_data)
        return {"id": doc.id, "sights": sight_data}
    else:
        raise HTTPException(status_code=404, detail="Sight not found")  
    

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_jwt_token(email: str):
    expiration = datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    payload = {"sub": email, "exp": expiration}
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

def verify_jwt_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, JWT_SECRET, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/signup")
async def signup(user: User):
    try:
        hashed_password = hash_password(user.password)
        user_ref = db.collection("users").document()
        user_ref.set({
            "name": user.name,
            "email": user.email,
            "dob": user.dob,
            "password": hashed_password
        })
        return {"message": "User registered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
        return {"message": "Login successful", "token": token}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/user")
async def get_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        # verifying the JWT token
        payload = verify_jwt_token(credentials)
        # Extracting the email from the token
        user_email = payload.get("sub")  

        # Fetch user data from Firestore
        user_ref = db.collection("users").where("email", "==", user_email).stream()
        user_doc = next(user_ref, None)

        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        user_data = user_doc.to_dict()
        return {"user": user_data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
