from typing import List, Dict
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import shutil
import subprocess

class Parameters(BaseModel):
  id: str
  answer: str
  language: str
  test_file: str
  tests: List[Dict[str, str]]

app = FastAPI()

@app.post("/test")
def test_participant_code(parameters: Parameters):
  # check language validity
  if language_is_not_valid(parameters.language.strip()):
    raise HTTPException(status_code=400, detail="Invalid Language")

  # create temporary test directory
  path = "/tmp/" + parameters.id
  clean(path)
  os.mkdir(path)

  # write parameters into respective files
  write_files(parameters, path)
  
  try:
    # compile files in c
    if parameters.language.strip() == "c":
      os.chdir(path)
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
    input_data, expected_output = format_input_output(parameters.language.strip(), test)

    try:
      run_command = get_run_command(parameters.language.strip(), test["input"])
      result = subprocess.run(run_command, input=input_data.encode(), check=True, capture_output=True, timeout=5)
      actual_output = result.stdout.decode()

      if actual_output.strip() != expected_output.strip():
        return {"result": "incorrect", "detail": "Failed test with input " + test["input"] + ".\nExpected: " + expected_output + ", but got: " + actual_output}

    except subprocess.TimeoutExpired:
      clean(path)
      raise HTTPException(status_code=400, detail="Timeout on Test: {input: " + test["input"] + " - output: " + expected_output + "}")
    except subprocess.CalledProcessError:
      clean(path)
      raise HTTPException(status_code=400, detail="Error running test with input " + test["input"])
    except UnicodeDecodeError:
      clean(path)
      raise HTTPException(status_code=400, detail="Output Encode Error on Test: {input: " + test["input"] + " - output: " + expected_output + "}")
  
  clean(path)
  return {"result": "correct"}



def language_is_not_valid(language):
  return language not in ["c", "python"]


def clean(path):
  if os.path.exists(path):
    shutil.rmtree(path)


def format_input_output(language, test):
  input_data = ""
  expected_output = "" 

  if language != "python" and "input" in test:
    split = test["input"].split(',')
    input_data = ' '.join(split)
  if "output" in test:
    expected_output = test["output"]

  return input_data, expected_output



def write_files(parameters: Parameters, path):
  os.chdir(path)
  language = parameters.language.strip()
  
  if language == "c":
    with open("main.c", "w") as file:
      file.write(parameters.test_file)
    with open("aux.c", "w") as file:
      file.write(parameters.answer)

  elif language == "python":
    with open("main.py", "w") as file:
      file.write("exec(open('sub.py').read())\n\n" + parameters.test_file)
    with open("sub.py", "w") as file:
      file.write(parameters.answer)


# Command to run respective executables
def get_run_command(language, input):
  if language == "c":
    return ["./main"]

  elif language == "python":
    inputs = input.split(',')
    return ["python", "main.py"] + inputs