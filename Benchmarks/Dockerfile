FROM heavyai/core-os-cuda:latest

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .

RUN pip install -r requirements.txt

