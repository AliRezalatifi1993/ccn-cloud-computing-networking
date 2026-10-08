FROM python:3.8-slim

RUN pip3 install Flask requests

COPY ./ /app

EXPOSE 5000

WORKDIR /app

CMD ["python3", "add1.py"]
