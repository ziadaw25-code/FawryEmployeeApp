package com.fawry.employeeapp

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FawryFirebaseMessagingService: FirebaseMessagingService(){
 override fun onMessageReceived(m:RemoteMessage){
  val channel="fawry_updates"
  val nm=getSystemService(NotificationManager::class.java)
  if(Build.VERSION.SDK_INT>=26) nm.createNotificationChannel(NotificationChannel(channel,"Fawry Updates",NotificationManager.IMPORTANCE_HIGH))
  val pi=PendingIntent.getActivity(this,0,Intent(this,MainActivity::class.java),PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
  val n=NotificationCompat.Builder(this,channel).setSmallIcon(android.R.drawable.ic_dialog_info).setContentTitle(m.notification?.title ?: "Fawry").setContentText(m.notification?.body ?: "لديك تحديث جديد").setAutoCancel(true).setContentIntent(pi).build()
  nm.notify((System.currentTimeMillis()%100000).toInt(),n)
 }
}
