## App Logo
Click on a logo to download the latest version of the app apk file:

<a href="https://github.com/ArpitAswal/Voice-Genie/releases/download/v2.0.0/Voice_Genie.apk"> ![ic_launcher](https://github.com/user-attachments/assets/ae14f7dc-567c-4074-b86a-81aca50c71b0)</a>

# Project Title: Voice Genie

Description: Voice Genie is a Flutter-based mobile application that acts as a voice-powered AI assistant. It is designed for quick, intuitive, and hands-free interactions. Leveraging the power of Gemini API and Imagine API, this single-screen app can respond to both text-based and art/image-based prompts, making it a unique blend of conversational AI and visual creativity. Through its streamlined interface, users can quickly send queries and receive spoken or visual responses, enhanced by intuitive speech-to-text and text-to-speech capabilities.

## Features

* Voice Interaction: Users can speak prompts or queries by tapping a button, and the app converts speech to text. This method provides 80–90% accurate responses while avoiding confidential information.

* AI-Powered Responses: Text-based prompts are processed using Gemini API (Gemini 1.5 Flash model). Art displaying from prompts is handled through the Imagine API.

* Image-Based Prompts: Users can send images as prompts. The AI analyzes the image and provides text-based responses with relevant information or insights about the image.

* PDF Querying: Users can upload a single PDF file. The app extracts and processes the content, allowing users to query specific information from the PDF and receive text-based responses.

* Speech-to-Text: The app converts spoken queries into text, allowing users to interact hands-free.

* Text-to-Speech: Users can listen to AI responses, making information accessible and providing a conversational experience.

* Visual Response Display: Responses are presented in rounded, animated containers for a modern and engaging UI. Includes error messages for issues like missing permissions or network errors.

* Response Options: After receiving an AI-generated response, users can choose to: Ask another question, Listen to the AI response from start to finish, Clear previous interactions and reset the screen for new prompts.

* New & History Prompts: From the new version user can not just send prompts from the single screen but can send prompts from the history prompt section.

* Auto Prompt Title: whenever the user sends the new first prompt the app will automatically decide the prompt section title. additionally custom modify the title option available if a user does not like the auto title.

## Installation

To run this project locally:

1. Clone the repository:
   git clone https://github.com/ArpitAswal/Voice-Genie.git

2. Navigate to the project directory:
   cd Voice-Genie

3. Install dependencies:
   flutter pub get

4. Set up API Keys (Optional, depending on external services used):
   Obtain an API key from Gemini AI Studio & Imagine API.

   Create a new file named lib/config.dart in the project directory.

   Add the following code, replacing 'YOUR_API_KEY' with your News API key:

   class Config { static const String apiKey = 'YOUR_API_KEY'; }

   Or directly used in API networking calls.

5. Run the app:
   flutter run

## Note
* Users must grant audio record permission for the app to function, as it uses, the voice speech functionality to record the user prompt.

* ImagineAPI service is sometimes unavailable, and for more styling image responses try different style_id parameters, for more detail visit the ImagineAPI site.

* Make sure you add your API keys to run this program on your system. If you download the directly apk file from here you can not use the service of Imagine API because my account token is finished.

## Tech Stack

Flutter: The primary framework for building the mobile application.

Dart: The programming language used with Flutter.

Imagine API. for generating AI-driven image responses based on user prompts.

Gemini API: Gemini API for processing text-based queries and providing informative answers.

## Challenges

* Speech-To-Text: Ensuring it listens to all the user's words/sentences and performs well.

* Text-To-Speech: Managing the response speech by single response or full messages responses.

* Prompt History: Managing the new and old responses for a particular prompt section.

* Handling Responses: Managing the UI state whenever the prompt request is successful or failed, data is fetching from API and handling the listener when it speaks all the messages of the prompt.

## Future Enhancements

* Image-Based Query Analysis: A new feature will allow users to upload images to the app. Gemini AI will then analyze the uploaded image, describing its contents to provide deeper insights or contextual explanations about the image.

* Enhanced AI Art Capabilities: Future updates will improve the app’s art-based prompts with more creative or style-based responses to user queries.

* Multi-File PDF Analysis: Enable users to upload multiple PDFs and query across all documents.

## What's New

* Image-Based Query Analysis: A new feature will allow users to upload images to the app. Gemini AI will then analyze the uploaded image, describing its contents to provide deeper insights or contextual explanations about the image.

* Improve user experience by enhancing UI, adding animation and utilising boilerplate widgets.

* All the previous issues resolved

## Contributing

Contributions are always welcome!

Please follow these steps:

1. Fork the repository.

2. Create a new branch (git checkout -b feature-branch).

3. Make your changes and commit them (git commit -m 'Add new feature').

4. Push the changes to your fork (git push origin feature-branch).

5. Create a pull request.

## Usage Flow

* Starting the App: Voice Genie opens on a single main screen where users can immediately interact with AI by pressing the microphone button.
  Providing a Query: Users can speak their questions or prompts. The app detects the type of request:

![Screenshot_2024-11-09-14-40-35-503_com google android permissioncontroller](https://github.com/user-attachments/assets/67522054-7b0e-4bba-9953-bb388fd08818)
![Screenshot_2024-11-09-14-40-42-147_com example voice_assistant](https://github.com/user-attachments/assets/0a2eadea-5009-4db2-803b-4c96996c4990)

* Text-Based: The app processes queries with Gemini AI to provide textual answers.

![Screenshot_2024-11-09-14-41-21-355_com example voice_assistant](https://github.com/user-attachments/assets/e4709d3e-c49e-4740-aa28-605af21222c6)

* Art/Image-Based: Imagine API is used to generate visual answers.

* Displaying Results: The response, either in text or image form, appears in an animated container. Users can then: Ask a new question, Listen to the responses through text-to-speech, and Refresh the app to reset for new queries.

https://github.com/user-attachments/assets/46f86248-9e8b-44fe-89d2-06d15a8808d6

https://github.com/user-attachments/assets/2e529fa7-ca4b-4f51-ac4a-e0ab7e4fc0bf

https://github.com/user-attachments/assets/f47ceed6-2ff8-480c-9d0e-a2e182bd1cd4

* Handling Errors: If permissions are missing or connectivity fails, the app displays clear, specific messages to guide users in troubleshooting.

https://github.com/user-attachments/assets/3b1540d0-5d9d-4b9d-a873-6839a03898e7

https://github.com/user-attachments/assets/7086e24c-85ea-4cbe-a5fa-0ded94854adf

## Feedback

If you have any feedback, please reach out to me at arpitaswal995@gmail.com

If you face an issue, then open an issue in a GitHub repository.

## Design Philosophy

Voice Genie is a sophisticated AI assistant designed to be an intuitive, accessible way for users to explore information and art with minimal effort. With future updates, it aims to become an even more interactive and personalized companion. Voice Genie continues to evolve into a versatile and intelligent assistant, offering seamless interaction across multiple data types while providing users with personalized and accurate responses.