import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/domain/usecases/generate_content.dart';
import 'package:voice_assistant/domain/usecases/title_generator.dart';
import 'package:voice_assistant/utils/alert_messages.dart';

import '../../data/adapters/models_adapter.dart';
import '../../data/hivedata/chat_data.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/repository/network_requests.dart';

class HomeController extends GetxController {
  // Dependencies
  final stt.SpeechToText speech =
      stt.SpeechToText(); // Handles speech-to-text functionality
  final FlutterTts _flutterTts =
      FlutterTts(); // Handles text-to-speech functionality
  final NetworkRequests _service =
      NetworkRequests(); // Makes API requests to custom network services
  final ChatData _chatData;
  final GenerateContentUseCase _generateContent;

  // Observable variables for UI updates
  final RxInt currentIndex = 0.obs; // to update the index of pages
  final RxInt initialAllChatBoxes = 0
      .obs; // indicate how many chat boxes already created whenever the app start
  final RxString greetingMessage =
      "".obs; // Stores the greeting message for display
  final RxString _userVoiceMsg =
      "".obs; // Stores the recognized user voice message from speech-to-text
  final RxString imageResponse =
      "".obs; // Store the image response that will received by gemini model
  final RxString _currentChatBoxID =
      "".obs; // to store current chat box where user send prompt
  final RxBool _speechEnabled =
      false.obs; // Flag to track if speech recognition is enabled
  final RxBool speechListen =
      false.obs; // Flag to indicate if app is actively listening to user speech
  final RxBool isTextPrompt =
      false.obs; // Flag to indicate if a text response is received
  final RxBool isLoading =
      false.obs; // Flag to show loading state when waiting for API response
  final RxBool isImagePrompt =
      false.obs; // Flag to determine if text-to-speech should stop
  final RxBool shouldTextAnimate =
      false.obs; // Flag to indicate the response text should re animate or not
  final RxBool isStopped =
      true.obs; // Flag to determine if text-to-speech should stop
  final RxBool isNewPrompt = true
      .obs; // Flag to determine whether current prompt is new or old chat prompt
  final RxList<HiveChatBoxMessages> messages =
      <HiveChatBoxMessages>[].obs; // List to hold conversation messages
  final RxList<HiveChatBox> totalChatBoxes =
      <HiveChatBox>[].obs; // List of all the previous chat/prompt box/folder
  final RxList<String> imagesFileList =
      <String>[].obs; // List of selected image files

  // Non-observable State
  final PageController _pageController =
      PageController(); // PageView controller
  final List<String> _messageQueue =
      []; // Queue for storing messages to be spoken by text-to-speech
  String _chatBoxTitle = ""; // to store the title of new prompt chat box

  HomeController({
    required ChatData chatData,
    required GenerateContentUseCase generateContent,
  })  : _generateContent = generateContent,
        _chatData = chatData;

  // Current page index getter
  String get currentChatBoxID => _currentChatBoxID.value;
  PageController get pageController => _pageController;
  int get currentAllChatBoxes => _chatData.getAllChatBoxes().length;

  // Update current page index
  void currentIndexValue(int value) {
    currentIndex.value = value;
  }

  // set current chat box id
  void setCurrentChatId({required String newChatId}) {
    _currentChatBoxID.value = newChatId;
  }

  // set current chat box title
  void changeChatBoxTitle({required String newChatTitle, String? chatId}) {
    _chatBoxTitle = newChatTitle;
    if (chatId != null) {
      final chat = _chatData.chatBox.get(chatId);
      chat!.title = _chatBoxTitle;
      chat.save().then((value) => {
            debugPrint("save: ${chat.messages.length}"),
            totalChatBoxes.value = _chatData.getAllChatBoxes()
          });
    }
  }

  void initializeTotalChatBoxes(
      {required bool delete, required bool firstTime}) {
    totalChatBoxes.value = _chatData.getAllChatBoxes();
    initialAllChatBoxes.value = totalChatBoxes.length - (delete ? 1 : 0);
    if (!firstTime) {
      totalChatBoxes.removeLast();
    }
  }

