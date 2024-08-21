FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY __init__.py __init__.py
COPY test_main.py test_main.py
COPY run.sh run.sh

CMD ["./run.sh"]
