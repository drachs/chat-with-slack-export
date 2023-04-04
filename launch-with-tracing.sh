#!/bin/bash

if [[ ! -v OPENAI_API_KEY ]]; then
    echo You must set OPENAI_API_KEY environmental variable
fi

langchain-server & 

export LANGCHAIN_ENDPOINT=http://langchain-langchain-backend-1:8000
export LANGCHAIN_HANDLER=langchain

# Wait for the langchain backend container to come online
while ! docker ps | grep langchain-langchain-backend; do
    sleep 1s
done

# Little grace period
sleep 2s

# Connect this container to the langchain network
docker network connect langchain_default chat-with-slack

make start & 

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?