from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return "Hello Ex-President Mr.Pradeep"

@app.get("/app")
def read_root():
    return "Hello Ex-President Mr.Pradeep"
