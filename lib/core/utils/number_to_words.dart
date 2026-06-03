class NumberToWordsConverter {
  static const List<String> _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen'
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  /// Converts a double value (representing an amount) to words.
  /// Example: 1800.50 -> "One Thousand Eight Hundred Rupees and Fifty Paise Only"
  static String convert(double amount) {
    if (amount < 0) {
      return 'Negative amount not supported';
    }
    
    final int rupees = amount.truncate();
    final int paise = ((amount - rupees) * 100).round();

    String result = '';

    if (rupees == 0) {
      result = 'Zero Rupees';
    } else {
      result = '${_convertPart(rupees)} Rupees';
    }

    if (paise > 0) {
      result = '$result and ${_convertPart(paise)} Paise';
    }

    return '$result Only';
  }

  static String _convertPart(int number) {
    if (number < 0) return '';
    
    if (number < 20) {
      return _ones[number];
    }
    
    if (number < 100) {
      return '${_tens[number ~/ 10]}${number % 10 > 0 ? ' ${_ones[number % 10]}' : ''}';
    }
    
    if (number < 1000) {
      return '${_ones[number ~/ 100]} Hundred${number % 100 > 0 ? ' and ${_convertPart(number % 100)}' : ''}';
    }

    // Indian Numbering System: Thousands, Lakhs, Crores
    if (number < 100000) { // Up to 99,999
      return '${_convertPart(number ~/ 1000)} Thousand${number % 1000 > 0 ? ' ${_convertPart(number % 1000)}' : ''}';
    }

    if (number < 10000000) { // Up to 99,99,999 (Lakhs)
      return '${_convertPart(number ~/ 100000)} Lakh${number % 100000 > 0 ? ' ${_convertPart(number % 100000)}' : ''}';
    }

    // Crores
    return '${_convertPart(number ~/ 10000000)} Crore${number % 10000000 > 0 ? ' ${_convertPart(number % 10000000)}' : ''}';
  }
}
