import 'package:intl/intl.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyService {
  static const Map<String, CurrencyInfo> currencies = {
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    'JPY': CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    'EGP': CurrencyInfo(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
    'SAR': CurrencyInfo(code: 'SAR', symbol: 'SR', name: 'Saudi Riyal'),
    'AED': CurrencyInfo(code: 'AED', symbol: 'DH', name: 'UAE Dirham'),
  };

  String formatAmount(double amount, String currencyCode) {
    final currency = currencies[currencyCode] ?? currencies['USD']!;
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String getSymbol(String currencyCode) {
    return currencies[currencyCode]?.symbol ?? '\$';
  }

  List<CurrencyInfo> getAllCurrencies() {
    return currencies.values.toList();
  }
}
