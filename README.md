# RAG Flutter App
## Introduction
The RAG Flutter App is a mobile application that utilizes Retrieval Augmented Generation (RAG) on the frontend, powered by a Flask backend. The app aims to provide a conversational interface, where users can interact with an AI-powered chatbot and receive responses that are generated using the RAG model.

## Architecture
The RAG Flutter App is built using a client-server architecture. The frontend is developed using the Flutter framework, which interacts with the backend Flask application. The Flask application hosts the RAG model and the necessary endpoints for the mobile app to communicate with.

### The key components of the architecture are:

## Frontend (Flutter)
Responsible for the user interface and handling user interactions.
Integrates with the Flask backend to send user messages and receive AI-generated responses.
## Backend (Flask)
Hosts the RAG model and the necessary API endpoints.
Provides a chat endpoint that the mobile app can use to send user messages and receive AI-generated responses.
Includes a text-to-speech endpoint powered by Elevenlabs, which converts the AI-generated text responses into audio streams.
Both the chat endpoint and the text-to-speech endpoint are deployed on Render.com.
Features
Retrieval Augmented Generation (RAG)
The mobile app integrates the RAG model, which generates responses based on the user's input and the information retrieved from a knowledge base.
The RAG model is accessed through the Flask chat endpoint, which is deployed on Render.com.
Text-to-Speech with Elevenlabs
The mobile app utilizes the Elevenlabs text-to-speech endpoint, also deployed on Render.com, to convert the AI-generated responses into audio streams.
Currently, there are issues with correctly fetching and playing the audio responses in the application.
Latency Improvements
The mobile app is experiencing latency issues, which need to be addressed.
The plan is to implement streaming of the *AI-generated messages to improve the user experience and reduce latency.
This will require changes in both the Flask chat endpoint and the frontend Flutter code.
User Authentication
User authentication needs to be added to the application to manage user accounts and data.
Collaboration
We welcome collaborators to help us achieve the following goals:

### A. Activate Mic Recorder and Integrate Whisper Transcription API

Integrate a transcription API, such as Whisper, to enable users to speak into the app and have their speech converted to text, which can then be sent to the backend for generating responses.
### B. Improve Audio Response Handling

Address the issues with the current audio response handling, ensuring that the Elevenlabs text-to-speech output is correctly fetched and played in the mobile app.
### C. Implement Streaming for AI-generated Messages

Modify the Flask chat endpoint and the frontend Flutter code to enable streaming of the AI-generated messages, improving the user experience and reducing latency.
### D. Implement User Authentication

Add user authentication functionality to the application, allowing users to create accounts and manage their data.
Getting Started
To set up the development environment and run the RAG Flutter App locally, please follow these steps:

Clone the repository: git clone https://github.com/Datascientist88/Flutter_RAG_APP
Install the required dependencies for the Flutter frontend and the Flask backend.
Set up the necessary environment variables, such as API keys and deployment configurations.
Run the Flutter app and the Flask backend separately in your local development environment.
Detailed instructions will be provided in the repository's README file.

## Deployment
The RAG Flutter App is currently deployed on Render.com, with the Flask backend hosting the RAG model and the necessary API endpoints. Any additional deployment steps will be outlined in the README file.

## Contributing
We welcome contributions to the RAG Flutter App project. To contribute, please follow these guidelines:

Report issues or suggest features by creating a new issue in the repository.
Fork the repository, make your changes, and submit a pull request.
Follow the code of conduct and ensure your contributions align with the project's goals and standards.
Contact
For any questions or inquiries, please reach out to the project maintainers at [https://bahageel1.onrender.com/].

## License
The RAG Flutter App is released under the MIT License.