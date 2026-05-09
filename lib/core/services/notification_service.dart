import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../widgets/confirm_transaction_dialog.dart';
import '../di/service_locator.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    debugPrint('Handling notification tap: $payload');

    final parts = payload.split('|');
    if (parts[0] == 'confirm_transaction') {
      final amount = double.tryParse(parts[1]) ?? 0.0;
      final merchant = parts[2];

      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null) {
        final walletBloc = sl<WalletBloc>();
        if (walletBloc.state is WalletsLoaded) {
          final wallets = (walletBloc.state as WalletsLoaded).wallets;
          if (wallets.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => ConfirmTransactionDialog(
                amount: amount,
                merchant: merchant,
                wallet: wallets.first,
              ),
            );
          }
        }
      }
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lemon_wallet_transactions',
      'Transactions',
      channelDescription: 'Notifications for detected transactions',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF00E5FF),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }
}
