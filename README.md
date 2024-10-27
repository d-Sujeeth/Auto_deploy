# FastAPI and Traefik and watchtower Docker Setup

This repository contains a Dockerized FastAPI application, configured with Traefik as a reverse proxy and load balancer. The setup includes Watchtower for automatic container updates.

## Project Structure

```
.
├── docker-compose.yml
├── Dockerfile
└── app
    └── app.py
```

## Components

### FastAPI

A simple FastAPI application that responds with a greeting.

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return "Hello Void"
```

### Dockerfile

The Dockerfile used to build the FastAPI application:

```Dockerfile
FROM python:3.10-alpine 

WORKDIR /app

COPY . /app

RUN pip install uvicorn FastAPI

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### docker-compose.yml

The Docker Compose configuration for deploying the application with Traefik and Watchtower.

```yaml
version: '3.8'

services:
  fastapi:
    image: sujeethcloud/image:latest
    deploy:
      replicas: 3
      mode: replicated
    ports:
      - "8000:8000"  # Explicit port mapping
    networks:
      - backend
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=PathPrefix(`/backend`)"
      - "traefik.http.services.backend.loadbalancer.server.port=8000"

  traefik:
    image: traefik:v2.5
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    networks:
      - backend
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    command: --interval 30

networks:
  backend:
    driver: bridge
```

## How to Run

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build and run the containers:
   ```bash
   docker-compose up --build
   ```

3. Access the FastAPI application at `http://localhost:8000` and the Traefik dashboard at `http://localhost:8080`.

## Load Balancing

Traefik routers manage incoming requests and direct them to the appropriate service while also enabling load balancing by distributing requests across multiple service instances, ensuring high availability and performance.
