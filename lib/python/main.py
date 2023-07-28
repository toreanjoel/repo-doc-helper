import sys
import os

# these are all the tools we have access to for our agents
from langchain import OpenAI
from langchain.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.chains import RetrievalQA

# check the main function
# take args as params to pass to function
# output the response - success/error
if __name__ == '__main__':
    input = sys.argv[1]
    open_ai_key = sys.argv[2]

    os.environ["OPENAI_API_KEY"] = open_ai_key

    # loading in the file or text document
    # the path starts at the root of the application
    loader = TextLoader('./_MODEL_DATA/model_data.txt')
    document = loader.load()

    # split the document into chunks
    # this means that its small enough so it loads in
    # splits by double and one line and space
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=100, chunk_overlap=50)
    texts = text_splitter.split_documents(document)

    # embeddings
    # A vast library of text embeddings, vector base data around multi factors to find how they relate
    # i.e cows, chickens will be closer being animals while cars, bike could be vehicles
    # taking words and sentacnes, mapping them to how they relate and new things will be closer together
    embeddings = OpenAIEmbeddings()

    # vector store
    # Chroma, opensource, lightwight embedding database
    # Stores to a local chroma database that we can query
    store = Chroma.from_documents(texts, embeddings, collection_name="langchain-read-doc")
    # query
    # setup open ai then use the LLM and use Retrieval QA to perform data retrieval on the stored data
    llm = OpenAI(temperature=1)
    chain = RetrievalQA.from_chain_type(llm, retriever=store.as_retriever())
    # print(input, end="")
    print(chain.run(input), end="")