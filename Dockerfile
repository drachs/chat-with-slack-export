
FROM ubuntu:22.04

ENV GOLANG_VERSION 1.19.6

# Build Essentials
RUN apt update && apt install -y build-essential

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

# Wget, Openssh, git
RUN apt install -y wget openssh-client git

# Install Go
#RUN wget https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
#RUN tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz
#RUN rm -f go${GOLANG_VERSION}.linux-amd64.tar.gz

#ENV PATH "$PATH:/usr/local/go/bin"

LABEL base.name="chat-with-slack"

WORKDIR /app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
#COPY go.mod go.sum ./
#RUN go mod download && go mod verify

COPY . .

#RUN go build -o microservice .

pip install -r requirements.txt

EXPOSE 9000

ENTRYPOINT ["/app/make start"]