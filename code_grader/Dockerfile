FROM python:3.9

# Set the working directory in the container
WORKDIR /code_grader

# Copy the requirements file into the container at /code_grader
COPY requirements.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the FastAPI server (using Uvicorn) when the container launches
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
CMD ["fastapi", "run", "main.py"]

# para executar:
# não esquecer de ir para a diretoria /code_grader 1º
# docker build -t code_grader_image .
# docker run -d (--restart always) --name code_grader_container -p 5000:8000 code_grader_image