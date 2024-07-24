import os
from dotenv import load_dotenv
from flask import Flask, request, jsonify
import qdrant_client
from prompts import engineeredprompt
from langchain_core.messages import AIMessage, HumanMessage
from langchain_community.vectorstores.qdrant import Qdrant
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Load Qdrant collection name
collection_name = os.getenv("QDRANT_COLLECTION_NAME")

# Initialize the memory
memory = ConversationBufferMemory(return_messages=True)

# Initialize the LLM
llm = ChatOpenAI()

# Initialize the conversation chain
conversation_chain = ConversationChain(
    llm=llm,
    memory=memory,
)

# Get the vector store
def get_vector_store():
    client = qdrant_client.QdrantClient(
        url=os.getenv("QDRANT_HOST"),
        api_key=os.getenv("QDRANT_API_KEY"),
    )
    embeddings = OpenAIEmbeddings()
    vector_store = Qdrant(
        client=client,
        collection_name=collection_name,
        embeddings=embeddings,
    )
    return vector_store

vector_store = get_vector_store()

def get_context_retriever_chain(vector_store=vector_store):
    llm = ChatOpenAI()
    retriever = vector_store.as_retriever()
    prompt = ChatPromptTemplate.from_messages(
        [
            MessagesPlaceholder(variable_name="chat_history"),
            ("user", "{input}"),
            (
                "user",
                "Given the above conversation, generate a search query to look up in order to get information relevant to the conversation",
            ),
        ]
    )
    retriever_chain = create_history_aware_retriever(llm, retriever, prompt)
    return retriever_chain

def get_conversational_rag_chain(retriever_chain):
    llm = ChatOpenAI()
    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                engineeredprompt
            ),
            MessagesPlaceholder(variable_name="chat_history"),
            ("user", "{input}"),
        ]
    )
    stuff_documents_chain = create_stuff_documents_chain(llm, prompt)
    return create_retrieval_chain(retriever_chain, stuff_documents_chain)

def get_response(user_input):
    retriever_chain = get_context_retriever_chain(vector_store)
    conversation_rag_chain = get_conversational_rag_chain(retriever_chain)
    response_stream = conversation_rag_chain.stream(
        {"chat_history": memory.load_memory_variables(None)['history'], "input": user_input}
    )
    response_content = ""
    for chunk in response_stream:
        response_content += chunk.get("answer", "")
    return response_content

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_query = data.get('message', '')

    if not user_query:
        return jsonify({'response': 'No message provided'}), 400

    # Update chat history in memory
    memory.chat_memory.add_user_message(user_query)
    response = get_response(user_query)
    memory.chat_memory.add_ai_message(response)

    return jsonify({'response': response})

@app.route('/reset', methods=['POST'])
def reset():
    memory.clear()
    return jsonify({'message': 'Chat history reset'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)