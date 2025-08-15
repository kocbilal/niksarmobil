package tr.niksarmobil.niksar_webview

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d("FCM", "Message received: ${remoteMessage.messageId}")
        Log.d("FCM", "From: ${remoteMessage.from}")
        Log.d("FCM", "Data: ${remoteMessage.data}")
        Log.d("FCM", "Notification Title: ${remoteMessage.notification?.title}")
        Log.d("FCM", "Notification Body: ${remoteMessage.notification?.body}")
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        
        Log.d("FCM", "New token: $token")
        // Burada token'ı sunucunuza gönderebilirsiniz
    }
}
