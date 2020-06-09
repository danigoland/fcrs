FROM python:3.8.3-slim
MAINTAINER Dani Goland <glossman@gmail.com>


COPY requirements.txt requirements.txt

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc g++ libpq-dev python-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove gcc g++ python-dev
