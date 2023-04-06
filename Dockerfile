
FROM ubuntu:22.04

ENV GOLANG_VERSION 1.19.6

# Build Essentials
RUN apt update && apt install -y build-essential

# Some Standard Linux command line tools to inspect network environments
RUN apt install -y net-tools iputils-ping dnsutils

# Install Docker CE CLI
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Docker Compose
RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
    && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Python Deps
RUN apt install -y pip

RUN apt install -y wget openssh-client git unzip

LABEL base.name="chat-with-slack"

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir docs-json
COPY slack-export.zip .
RUN cd docs-json && unzip ../slack-export.zip

RUN mkdir docs-txt
COPY slack_archive_to_text.py .
RUN python3 ./slack_archive_to_text.py

COPY ingest.py .
ARG OPENAI_API_KEY
RUN python3 ingest.py

RUN rm -rf docs-json docs-txt

COPY . . 

EXPOSE 9000

ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENTRYPOINT ["/usr/local/bin/uvicorn",  "main:app",  "--reload",  "--port",  "9000", "--host", "0.0.0.0"]
#ENTRYPOINT ["/bin/bash"]