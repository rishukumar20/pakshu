import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationServices  {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    Future<void> requestNotificationPermission() async {
        print("request");
        NotificationSettings settings = await messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            print('User granted permission');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
            print('User granted provisional permission');
        } else {
            print('User declined or has not accepted permission');
        }
    }

Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
}
}
