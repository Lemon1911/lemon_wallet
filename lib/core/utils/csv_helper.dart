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
      "Category",
      "Amount",
      "Note",
    ]);

    for (var tx in transactions) {
      rows.add([
        tx.transactionDate.toIso8601String(),
        tx.type == TransactionType.income ? "Income" : "Expense",
        tx.categoryId, // Ideally we would have the category name here
        tx.amount,
        tx.note,
      ]);
    }

    // In csv 8.0.0, use CsvEncoder
    String csvData = const CsvEncoder().convert(rows);

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);

    await file.writeAsString(csvData);

    // Share using the updated share_plus 10.0.0 API
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'Exported Transactions',
      ),
    );
  }
}
