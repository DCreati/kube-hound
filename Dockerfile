# immagine di base di Python
FROM python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y curl
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH=$PATH:/root/.local/bin

COPY . .
# COPY pyproject.toml poetry.lock ./

RUN poetry install
ENTRYPOINT ["poetry", "run", "python", "-m", "kube_hound"]