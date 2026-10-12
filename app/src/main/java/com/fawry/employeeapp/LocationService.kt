package com.fawry.employeeapp

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.*
import android.os.IBinder
import androidx.core.content.ContextCompat
import java.util.concurrent.Executors

class LocationService:Service(){
 private lateinit var lm:LocationManager
 private val ex=Executors.newSingleThreadExecutor()
 private val listener=object:LocationListener{override fun onLocationChanged(l:Location){
   val p=getSharedPreferences("tracking",Context.MODE_PRIVATE);p.edit().putLong("last_time",System.currentTimeMillis()).putString("last_lat",l.latitude.toString()).putString("last_lng",l.longitude.toString()).putString("last_accuracy",l.accuracy.toString()).apply()
   val token=SessionStore.token(this@LocationService);val eid=SessionStore.employeeId(this@LocationService);if(token!=null&&eid!=null)ex.execute{var aid=p.getString("attendanceId",null);if(aid==null){SupabaseApi.createAttendance(token,eid,l.latitude,l.longitude).onSuccess{id->p.edit().putString("attendanceId",id).apply();aid=id}};SupabaseApi.addLocation(token,eid,aid,l.latitude,l.longitude,l.accuracy)}
 }}
 override fun onCreate(){super.onCreate();val ch=NotificationChannel("attendance","Attendance",NotificationManager.IMPORTANCE_LOW);getSystemService(NotificationManager::class.java).createNotificationChannel(ch);lm=getSystemService(LocationManager::class.java)}
 override fun onStartCommand(i:Intent?,flags:Int,id:Int):Int{getSharedPreferences("tracking",Context.MODE_PRIVATE).edit().remove("attendanceId").apply();val n=Notification.Builder(this,"attendance").setContentTitle("Fawry Attendance").setContentText("تتبع الموقع مفعل أثناء الوردية").setSmallIcon(android.R.drawable.ic_menu_mylocation).setOngoing(true).build();startForeground(1001,n);if(ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_FINE_LOCATION)==PackageManager.PERMISSION_GRANTED||ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED){try{lm.requestLocationUpdates(LocationManager.GPS_PROVIDER,15000L,20f,listener)}catch(_:SecurityException){}};return START_STICKY}
 override fun onDestroy(){try{lm.removeUpdates(listener)}catch(_:Exception){};getSharedPreferences("tracking",Context.MODE_PRIVATE).edit().remove("attendanceId").apply();ex.shutdownNow();super.onDestroy()}
 override fun onBind(i:Intent?):IBinder?=null
}