  Future<void> deleteChatBox({required String chatId}) async {
    bool b = await _chatData.deleteChatBox(chatId: chatId);
    if (b) {
      initializeTotalChatBoxes(delete: true, firstTime: false);
    } else {
      AlertMessages.showSnackBar(
          "Hive Error: something went wrong to deleting this ChatBox");
    }
  }

  @override
  void onInit() {
    super.onInit();
    initialize(); // Initialize greeting and speech services
    initializeTotalChatBoxes(delete: false, firstTime: true);
  }

  @override
  void onClose() {
    stopTTs(); // Stops any active text-to-speech
    stopListening(); // Stops any active speech-to-text
  }

  // Initializes greeting message, speech recognition, and TTS settings
  Future<void> initialize() async {
    await speechInitialize();
    await _flutterTts.setLanguage("en-US"); // Sets TTS language
    await _flutterTts.setSpeechRate(0.5); // Sets TTS speaking speed
    await _flutterTts.setVolume(1.0); // Sets TTS volume
    await _flutterTts.setPitch(1.0); // Sets TTS pitch
    _flutterTts.setCompletionHandler(
        _onSpeakCompleted); // Sets a handler for TTS completion
  }

  Future<void> askPermission() async {
    // Asks for microphone permission and opens settings if denied
    var requestStatus = await Permission.microphone.request();
    if (requestStatus.isDenied || requestStatus.isPermanentlyDenied) {
      await openAppSettings();
    } else if (requestStatus.isGranted) {
      speechInitialize(); // Initializes speech recognition if permission is granted
    }
  }

  // Callback to handle changes in the speech recognition status
  void _onSpeechStatus(String status) async {
    if (status == "notListening") {
      speechListen.value = false; // Updates flag when user stops speaking
      await Future.delayed(const Duration(
          seconds:
              2)); // here delay is used to store the speech words, if not it will miss the last word of your prompt
      _sendRequest(_userVoiceMsg.value); // Process the captured input
      stopListening(); // Stops speech recognition
    }
  }

  // Called when TTS completes a message, then checks for more messages in queue
  void _onSpeakCompleted() {
    if (!isStopped.value) {
      _speakNextMessage(); // Speak the next message if not stopped
    }
  }

  // Initializes the message queue for speaking and starts TTS
  void playTTs() async {
    for (var message in messages) {
      if (message.visualPath != null) _messageQueue.add(message.text);
    }
    isStopped.value = false;
    _flutterTts.setCompletionHandler(_onSpeakCompleted);
    await _speakNextMessage(); // Begins speaking messages in the queue
  }

  // Resets conversation messages and stops both TTS and speech recognition
  void resetAll() {
    messages.clear();
    _messageQueue.clear();
    initializeTotalChatBoxes(delete: false, firstTime: true);
    _chatBoxTitle = "";
    isTextPrompt.value = false;
    isImagePrompt.value = false;
    isNewPrompt.value = true;
    checkAlreadyCreated();
    stopTTs();
    stopListening();
  }

  // Initializes speech recognition and sets error handlers
  Future<void> speechInitialize() async {
    _speechEnabled.value = await speech.initialize(
        onStatus: (status) =>
            _onSpeechStatus(status), // Sets status change handler
        onError: (error) => AlertMessages.showSnackBar(
            error.errorMsg) // Shows error on initialization failure
        );
    if (!_speechEnabled.value) {
      AlertMessages.audioBottomSheet(
          "Speech recognition is not available on this device.");
    }
  }

  // Speaks the next message in the queue if available
  Future<void> _speakNextMessage() async {
    if (_messageQueue.isNotEmpty && !isStopped.value) {
      await _flutterTts
          .speak(_messageQueue.removeAt(0)); // Speaks the next message in queue
    } else {
      isStopped.value = true; // Sets stopped flag when queue is empty
    }
  }

