FROM python:3.9

# Set the working directory in the container
WORKDIR /code_grader

# Install gcc
RUN apt-get update && \
    apt-get -y install gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container at /code_grader
COPY requirements.txt ./
# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the rest to the container
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the FastAPI server (using Uvicorn) when the container launches
CMD ["fastapi", "run", "main.py"]
