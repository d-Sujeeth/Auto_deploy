FROM python:3.10-alpine 

WORKDIR /app

COPY . /app

RUN pip install uvicorn Fastapi

EXPOSE 6666

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "6666"]

