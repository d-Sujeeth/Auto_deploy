step 1:
Create a fastapi code on a file named app.py
write a dockerfile for it,to build a fasta pi image 

FROM python:3.10-alpine

WORKDIR /app

COPY . /app

RUN pip install uvicorn Fastapi

EXPOSE 6666

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "6666"]

