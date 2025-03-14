from pydantic import BaseModel

class User(BaseModel):
    name: str
    email: str
    dob: str
    password: str  
