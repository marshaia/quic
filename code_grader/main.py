from typing import Union
from fastapi import FastAPI
from pydantic import BaseModel

class Name(BaseModel):
  name: str

app = FastAPI()

@app.get("/")
def hello():
  return "Hello World!"

@app.post("/")
def hello(name: Name):
  return "Hello " + name.name + "!"

# @app.get("/items/{item_id}")
# def read_item(item_id: int, q: Union[str, None] = None):
#   return {"item_id": item_id, "q": q}