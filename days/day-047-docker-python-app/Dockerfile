FROM python:3.12-slim

# Set working directory
WORKDIR /python_app

# Copy requirements first for better caching
COPY src/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY src/ .

# Expose port 8082
EXPOSE 8082

# Run the server
CMD ["python", "server.py"]

