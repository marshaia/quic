from typing import List, Dict
from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import os
import shutil
import subprocess

class Parameters(BaseModel):
  id: str
  answer: str
  test_file: str
  tests: List[Dict[str, str]]

app = FastAPI()

@app.post("/test")
def test_participant_code(parameters: Parameters):
  # create temporary test directory
  path = "/tmp/" + parameters.id
  clean(path)
  os.mkdir(path)
  os.chdir(path)

  # write parameters into respective files
  with open("main.c", "w") as file:
    file.write(parameters.test_file)
  with open("aux.c", "w") as file:
    file.write(parameters.answer)

  # compile files
  try:
    subprocess.run(["gcc", "main.c", "aux.c", "-o", "main", "-Wall"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=5)
    return test_compiled_code(parameters, path)

  except subprocess.TimeoutExpired:
    clean(path)
    raise HTTPException(status_code=400, detail="Compilation Timeout")
  except subprocess.CalledProcessError:
    clean(path)
    raise HTTPException(status_code=400, detail="Compilation Error")


def test_compiled_code(parameters: Parameters, path):
  os.chdir(path)

  for test in parameters.tests:
    input_data = []
    expected_output = test["output"]
    if "input" in test:
     input_data = test["input"].replace(',', ' ')

    try:
      result = subprocess.run(["./main"], input=input_data.encode(), check=True, capture_output=True, timeout=5,)
      actual_output = result.stdout.decode()

      if actual_output != expected_output:
        return {"result": "incorrect"}

    except subprocess.TimeoutExpired:
      clean(path)
      raise HTTPException(status_code=400, detail="Timeout on Test: {input: " + test["input"] + " - output: " + expected_output + "}")
    except subprocess.CalledProcessError:
      clean(path)
      raise HTTPException(status_code=400, detail="Error Running Test: {input: " + test["input"] + " - output: " + expected_output + "}")
    except UnicodeDecodeError:
      clean(path)
      raise HTTPException(status_code=400, detail="Output Encode Error on Test: {input: " + test["input"] + " - output: " + expected_output + "}")
  
  clean(path)
  return {"result": "correct"}


def clean(path):
  if os.path.exists(path):
    shutil.rmtree(path)