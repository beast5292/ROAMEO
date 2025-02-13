from fastapi import FastAPI
from typing import List
from Sight_info import Sight

app = FastAPI()

@app.post("/sights/")
async def receive_sights(sights:List[Sight]): # type: ignore
    print("Received Sights: ", sights)
    return {"message": "Sights received successfully", "count": len(sights)}


