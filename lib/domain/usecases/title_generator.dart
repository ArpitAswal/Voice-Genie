class ChatTitleGenerator {
  // Function to generate a dynamic title based on content
  static String generateTitle(String userPrompt, String aiResponse) {
    // Combine user prompt and response for analysis
    String combinedText = "$userPrompt $aiResponse";

    // Attempt to extract a meaningful phrase or word (basic NLP simulation)
    String title = _extractKeywords(combinedText);

    // If no meaningful keywords are extracted, fallback to a summary
    if (title.isEmpty) {
      title = _summarizeText(userPrompt, aiResponse);
    }

    return title.isNotEmpty
        ? _sanitizeTitle(capitalizeTitle(title))
        : "Voice Genie Prompt";
  }

  // Extract potential keywords or meaningful phrases
  static String _extractKeywords(String text) {
    // Split text into words
    List<String> words = text.split(' ');
    List<String> keywords = specializedKeywords(words);

    // Return the most relevant keyword or a combination of the top 5
    if (keywords.isNotEmpty) {
      return (keywords.length < 3)
          ? keywords.take(keywords.length).join(' ')
          : keywords.take(3).join(' ');
    }
    return '';
  }

  // A fallback summarization function
  static String _summarizeText(String userPrompt, String aiResponse) {
    String baseText =
        (userPrompt.length > aiResponse.length) ? userPrompt : aiResponse;
    return _extractKeywords(baseText);
  }

  static List<String> specializedKeywords(List<String> words) {
    // Filter for nouns/proper nouns or special words (basic logic: use longer words, but no common stop words)
    const stopWords = [
      'because',
      'however',
      'during',
    ];
    return words.where((word) {
      word = word.toLowerCase().trim();
      return word.length >= 6 && !stopWords.contains(word);
    }).toList();
  }

  static String capitalizeTitle(String input) {
    List<String> words = input.split(' ');
    List<String> capitalizedWords = words.map((word) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).toList();
    return capitalizedWords.join(' ');
  }

  static String _sanitizeTitle(String title) {
    // Define special keywords or characters to remove
    const specialKeywords = [
      // Add any special words you want to exclude
      '!', '@', '#', '%', '^', '&', '*', '**', '?',
    ];

    // Remove newlines, trailing spaces, and special keywords
    title = title
        .replaceAll('\n', ' ')
        .trim(); // Remove newlines and trailing spaces
    for (String keyword in specialKeywords) {
      title = title.replaceAll(keyword, '');
    }

    // Normalize multiple spaces to a single space
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    return title;
  }
}
