# 3.13-slim-trixie
FROM python@sha256:6771159cd4fa5d9bba1258caf0b82e6b73458c694d178ad97c5e925c2d0e1a91 AS builder

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir --target=/app/dependencies -r /app/requirements.txt

# nonroot
FROM gcr.io/distroless/python3-debian13@sha256:0e52dfee02b1aba142e77b004f6ea11210b79456b51f10d70e9bd631cbc21d98

WORKDIR /app

COPY --from=builder --chown=65532:65532 /app/dependencies /app/dependencies
COPY --from=builder --chown=65532:65532 /app/app.py /app/app.py

ENV PYTHONPATH=/app/dependencies

CMD ["/app/app.py"]