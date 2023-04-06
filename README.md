# 🦜️🔗 ChatLangChain

This repo is an implementation of a locally hosted chatbot specifically focused on question answering over a slack export using Docker.

It is derived from (hwchase17/chat-langchain) https://github.com/hwchase17/chat-langchain

1. Export your data from slack and place the zip file in this folder as slack-export.zip
2. Use the following command with your own OpenAI API key to build the image and calculate the document embeddings
   a. `docker build -t chat-with-slack --build-arg=OPENAI_API_KEY=sk-...`
3. Run the image with this command
   a. `docker run -d -p 9000:9000/tcp chat-with-slack`
4. Connect to the app at http://127.0.0.1:9000 and ask your questions

