from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os

app = FastAPI(title="MyApp API", version="1.0.0")


class HealthResponse(BaseModel):
    status: str
    version: str
    environment: str


@app.get("/health", response_model=HealthResponse)
def health_check():
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        environment=os.getenv("ENVIRONMENT", "dev"),
    )


@app.get("/")
def root():
    return {"message": "Welcome to MyApp API"}