  // Adds a message to the queue and starts TTS
  Future<void> speakTTs(String botResponse) async {
    isStopped.value = false;
    _messageQueue.add(botResponse);
    await _speakNextMessage();
  }

  // Adds a message to the queue and starts TTS
  Future<void> stopTTs() async {
    isStopped.value = true;
    await _flutterTts.stop();
  }

  // Each time to start a speech recognition session
  Future<void> startListening() async {
    speechListen.value = true;
    await speech.listen(
      onResult: (result) {
        _userVoiceMsg.value =
            result.recognizedWords; // Captures user's speech as text
      },
      listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode
              .dictation, // Use dictation mode for continuous listening
          cancelOnError: true),
      pauseFor: const Duration(seconds: 2),
    );
  }

  /// Manually stop the active speech recognition session Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the listen method.
  Future<void> stopListening() async {
    _userVoiceMsg.value = "";
    speechListen.value = false;
    await speech.stop();
  }

  // Sends user input to appropriate API and speaks the response if needed
  Future<void> _sendRequest(String input) async {
    try {
      isTextPrompt.value = true;
      if (input.isNotEmpty) {
        messages.add(HiveChatBoxMessages(
          text: input,
          isUser: true,
          visualPath: null,
        ));
        isLoading.value = true;

        final response = await _service.isArtPromptAPI(input);
        if (response == "YES") {
          await callImagineAPI(
              input); // Calls Imagine API if input asks for an image
        } else {
          await sendPrompt(
              input); // Calls Gemini API if text response is expected
        }
      } else {
        // Adds a default prompt message when no input is provided
        isTextPrompt.value = true;
        messages.add(HiveChatBoxMessages(
            text:
                "Please provide me with some context or a question so I can assist you.",
            isUser: true));
        _messageQueue.add(
            "Please provide me with some context or a question so I can assist you.");
        messages.add(HiveChatBoxMessages(
            text: "For example: Give me some Interview Tips.", isUser: false));
        _messageQueue.add("For example: Give me some Interview Tips.");
        isStopped.value = false;
        await _speakNextMessage();
      }
    } on AppException catch (e) {
      isLoading.value = false;
      messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {
      isLoading.value = false;
      messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
      AlertMessages.showSnackBar(e.toString());
    }
  }

  Future<void> sendPrompt(String prompt) async {
    isImagePrompt.value = false;

    if (imagesFileList.isNotEmpty) {
      messages.add(HiveChatBoxMessages(
        text: prompt,
        isUser: true,
        visualPath: List<String>.from(imagesFileList),
      ));
      isLoading.value = true;
    }

    try {
      final Stream<GenerateContentResponse> response =
          await _generateContent.execute(
              prompt: prompt,
              history: await getHistoryMessages(),
              message: (prompt.isEmpty) ? "Describe the images" : prompt,
              isTextOnly: imagesFileList.isEmpty,
              images: imagesFileList.map((image) => XFile(image)).toList());
      response.listen((event) {
        imageResponse.value += event.text.toString();
      }, onDone: () async {
        isLoading.value = false; // Ends loading state
        messages
            .add(HiveChatBoxMessages(text: imageResponse.value, isUser: false));
        speakTTs(imageResponse.value);
        imageResponse.value = "";
        if (isNewPrompt.value &&
            messages.length == 2 &&
            _chatBoxTitle.isEmpty) {
          setChatBoxTitle();
        }
        saveMessagesInDB();
        // save message to hive db
      }).onError((error, stackTrace) {
        isLoading.value = false; // Ends loading state
        AlertMessages.showSnackBar(error.toString());
        messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
      });
    } catch (e) {
      isLoading.value = false;
      AlertMessages.showSnackBar(e.toString());
      messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
    } finally {
      imagesFileList.clear();
    }
  }

  // Calls the Imagine API to fetch an image based on input text
  Future<void> callImagineAPI(String input) async {
    try {
      final data = await _service.imagineAPI(input);
      isLoading.value = false;
      messages.add(HiveChatBoxMessages(
          text: "Here, is a comprehensive desire image output of your prompt.",
          isUser: false));
      messages.add(
          HiveChatBoxMessages(text: "", isUser: false, visualPath: [data]));
      if (isNewPrompt.value && messages.length == 3 && _chatBoxTitle.isEmpty) {
        setChatBoxTitle();
      }
      saveMessagesInDB();
    } on AppException catch (e) {
      // Adds an error message if the call fails
      isLoading.value = false;
      messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {
      // Adds an error message if the call fails
      isLoading.value = false;
      messages.add(HiveChatBoxMessages(text: "Failed", isUser: false));
      AlertMessages.showSnackBar(e.toString());
    }
  }

  Future<List<Content>?> getHistoryMessages() async {
    List<Content> result = [];
    try {
      final history = _chatData.getChatHistory(currentChatBoxID);
      if (history != null) {
        Content content;
        for (var data in history) {
          content = (data.isUser && data.visualPath == null)
              ? Content("user", [TextPart(data.text)])
              : (data.isUser && data.visualPath != null)
                  ? Content("user", [
                      ...await getDataPartList(data.visualPath!
                          .map((value) => XFile(value))
                          .toList()),
                      TextPart(data.text)
                    ])
                  : (!data.isUser && data.visualPath == null)
                      ? Content("model", [TextPart(data.text)])
                      : Content(
                          "model",
                          await getDataPartList(data.visualPath!
                              .map((value) => XFile(value))
                              .toList()));
          result.add(content);
        }
        return result;
      } else {
        return null;
      }
    } catch (e) {
      AlertMessages.showSnackBar(e.toString());
      return null;
    }
  }

  void saveMessagesInDB() {
    shouldTextAnimate.value = true;
    Future.delayed(const Duration(seconds: 3),
        () => _chatData.saveMessage(currentChatBoxID, _chatBoxTitle, messages));
  }

  void checkAlreadyCreated() {
    if (initialAllChatBoxes.value < currentAllChatBoxes) {
      setCurrentChatId(newChatId: _chatData.getLastChatBox().id);
      changeChatBoxTitle(newChatTitle: _chatData.getLastChatBox().title);
      final history = _chatData.getChatHistory(currentChatBoxID);
      if (history != null) {
        messages.value = history.map((e) => e).toList();
      }
      isTextPrompt.value = true;
    } else {
      setCurrentChatId(newChatId: DateTime.now().toIso8601String());
      setGreeting();
      isTextPrompt.value = false;
      messages.value = [];
    }
  }

  Future<void> pickImage() async {
    isTextPrompt.value = true;
    isImagePrompt.value = true;
    final pickedImages = await ImagePicker().pickMultiImage(
        maxHeight: 800, maxWidth: 800, imageQuality: 95, limit: 4);
    if (pickedImages.isNotEmpty) {
      imagesFileList.value = pickedImages.map((image) => image.path).toList();
    } else {
      isTextPrompt.value = false;
      isImagePrompt.value = false;
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
    } else {
      // User canceled the picker
    }
  }

  Future<List<DataPart>> getDataPartList(List<XFile> images) async {
    final imageFutures = images
        .map((imageFile) => imageFile.readAsBytes())
        .toList(growable: false);

    final imageBytes = await Future.wait(imageFutures);
    final imageParts = imageBytes
        .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
        .toList();
    return imageParts;
  }

  Future<void> setChatBoxTitle() async {
    String prompt = messages[0].text;
    String response = messages[1].text;
    _chatBoxTitle = ChatTitleGenerator.generateTitle(prompt, response);
  }

  void setGreeting() {
    // Sets initial greeting based on time of day
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage.value = "Good Morning";
    } else if (hour < 18) {
      greetingMessage.value = "Good Afternoon";
    } else {
      greetingMessage.value = "Good Evening";
    }
  }
}
