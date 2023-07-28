import sys
import os

# these are all the tools we have access to for our agents
from langchain import OpenAI
from langchain.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.chains import RetrievalQA

# The path of the model data
model_path = './_MODEL_DATA/model_data.txt'

if __name__ == '__main__':
    input = sys.argv[1]
    open_ai_key = sys.argv[2]

    # Set the env variable for the python instance of being run
    os.environ["OPENAI_API_KEY"] = open_ai_key

    # loading in the file or text document
    loader = TextLoader(model_path)
    document = loader.load()

    # split the document into chunks
    # this means that its small enough so it loads in
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=0)
    texts = text_splitter.split_documents(document)

    # embeddings
    # A vast library of text embeddings, vector base data around multi factors to find how they relate
    embeddings = OpenAIEmbeddings()

    # Chroma, opensource, lightwight embedding database
    # Stores to a local chroma database that we can query
    store = Chroma.from_documents(texts, embeddings, collection_name="langchain-read-doc")

    # setup open ai then use the LLM and use Retrieval QA to perform data retrieval on the stored data
    llm = OpenAI(temperature=0.1)
    chain = RetrievalQA.from_chain_type(llm, retriever=store.as_retriever())
    print(chain.run(input), end="")