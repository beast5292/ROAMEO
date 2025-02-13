from fastapi import FastAPI
from typing import List
from Sight_info import Sight

app = FastAPI()

#temporary storage for sights
sights_db = []

#add a sight to the db
@app.post("/sights/")
async def add_sights(sights:List[Sight]): # type: ignore
    # Add the array as one sightseeing mode
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