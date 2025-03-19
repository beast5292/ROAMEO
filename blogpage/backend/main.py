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

# Endpoint to create a blog post
@app.post("/create-blog")
async def create_blog(blog: dict):
    try:
        blog['likes'] = 0  # Default to 0
        blog['dislikes'] = 0  # Default to 0
        blog['userLikesDislikes'] = {}  # Track user interactions

        blog_ref = db.collection("blogs").document()
        blog_ref.set(blog)

        return {"message": "Blog created successfully!", "id": blog_ref.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



# Endpoint to update like/dislike count
@app.put("/update-like-dislike/{blog_id}")
async def update_like_dislike(blog_id: str, interaction: dict):
    try:
        blog_ref = db.collection("blogs").document(blog_id)
        blog = blog_ref.get()

        if not blog.exists:
            raise HTTPException(status_code=404, detail="Blog not found")

        blog_data = blog.to_dict()

        user_id = interaction["user_id"]  # Get the user ID
        is_like = interaction["is_like"]  # True for like, False for dislike

        # Check if the user has already liked/disliked
        user_interactions = blog_data.get("userLikesDislikes", {})

        if user_id in user_interactions:
            return {"message": f"You have already {user_interactions[user_id]}d this post."}

        # Update likes/dislikes count
        if is_like:
            updated_likes = blog_data.get("likes", 0) + 1
            blog_ref.update({
                "likes": updated_likes,
                f"userLikesDislikes.{user_id}": "like"
            })
        else:
            updated_dislikes = blog_data.get("dislikes", 0) + 1
            blog_ref.update({
                "dislikes": updated_dislikes,
                f"userLikesDislikes.{user_id}": "dislike"
            })

        # Return updated data
        return {"message": "Blog updated successfully", "likes": updated_likes if is_like else blog_data["likes"],
                "dislikes": updated_dislikes if not is_like else blog_data["dislikes"]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))





# Endpoint to fetch all blogs
@app.get("/blogs")
async def get_blogs():
    try:
        blogs = db.collection("blogs").stream()
        blog_list = [{"id": blog.id, **blog.to_dict()} for blog in blogs]
        return {"blogs": blog_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


    

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
