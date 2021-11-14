FROM python:3.10.0-alpine3.14

# Ugh
RUN apk add cargo

RUN apk add --no-cache libressl-dev \
        musl-dev libffi-dev \
        make gcc libtool \
        libxml2 libxslt \
        g++ libxslt-dev \
        libjpeg-dev zlib1g-dev

WORKDIR /app
COPY . .

COPY pyproject* /app/
COPY poetry* /app/

RUN pip install lxml

RUN pip install poetry --no-cache-dir \
    && poetry config virtualenvs.create false \
    && poetry install \
    && pip install .
