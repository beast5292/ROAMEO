from fastapi import FastAPI
from typing import List
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app
from typing import List
import firebase_admin

#Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate(r'C:\IIT\2nd year\SDGP\Project\ROAMEO Sulaiman\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-1e1297f52f.json') 
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
    doc_ref = db.collection("sights").document()  # Firestore will auto-generate the document ID
    doc_ref.set({"sights": sight_dicts})  

    # Add to local storage
    sights_db.append(sight_dicts)
    print("Current sights_db:", sights_db)
    return {"message": "Sightseeing mode added successfully"}


#get a sight from the db
@app.get("/sights/")
async def get_sights():
    return {"sights": sights_db}

#get selected sight by index
@app.get("/sights/{index}")
async def get_sight_mode(index: int):
    if index < 0 or index >= len(sights_db):
        return {"error": "Invalid index"}
    return {"sight_mode": sights_db[index]}