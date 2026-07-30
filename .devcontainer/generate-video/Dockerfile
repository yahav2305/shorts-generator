# python:3.13.14-trixie
FROM python@sha256:54e7879ce487f34f8ee85fc37e7547e843a2358bbcb19ecc273869e9d9fcc7dc

COPY ./docker/generate-video/requirements.txt /tmp/requirements.txt

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --require-hashes -r /tmp/requirements.txt --no-cache-dir