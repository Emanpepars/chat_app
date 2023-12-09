import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  var messageController = TextEditingController();
  final controller = ScrollController();

  void addMessageFireBase(String value, args) {
    getMessageCollection();

    addMessage(
      MessageModel(
        message: value,
        date: DateTime.now(),
        id: args.id,
        userId: FirebaseAuth.instance.currentUser!.uid,
        friendId: args.id,
      ),
    );

    sendNotification(args.pushToken,
        FirebaseAuth.instance.currentUser!.email ?? "", messageController.text);
    messageController.clear();
    controller.animateTo(0,
        duration: const Duration(seconds: 2), curve: Curves.easeIn);
    notifyListeners();
  }

  CollectionReference<MessageModel> getMessageCollection() {
    return FirebaseFirestore.instance.collection('Messages').withConverter(
          fromFirestore: (snapshot, _) =>
              MessageModel.fromJson(snapshot.data()!),
          toFirestore: (message, options) => message.toJson(),
        );
  }

  Future<void> addMessage(MessageModel message) {
    var collection = getMessageCollection();
    var docRef = collection.doc();
    message.id = message.userId;
    return docRef.set(message);
  }

  Stream<QuerySnapshot<MessageModel>> getMessagesFromFireStore() {
    var collection = getMessageCollection();
    return collection.orderBy("date", descending: true).snapshots();
  }

  updateMessage(String id, MessageModel message) {
    return getMessageCollection().doc(id).update(
          message.toJson(),
        );
  }

  void sendNotification(String friendToken, String title, String body) async {
    // FCM server endpoint
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    // FCM server key from your Firebase project settings
    const String serverKey =
        'AAAAoM67dP0:APA91bFNN7hNpMkhiKv4iYD5r9cpjizzacqFEJdzOQ_724h-6RlSaSiKhl8tuLrnXe1hYOfb-ZPGDdacIfLA8qjambjEshm7R-E81EnZS1TYT3tBuw7rYoraWz8fM9Bto7-srgDJ8j16';

    // Create the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    // Create the notification payload
    final Map<String, dynamic> notification = {
      'title': title,
      'body': body,
    };

    // Create the message payload
    final Map<String, dynamic> message = {
      'to': friendToken,
      'notification': notification,
      'data': {
        // Additional data if needed
      },
    };

    // Convert the message to JSON
    final String jsonMessage = jsonEncode(message);

    // Make the HTTP POST request
    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: headers,
      body: jsonMessage,
    );

    // Check the response
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
