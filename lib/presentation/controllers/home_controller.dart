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
  final RxString visionResponse =
      "".obs; // Store the image response that will received by gemini model
  final RxString _currentChatBoxID =
      "".obs; // to store current chat box where user send prompt
  final RxString filePath = "".obs; // file path of selected pdf file
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
  late List<String> _chunks =
      []; //to store large text into chunks to be spoken by text-to-speech
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
      chat.save().then(
          (value) => {totalChatBoxes.value = _chatData.getAllChatBoxes()});
    }
  }

  void initializeTotalChatBoxes({required bool firstTime}) {
    totalChatBoxes.value = _chatData.getAllChatBoxes();
    if (!firstTime && totalChatBoxes.isNotEmpty && isTextPrompt.value) {
      totalChatBoxes.removeLast();
    }
    initialAllChatBoxes.value = totalChatBoxes.length;
  }

  Future<void> deleteChatBox({required String chatId}) async {
    bool b = await _chatData.deleteChatBox(chatId: chatId);
    if (b) {
      initializeTotalChatBoxes(firstTime: false);
    } else {
      AlertMessages.showSnackBar(
          "Hive Error: something went wrong to deleting this ChatBox");
    }
  }

  @override
  void onInit() {
    super.onInit();
    initialize(); // Initialize greeting and speech services
    initializeTotalChatBoxes(firstTime: true);
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

  void _onChunkCompleted() {
    if (!isStopped.value) {
      _speakChunks(); // Speak the next message if not stopped
    }
  }

  // Initializes the message queue for speaking and starts TTS
  void playTTs() async {
    for (var message in messages) {
      if (message.text.isNotEmpty) {
        _messageQueue.add(message.text);
      }
    }
    _flutterTts.setCompletionHandler(
        _onSpeakCompleted); // Sets a handler for TTS completion
    isStopped.value = false;
    await _speakNextMessage(); // Begins speaking messages in the queue
  }

  // Resets conversation messages and stops both TTS and speech recognition
  void resetAll() {
    messages.value = [];
    _messageQueue.clear();
    initializeTotalChatBoxes(firstTime: true);
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
      if (_messageQueue.elementAt(0).length > 4000) {
        _chunks = _splitTextIntoChunks(_messageQueue.removeAt(0), 4000);
        _flutterTts.setCompletionHandler(_onChunkCompleted);
        await _speakChunks();
      } else {
        await _flutterTts.speak(_messageQueue.removeAt(0));
      } // Speaks the next message in queue
    } else {
      stopTTs();
    }
  }

  Future<void> _speakChunks() async {
    if (_chunks.isNotEmpty) {
      debugPrint("chunks speak");
      await _flutterTts.speak(_chunks.removeAt(0));
    } else {
      debugPrint("chunks finished");
      _speakNextMessage();
    }
  }

  List<String> _splitTextIntoChunks(String text, int chunkSize) {
    final List<String> chunks = [];
    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(
          i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
    return chunks;
  }

  // Adds a message to the queue and starts TTS
  Future<void> speakTTs(String botResponse) async {
    isStopped.value = false;
    _messageQueue.add(botResponse);
    await _speakNextMessage();
  }

  // stop speaking the queue messages or complete speaking
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
            text: input, isUser: true, imagePath: null, filePath: null));
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
        messages.add(HiveChatBoxMessages(text: "Empty prompt", isUser: true));
        shouldTextAnimate.value = true;
        callingFail(
            speakMsg:
                "Please provide me with some context or a question so I can assist you. For example: Give me some Interview Tips.");
      }
    } on AppException catch (e) {
      callingFail();
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {
      callingFail();
      AlertMessages.showSnackBar(e.toString());
    }
  }

  Future<void> sendPrompt(String prompt) async {
    isImagePrompt.value = false;

    if (imagesFileList.isNotEmpty) {
      messages.add(HiveChatBoxMessages(
          text: prompt,
          isUser: true,
          imagePath: (imagesFileList.isNotEmpty)
              ? List<String>.from(imagesFileList)
              : null,
          filePath: null));
      isLoading.value = true;
    }

    try {
      final Stream<GenerateContentResponse> response =
          await _generateContent.execute(
              prompt: prompt,
              history: await getHistoryMessages(),
              isTextOnly: imagesFileList.isEmpty,
              images: imagesFileList.map((image) => XFile(image)).toList());
      response.listen((event) {
        visionResponse.value += event.text.toString();
      }, onDone: () async {
        isLoading.value = false; // Ends loading state
        if (visionResponse.value.isNotEmpty) {
          messages.add(HiveChatBoxMessages(
              text: visionResponse.value.trim(), isUser: false));
          speakTTs(visionResponse.value);
          visionResponse.value = "";
        }
        if (isNewPrompt.value &&
            messages.length == 2 &&
            _chatBoxTitle.isEmpty) {
          setChatBoxTitle();
        }
        saveMessagesInDB();
        // save message to hive db
      }).onError((error, stackTrace) {
        callingFail(speakMsg: error.toString());
        AlertMessages.showSnackBar(error.toString());
      });
    } catch (e) {
      callingFail();
      AlertMessages.showSnackBar(e.toString());
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
          isUser: false,
          imagePath: [data],
          filePath: null));
      if (isNewPrompt.value && messages.length == 2 && _chatBoxTitle.isEmpty) {
        setChatBoxTitle();
      }
      saveMessagesInDB();
    } on AppException catch (e) {
      // Adds an error message if the call fails
      callingFail();
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {
      // Adds an error message if the call fails
      callingFail();
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
          content = (data.isUser && data.imagePath == null)
              ? Content("user", [TextPart(data.text)])
              : (data.isUser && data.imagePath != null)
                  ? Content("user", [
                      ...await getDataPartList(data.imagePath!
                          .map((value) => XFile(value))
                          .toList()),
                      TextPart(data.text)
                    ])
                  : (!data.isUser && data.imagePath == null)
                      ? Content("model", [TextPart(data.text)])
                      : Content(
                          "model",
                          await getDataPartList(data.imagePath!
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

  void callingFail(
      {String speakMsg = "Sorry, I could not generate the response"}) {
    isLoading.value = false;
    messages.add(HiveChatBoxMessages(text: speakMsg, isUser: false));
    speakTTs(speakMsg);
    if (isNewPrompt.value && messages.length == 2 && _chatBoxTitle.isEmpty) {
      setChatBoxTitle();
    }
    saveMessagesInDB();
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
      _chatBoxTitle = "";
      setGreeting();
      isTextPrompt.value = false;
      messages.value = [];
    }
  }

  Future<void> pickImage() async {
    final pickedImages = await ImagePicker()
        .pickMultiImage(maxHeight: 800, maxWidth: 800, imageQuality: 100);
    if (pickedImages.isNotEmpty) {
      isImagePrompt.value = true;
      isTextPrompt.value = true;
      imagesFileList.value = pickedImages.map((image) => image.path).toList();
      if (filePath.value.isNotEmpty) {
        filePath.value = "";
      }
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf']);

    if (result != null) {
      isImagePrompt.value = true;
      isTextPrompt.value = true;
      filePath.value = result.files.single.path!;
      if (imagesFileList.isNotEmpty) {
        imagesFileList.value = [];
      }
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

  Future<void> uploadPdf(String text) async {
    isImagePrompt.value = false;
    final fileName = filePath.value.split('/').last.split('-').last;
    messages.add(HiveChatBoxMessages(
        text: text,
        isUser: true,
        imagePath: null,
        filePath: (filePath.isNotEmpty) ? fileName : null));
    isLoading.value = true;

    try {
      final response = await _generateContent.sendPromptFile(
          prompt: text, file: File(filePath.value), fileName: fileName);
      if (response.isNotEmpty) {
        isLoading.value = false;
        messages.add(HiveChatBoxMessages(text: response.trim(), isUser: false));
        speakTTs(response);
        if (isNewPrompt.value &&
            messages.length == 2 &&
            _chatBoxTitle.isEmpty) {
          setChatBoxTitle();
        }
        saveMessagesInDB();
      }
    } catch (e) {
      callingFail();
      AlertMessages.showSnackBar(e.toString());
    } finally {
      filePath.value = "";
    }
  }
}
