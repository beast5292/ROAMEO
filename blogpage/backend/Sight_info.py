from pydantic import BaseModel
from typing import List,Optional

class Sight(BaseModel):
    id:str
    name: str
    description: str
    tags: List[str]
    lat: Optional[float] = None
    long: Optional[float] = None
    imageUrls: List[str]

