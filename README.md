# Documentation

## Uvicorn  
The server that will be used to test and run the FastAPI application.

## Using the Swagger UI page to test the URLS
http://127.0.0.1:8000/docs#

## Use the following command to start the FastAPI app
uvicorn main:app --host 0.0.0.0 --port 8000
uvicorn runs the FastAPI app.
- --host 0.0.0.0 makes the app accessible from any device, not just the local machine. 
- Without this, you can only make requests from the same computer where the server is running.
- --port 8000 sets the app to run on port 8000.
