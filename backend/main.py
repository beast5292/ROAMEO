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

#Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate(r'C:\Users\Mindula\Desktop\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-1e1297f52f.json') 
initialize_app(cred)

#Firestore client initialization
db = firestore.client()

app = FastAPI()

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
    

# Function to hash passwords
def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

# Signup route endpoint
@app.post("/signup")
async def signup(user: User):
    try:
        # Hashing the password before storing
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
    
# Signin/Login route endpoint    
@app.post("/login")
async def login(user: LoginRequest):
    print(f"Received data: {user.dict()}") 

    try:
        user_ref = db.collection("users").where("email", "==", user.email).stream()
        user_doc = next(user_ref, None)  

        if not user_doc:
            raise HTTPException(status_code=400, detail="Invalid email or password")

        user_data = user_doc.to_dict()
        stored_hashed_password = user_data.get("password")

        if not stored_hashed_password or not bcrypt.checkpw(user.password.encode('utf-8'), stored_hashed_password.encode('utf-8')):
            raise HTTPException(status_code=400, detail="Invalid email or password")

        return {"message": "Login successful", "redirect": "/home"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
