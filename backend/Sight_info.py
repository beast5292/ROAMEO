from pydantic import BaseModel
from typing import List,Optional

class Sight(BaseModel):
    modeName: Optional[str] = None
    modeDescription: Optional[str] = None
    username: Optional[str] = None
    id: str
    name: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[List[str]] = None
    lat: Optional[float] = None
    long: Optional[float] = None
    imageUrls: Optional[List[str]] = None

