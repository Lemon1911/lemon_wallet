class SMSParsedData {
  final double amount;
  final String merchant;
  final String? account;
  final String fullText;

  SMSParsedData({
    required this.amount,
    required this.merchant,
    this.account,
    required this.fullText,
  });
}

class SMSParser {
  static SMSParsedData? parse(String message) {
    final msg = message.toLowerCase();
    
    // Pattern 1: "Paid [Amount] to [Merchant]"
    final paidRegex = RegExp(r'paid\s+([a-z]{0,3}\s?\d+[\.,]\d{2})\s+to\s+([^,\.]+)', caseSensitive: false);
    final paidMatch = paidRegex.firstMatch(msg);
    if (paidMatch != null) {
      final amountStr = _cleanAmount(paidMatch.group(1)!);
      final merchant = paidMatch.group(2)!.trim();
      return SMSParsedData(
        amount: double.tryParse(amountStr) ?? 0.0,
        merchant: merchant,
        fullText: message,
      );
    }

    // Pattern 2: "Spent [Amount] at [Merchant]"
    final spentRegex = RegExp(r'spent\s+([a-z]{0,3}\s?\d+[\.,]\d{2})\s+at\s+([^,\.]+)', caseSensitive: false);
    final spentMatch = spentRegex.firstMatch(msg);
    if (spentMatch != null) {
      final amountStr = _cleanAmount(spentMatch.group(1)!);
      final merchant = spentMatch.group(2)!.trim();
      return SMSParsedData(
        amount: double.tryParse(amountStr) ?? 0.0,
        merchant: merchant,
        fullText: message,
      );
    }

    // Pattern 3: "Purchase of [Amount] at [Merchant]"
    final purchaseRegex = RegExp(r'purchase\s+of\s+([a-z]{0,3}\s?\d+[\.,]\d{2})\s+at\s+([^,\.]+)', caseSensitive: false);
    final purchaseMatch = purchaseRegex.firstMatch(msg);
    if (purchaseMatch != null) {
      final amountStr = _cleanAmount(purchaseMatch.group(1)!);
      final merchant = purchaseMatch.group(2)!.trim();
      return SMSParsedData(
        amount: double.tryParse(amountStr) ?? 0.0,
        merchant: merchant,
        fullText: message,
      );
    }

    return null;
  }

  static String _cleanAmount(String str) {
    // Remove currency symbols and non-numeric except . and ,
    return str.replaceAll(RegExp(r'[^0-9\.,]'), '').replaceAll(',', '.');
  }
}
