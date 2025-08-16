import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  // Yerel bildirim servisini başlat
  static Future<void> initialize() async {
    try {
      print('🔍 Yerel bildirim servisi başlatılıyor...');
      
      // Android ayarları
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS ayarları
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      // Genel ayarlar
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Bildirimleri başlat
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      
      // Android için bildirim kanalı oluştur
      await _createNotificationChannel();
      
      print('✅ Yerel bildirim servisi başarıyla başlatıldı!');
    } catch (e) {
      print('❌ Yerel bildirim servisi başlatılamadı: $e');
      rethrow;
    }
  }
  
  // Android için bildirim kanalı oluştur
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'niksar_mobile_channel',
      'Niksar Mobil Bildirimleri',
      description: 'Niksar Mobil uygulaması için bildirimler',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Yerel bildirim göster
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'niksar_mobile_channel',
        'Niksar Mobil Bildirimleri',
        channelDescription: 'Niksar Mobil uygulaması için bildirimler',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
      
      print('✅ Yerel bildirim gönderildi: $title');
    } catch (e) {
      print('❌ Yerel bildirim gösterilemedi: $e');
    }
  }
  
  // Bildirime tıklanma işlemi
  static void _onNotificationTap(NotificationResponse response) {
    print('🔔 Bildirime tıklandı!');
    print('📱 Payload: ${response.payload ?? 'Boş'}');
    
    // Burada istediğiniz sayfaya yönlendirebilirsiniz
    // Örneğin: Navigator.pushNamed(context, '/notification-detail');
  }
  
  // Zamanlanmış bildirim göster
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'niksar_mobile_channel',
        'Niksar Mobil Bildirimleri',
        channelDescription: 'Niksar Mobil uygulaması için bildirimler',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        scheduledTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      print('✅ Zamanlanmış bildirim ayarlandı: $title');
    } catch (e) {
      print('❌ Zamanlanmış bildirim ayarlanamadı: $e');
    }
  }
  
  // Tüm bekleyen bildirimleri iptal et
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('✅ Tüm bildirimler iptal edildi');
  }
  
  // Belirli bir bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('✅ Bildirim iptal edildi: $id');
  }
}