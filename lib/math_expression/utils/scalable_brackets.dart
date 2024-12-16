class MakeScalableBrackets {
  static String makeScalableBrackets(String expression) {
    if (expression.isEmpty) return expression;

    try {
      // Don't process expressions that already contain \left or \right
      if (expression.contains(r'\left') || expression.contains(r'\right')) {
        return expression;
      }

      // Define bracket pairs, including escaped curly braces
      final Map<String, String> bracketPairs = {
        '(': ')',
        '[': ']',
        r'\{': r'\}',
      };

      // Stack to keep track of opened brackets
      List<MapEntry<int, String>> openBrackets = [];
      StringBuffer result = StringBuffer();
      int i = 0;

      while (i < expression.length) {
        String currentChar = expression[i];

        // Check for escaped characters (e.g., \{ or \})
        String currentToken = currentChar;
        if (currentChar == r'\') {
          if (i + 1 < expression.length) {
            currentToken = expression.substring(i, i + 2);
            i++; // Skip next character as it's part of the escaped character
          }
        }

        // If opening bracket, push to stack
        if (bracketPairs.containsKey(currentToken)) {
          openBrackets.add(MapEntry(result.length, currentToken));
          result.write(currentToken);
        }
        // If closing bracket, match with stack
        else if (bracketPairs.containsValue(currentToken)) {
          if (openBrackets.isNotEmpty) {
            final lastOpen = openBrackets.removeLast();
            final expectedClose = bracketPairs[lastOpen.value];
            if (currentToken == expectedClose) {
              // Insert \left before opening bracket
              String temp = result.toString();
              result = StringBuffer(temp.substring(0, lastOpen.key) +
                  r'\left' +
                  temp.substring(lastOpen.key));
              // Insert \right before closing bracket
              result.write(r'\right');
              result.write(currentToken);
            } else {
              // Bracket mismatch, write as is
              result.write(currentToken);
            }
          } else {
            // Unmatched closing bracket, write as is
            result.write(currentToken);
          }
        } else {
          // Regular character, write as is
          result.write(currentToken);
        }
        i++;
      }

      return result.toString();
    } catch (e) {
      // print('Error in makeScalableBrackets: $e');
      return expression;
    }
  }
}
