# python:3.13.14-trixie
FROM python@sha256:54e7879ce487f34f8ee85fc37e7547e843a2358bbcb19ecc273869e9d9fcc7dc

COPY ./docker/generate-story/requirements.txt /tmp/requirements.txt

RUN pip install --require-hashes -r /tmp/requirements.txt --no-cache-dir