from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (for development only)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)


# Example data model
class Item(BaseModel):
    name: str
    description: str = None
    price: float
    tax: float = None

# Example in-memory database
fake_db = []

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Welcome to FastAPI!"}

# Create an item
@app.post("/items/")
def create_item(item: Item):
    fake_db.append(item)
    return {"message": "Item created", "item": item}

# Get all items
@app.get("/items/")
def get_items():
    return {"items": fake_db}