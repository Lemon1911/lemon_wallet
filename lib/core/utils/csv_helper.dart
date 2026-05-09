import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

class CsvHelper {
  static Future<void> exportTransactionsToCsv(List<TransactionEntity> transactions) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Date",
      "Type",
      "Category ID",
      "Amount",
      "Note",
    ]);

    for (var tx in transactions) {
      rows.add([
        tx.transactionDate.toIso8601String(),
        tx.type == TransactionType.income ? "Income" : "Expense",
        tx.categoryId,
        tx.amount,
        tx.note,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/lemon_transactions_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);

    await file.writeAsString(csvData);

    // Correct share_plus API
    await Share.shareXFiles(
      [XFile(path)],
      text: 'My LemonWallet Transaction Export 🍋',
    );
  }

  static Future<List<Map<String, dynamic>>> importTransactionsFromCsv(File file) async {
    final input = file.readAsStringSync();
    final List<List<dynamic>> fields = const CsvToListConverter().convert(input);

    if (fields.isEmpty) return [];

    final header = fields[0];
    final data = fields.sublist(1);

    List<Map<String, dynamic>> results = [];
    for (var row in data) {
      Map<String, dynamic> tx = {};
      for (int i = 0; i < header.length; i++) {
        if (i < row.length) {
          tx[header[i].toString().toLowerCase()] = row[i];
        }
      }
      results.add(tx);
    }
    return results;
  }
}
