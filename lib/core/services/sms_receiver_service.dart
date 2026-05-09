import 'package:flutter/foundation.dart';
import 'package:another_telephony/telephony.dart';
import 'notification_service.dart';
import '../utils/sms_parser.dart';

class SmsReceiverService {
  static final Telephony telephony = Telephony.instance;

  static Future<void> startListening() async {
    // We should request permissions before calling this, 
    // but the package handles some internals.
    telephony.listenIncomingSms(
      onNewMessage: _handleSms,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  static void _handleSms(SmsMessage message) {
    _processMessage(message);
  }

  static Future<void> _processMessage(SmsMessage message) async {
    final body = message.body;
    if (body == null) return;

    final parsedData = SMSParser.parse(body);
    if (parsedData != null) {
      debugPrint('Parsed Transaction: ${parsedData.amount} from ${parsedData.merchant}');
      
      await NotificationService.showNotification(
        id: body.hashCode,
        title: 'New Transaction Detected',
        body: '${parsedData.amount} spent at ${parsedData.merchant}. Tap to confirm.',
        payload: 'confirm_transaction|${parsedData.amount}|${parsedData.merchant}',
      );
    }
  }
}

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  // This runs in a separate isolate
  // We can't use the main service locator here easily without re-initializing
  debugPrint('Background SMS received: ${message.body}');
}
