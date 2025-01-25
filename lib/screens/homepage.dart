import 'package:cloud_messaging/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await FirebaseMessaging.instance.requestPermission();
        await FirebaseMessaging.instance.getAPNSToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();

        if(fcmToken!=null){
         await _setFcmToken(fcmToken);
        }

      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
       await _setFcmToken(fcmToken);
    });
  }

  Future<void> _setFcmToken(String fcmToken) async {
      final userId = supabase.auth.currentUser?.id;
      if(userId!=null){
        await supabase.from('profiles').upsert({
          'id': userId,
          'fcm_token': fcmToken,
        });

      }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Messaging'),
        actions: [
          IconButton(
              onPressed: () async{
                await supabase.auth.signOut();
              } ,
              icon: Icon(Icons.logout_outlined))
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey.withOpacity(0.4),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
