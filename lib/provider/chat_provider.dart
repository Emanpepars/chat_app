import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  var messageController = TextEditingController();
  final controller = ScrollController();
  File? img;

  late String imageUrl;

  void addMessageFireBase(String value, args) {
    if (messageController.text != "") {
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

      sendNotification(
          args.pushToken,
          FirebaseAuth.instance.currentUser!.email ?? "",
          messageController.text);
      messageController.clear();
      controller.animateTo(0,
          duration: const Duration(seconds: 2), curve: Curves.easeIn);
      notifyListeners();
    }
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

  Stream<QuerySnapshot<MessageModel>> getLastMessagesFromFireStore(
      friendId, userId) {
    var collection = getMessageCollection();
    return collection
        .where("friendId", isEqualTo: friendId)
        .where("userId", isEqualTo: userId)
        .limit(1)
        .snapshots();
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

  void pickImage(args) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      img = File(image.path);
      notifyListeners();
      addImageFireBase(img!, args);
    }
  }

  Future<void> getImage(args) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      img = File(pickedFile.path);
      notifyListeners();

      addImageFireBase(img!,args);
    }
  }

  void addImageFireBase(File image, args) {
    getMessageCollection();

    uploadImageToFirebaseStorage(image).then((imageUrl) {
      print(imageUrl);
      print(image);
      print(img);
      addMessage(
        MessageModel(
          message: imageUrl,
          date: DateTime.now(),
          id: args.id,
          userId: FirebaseAuth.instance.currentUser!.uid,
          friendId: args.id,
        ),
      );

      print("object");
      sendNotification(
        args.pushToken,
        FirebaseAuth.instance.currentUser!.email ?? "",
        imageUrl,
      );

      controller.animateTo(0,
          duration: const Duration(seconds: 2), curve: Curves.easeIn);
      notifyListeners();
    });
  }

  Future<String> uploadImageToFirebaseStorage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference firebaseStorageRef =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      firebase_storage.UploadTask uploadTask =
          firebaseStorageRef.putFile(image);

      // Use 'then' to get the imageUrl after the upload is complete
      String imageUrl = await uploadTask.then((taskSnapshot) async {
        return await firebaseStorageRef.getDownloadURL();
      });

      print("Image uploaded to Firebase Storage: $imageUrl");
      return imageUrl; // Return the imageUrl in the success case
    } catch (error) {
      print("Error uploading image to Firebase Storage: $error");
      return ""; // Return an empty string in case of an error
    }
  }
}
