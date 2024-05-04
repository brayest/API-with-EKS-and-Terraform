# Use a base image with updated libpq (Debian bullseye)
FROM python:3.10-bullseye

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create and set the working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 8000

# Run the FastAPI application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
