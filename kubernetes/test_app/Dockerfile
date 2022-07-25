FROM python:3.10.4-slim

COPY . /src
WORKDIR /src

RUN apt-get update && apt-get install -y gcc g++ python3-dev
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80
CMD ["python", "-m", "uvicorn", "main:app", "--port", "80", "--host", "0.0.0.0"]