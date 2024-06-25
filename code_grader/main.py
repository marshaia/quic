from typing import Union
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

class Parameters(BaseModel):
  participant_id: str
  participant_answer: str
  test_file: str


app = FastAPI()

@app.post("/")
def hello(parameters: Parameters):
  if parameters.participant_answer == "":
    raise HTTPException(status_code=400, detail="Invalid Participant Answer!")  
  elif parameters.test_file == "":
    raise HTTPException(status_code=400, detail="Invalid Test File!")  
  else:
    return parameters

# @app.get("/")
# def hello():
#   return "Hello World!"