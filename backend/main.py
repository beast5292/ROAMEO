'''
from fastapi import FastAPI,HTTPException
from typing import List
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app
from typing import List
import asyncio
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
    doc_ref = db.collection("sights").document()  #Firestore will auto-generate the document ID
    doc_ref.set({"sights": sight_dicts})  


    # Add to the local array
    sights_db.append(sight_dicts)
    print("Current sights_db:", sights_db)
    return {"message": "Sightseeing mode added successfully"}


#get all the sights from the db
@app.get("/sights/")
async def get_sights():

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
    
'''
from fastapi import FastAPI, HTTPException
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi.middleware.cors import CORSMiddleware

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

# Add CORS middleware to allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True
)
