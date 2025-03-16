from pydantic import BaseModel

class User(BaseModel):
    username: str
    email: str
    dob: str
    password: str  
