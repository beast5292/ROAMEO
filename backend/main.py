from fastapi import FastAPI
from typing import List
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app
from typing import List
import firebase_admin

#Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate(r'C:\IIT\2nd year\SDGP\Project\ROAMEO Sulaiman\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-04eb540eda.json') 
initialize_app(cred)

#Firestore client initialization
db = firestore.client()

app = FastAPI()

#temporary storage for sights
sights_db = []

#add a sight to the db
@app.post("/sights/")
async def add_sights(sights:List[Sight]): #type: ignore

    #Save the received sights to Firebase Firestore
    for sight in sights:
        sight_dict = sight.dict()
        sight_ref = db.collection("sights").document(sight.id)  #Use the sight's id as document ID
        sight_ref.set(sight_dict)  #Save the sight data to Firestore

    #Add the array as one sightseeing mode
    sights_db.append([sight.dict() for sight in sights])
    print("Current sights_db:", sights_db)  # Print the updated array
    return {"Message": "Sightseeing mode added successfully"}


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