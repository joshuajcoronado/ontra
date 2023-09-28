# Let's use a multistage file
FROM python:3.11.5-slim as builder

WORKDIR /app
# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install -U pip setuptools \
    && pip install poetry

# Install dependencies
COPY pyproject.toml /app/
COPY poetry.lock /app/
RUN poetry config virtualenvs.in-project true \
    && poetry install --no-interaction

FROM python:3.11.5-slim

# # use a non-root user
RUN useradd --create-home ontra
WORKDIR /home/ontra
USER ontra

# Copy installed dependencies from builder
COPY --from=builder /app/.venv /home/ontra/.venv
COPY ./ontra /home/ontra/ontra

CMD ["/home/ontra/.venv/bin/python3", "-m", "uvicorn", "ontra.server:app", "--host", "0.0.0.0", "--port", "80"]
