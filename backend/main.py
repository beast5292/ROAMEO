from fastapi import FastAPI,HTTPException
from typing import List
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app
from typing import List
import asyncio
import firebase_admin
from user_model import User

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
    

#Signup route endpoints
@app.post("/signup")
async def signup(user: User):
    try:
        user_ref = db.collection("users").document()
        # Saving the user data
        user_ref.set(user.dict()) 
        return {"message": "User registered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))