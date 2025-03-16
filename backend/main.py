import asyncio
import firebase_admin
from fastapi import FastAPI, HTTPException, Query
from typing import List, Dict
from Sight_info import Sight
from firebase_admin import credentials,firestore, initialize_app

# Initialize FastAPI
app = FastAPI()

#Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate(r'F:\GITHUB\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-1e1297f52f.json') 
initialize_app(cred)
db = firestore.client() #Firestore client initialization

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

#get request for search
@app.get("/search_sights/")
async def search_sight(place: str = Query(...)):
    print(f"Received search query: {place}")  # Debugging log


    sights_ref = db.collection("sights")
    docs = sights_ref.stream()  # Print all documents in Firestore for debugging
    
    results = []

    for doc in docs:
        doc_data = doc.to_dict()
        
        # Ensure 'sights' field exists and is a list
        if "sights" in doc_data and isinstance(doc_data["sights"], list):
            for sight in doc_data["sights"]:
                if "name" in sight and place.lower() in sight["name"].lower():
                    results.append(sight)

        print("Filtered Sights:", results)

        if results:
            return {"message": "Sights found", "data": results}
        else:
            return {"message": "No sights found", "data": []}

    

 
# # Following is for debug to see if fast API is working or not
# from fastapi import FastAPI

# app = FastAPI()

# @app.get("/search_sights/")
# async def search_sights(name: str):
#     return {"results": [{"name": "Test Location", "lat": 6.921, "long": 79.882}]}