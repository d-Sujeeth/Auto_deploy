# Dockerized FastAPI Application with Watchtower and Traefik

This project demonstrates how to run a Dockerized FastAPI application with Watchtower for automatic updates and Traefik as a reverse proxy/load balancer using Docker Compose.

## Prerequisites

- **Docker**: Ensure Docker is installed on your machine.
- **Docker Hub Account**: Create an account to push your Docker images.
- **Docker Compose**: Install Docker Compose for easier multi-container management.

## Setup Steps

### 1. Create Your FastAPI Application

Create a simple FastAPI app in `app/main.py`:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"Hello": "World"}
```

### 2. Create a Dockerfile

Add a Dockerfile to the root of your project:

```Dockerfile
# Dockerfile
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

COPY ./app /app

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
```

### 3. Create a Traefik Configuration

Create a Traefik configuration file `traefik/traefik.yml`:

```yaml
entryPoints:
  web:
    address: ":80"

providers:
  docker:
    exposedByDefault: false

api:
  dashboard: true
```

Create an `acme.json` file for SSL certificates:

```bash
touch traefik/acme.json
chmod 600 traefik/acme.json
```

### 4. Create a Docker Compose File

Create a `docker-compose.yml` file in the root directory:

```yaml
version: '3.8'

services:
  app:
    image: sujeethcloud/one:latest
    build:
      context: .
      dockerfile: Dockerfile
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`localhost`)"
      - "traefik.http.services.app.loadbalancer.server.port=80"
    networks:
      - backend

  traefik:
    image: traefik:v2.5
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "./traefik/traefik.yml:/traefik.yml"
      - "./traefik/acme.json:/acme.json"
    networks:
      - backend

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 60 --cleanup sujeethcloud/one
    networks:
      - backend

networks:
  backend:
```

### 5. Build and Push Your Image

Build and push your Docker image:

```bash
# Build the Docker image
docker build -t sujeethcloud/one:latest .

# Push the Docker image to Docker Hub
docker push sujeethcloud/one:latest
```

### 6. Start the Services

Run Docker Compose to start all services:

```bash
docker-compose up -d
```

## Verification

Check the logs of Watchtower and Traefik to verify they are running correctly:

```bash
docker logs watchtower
docker logs traefik
```

Access your FastAPI application via Traefik at `http://localhost`, and the Traefik dashboard at `http://localhost:8080`.

## Troubleshooting

If updates are not detected:

- **Verify Image Tags**: Ensure your image is correctly tagged as `latest`.
- **Re-push Image**: Push a new version of your image to Docker Hub.
- **Clear Docker Cache**: If necessary, clear the Docker cache:

```bash
docker system prune
```

If Traefik is not routing requests:

- **Check Traefik Logs**: Look for errors or warnings.
- **Ensure Docker Labels**: Add appropriate labels to your FastAPI container to expose it to Traefik.
