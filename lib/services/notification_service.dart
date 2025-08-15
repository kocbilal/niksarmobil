import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Background message handler - top-level function olmalı
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('🔔 BACKGROUND MESSAGE ALINDI!');
    print('📱 Message ID: ${message.messageId ?? 'NULL'}');
    print('📱 From: ${message.from ?? 'NULL'}');
    print('📱 Data: ${message.data.toString()}');
    print('📱 Notification Title: ${message.notification?.title ?? 'NULL'}');
    print('📱 Notification Body: ${message.notification?.body ?? 'NULL'}');
    
    // Firebase'i başlat (background'da gerekli)
    await Firebase.initializeApp();
  } catch (e) {
    print('❌ Background message handler hatası: $e');
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static String? _fcmToken;
  
  // FCM Token'ı al
  static String? get fcmToken => _fcmToken;
  
  // Bildirim servisini başlat
  static Future<void> initialize() async {
    try {
      print('🔍 Firebase başlatılıyor...');
      // Firebase'i başlat
      await Firebase.initializeApp();
      print('✅ Firebase başarıyla başlatıldı!');
      
      // FCM izinlerini iste
      await _requestPermissions();
      
      // FCM token'ı al
      await _getFCMToken();
      
      // Background message handler'ı ayarla
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Foreground message handler'ı ayarla
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Notification tap handler'ı ayarla
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      print('✅ Firebase Messaging başarıyla başlatıldı!');
    } catch (e) {
      print('❌ Firebase başlatılamadı: $e');
      rethrow;
    }
  }
  
  // FCM izinlerini iste
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('Kullanıcı izni: ${settings.authorizationStatus}');
  }
  
  // FCM Token'ı al
  static Future<void> _getFCMToken() async {
    try {
      print('🔍 FCM Token alınıyor...');
      _fcmToken = await _firebaseMessaging.getToken();
      
      if (_fcmToken != null) {
        print('✅ FCM Token başarıyla alındı!');
        print('🔥 FCM TOKEN: $_fcmToken');
        if (_fcmToken!.length > 50) {
          print('🔥 FCM TOKEN (ilk 50 karakter): ${_fcmToken!.substring(0, 50)}...');
        } else {
          print('🔥 FCM TOKEN (tam): $_fcmToken');
        }
        print('🔥 FCM TOKEN uzunluğu: ${_fcmToken!.length} karakter');
      } else {
        print('❌ FCM Token null döndü!');
      }
    } catch (e) {
      print('❌ FCM Token alınırken hata: $e');
    }
    
    // Token yenilendiğinde
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      print('🔄 Yeni FCM Token: $_fcmToken');
      print('🔄 Yeni FCM Token (ilk 50 karakter): ${token.substring(0, 50)}...');
      // Burada token'ı sunucunuza gönderebilirsiniz
    });
  }
  
  // Local notification göster (basit SnackBar ile)
  static void showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    // Flutter context olmadığı için sadece print yapıyoruz
    // Gerçek uygulamada ScaffoldMessenger kullanılacak
    print('Local Notification: $title - $body');
  }
  
  // Foreground message handler
  static void _handleForegroundMessage(RemoteMessage message) {
    try {
      print('🔔 FOREGROUND MESSAGE ALINDI!');
      print('📱 Message ID: ${message.messageId ?? 'NULL'}');
      print('📱 From: ${message.from ?? 'NULL'}');
      print('📱 Data: ${message.data.toString()}');
      print('📱 Notification Title: ${message.notification?.title ?? 'NULL'}');
      print('📱 Notification Body: ${message.notification?.body ?? 'NULL'}');
      print('📱 Collapse Key: ${message.collapseKey ?? 'NULL'}');
      print('📱 Sent Time: ${message.sentTime ?? 'NULL'}');
      print('📱 TTL: ${message.ttl ?? 'NULL'}');
      
      // Foreground'da bildirim göster (sadece print)
      print('Foreground Notification: ${message.notification?.title ?? 'Yeni Bildirim'} - ${message.notification?.body ?? ''}');
    } catch (e) {
      print('❌ Foreground message handler hatası: $e');
    }
  }
  
  // Notification tap handler
  static void _handleNotificationTap(RemoteMessage message) {
    try {
      print('🔔 NOTIFICATION TIKLANDI!');
      print('📱 Message ID: ${message.messageId ?? 'NULL'}');
      print('📱 From: ${message.from ?? 'NULL'}');
      print('📱 Data: ${message.data.toString()}');
      print('📱 Notification Title: ${message.notification?.title ?? 'NULL'}');
      print('📱 Notification Body: ${message.notification?.body ?? 'NULL'}');
      // Burada istediğiniz sayfaya yönlendirebilirsiniz
    } catch (e) {
      print('❌ Notification tap handler hatası: $e');
    }
  }
  
  // Topic'e abone ol
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Topic\'e abone olundu: $topic');
  }
  
  // Topic'ten çık
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Topic\'ten çıkıldı: $topic');
  }
}
