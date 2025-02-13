import firebase_admin
from firebase_admin import credentials, firestore, storage

# Initialize Firebase Admin SDK with your credentials
cred = credentials.Certificate('path/to/your/serviceAccountKey.json')  # Download the credentials JSON from Firebase Console
firebase_admin.initialize_app(cred, {
    'storageBucket': 'your-project-id.appspot.com'  # Replace with your Firebase Storage bucket URL
})

db = firestore.client()  # Get Firestore client
bucket = storage.bucket()  # Get Firebase Storage bucket
