import firebase_admin
from firebase_admin import credentials, firestore, storage, initialize_app

# Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate('C:\IIT\2nd year\SDGP\Project\ROAMEO Sulaiman\ROAMEO\backend\private key\roameo-f3ab0-firebase-adminsdk-ss40k-04eb540eda.json') #Download the credentials JSON from Firebase Console

initialize_app(cred)

db = firestore.client()  # Get Firestore client

