"""Load html from files, clean up, split, ingest into Weaviate."""
import pickle

#from langchain.document_loaders import ReadTheDocsLoader
from langchain.document_loaders import DirectoryLoader
from langchain.document_loaders import TextLoader
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.text_splitter import TokenTextSplitter
from langchain.vectorstores.faiss import FAISS


def ingest_docs():
    loader = DirectoryLoader("docs-txt", loader_cls=TextLoader)
    raw_documents = loader.load()

    print(f"Loaded {len(raw_documents)} chats...")
    #text_splitter = RecursiveCharacterTextSplitter(
    #    chunk_size=1000,
    #    chunk_overlap=200,
    #)
    text_splitter = TokenTextSplitter(
        chunk_size=400,
        chunk_overlap=50,
    )
    documents = text_splitter.split_documents(raw_documents)

    print("Writing out debug-docs.txt...")
    file = open('debug-docs.txt', 'w')
    for doc in documents:
        file.write(doc.metadata['source'])
        file.write("\n")
        file.write(doc.page_content)
        file.write("\n\n")
    print(f"Split chats into {len(documents)} documents...")

    embeddings = OpenAIEmbeddings()
    vectorstore = FAISS.from_documents(documents, embeddings)

    # Save vectorstore
    with open("vectorstore.pkl", "wb") as f:
        pickle.dump(vectorstore, f)


if __name__ == "__main__":
    ingest_docs()
