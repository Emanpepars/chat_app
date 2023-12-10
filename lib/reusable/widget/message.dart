import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ChatBuble extends StatelessWidget {
  final String message;

  const ChatBuble(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.startsWith('http')) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 10.w,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 5.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: Image.network(
              message,
              fit: BoxFit.cover, // Adjust the BoxFit as needed
              width: 300.w, // Take the available width
              height: 400.h, // Set a fixed height or adjust as needed
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 25.h,
            vertical: 25.w,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            message,
            style: poppins16W500white(),
          ),
        ),
      );
    }
  }
}

class ChatBubleFriend extends StatelessWidget {
  final String message;

  const ChatBubleFriend(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.startsWith('http')) {
      // If it's a URL, display the image
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 10.w,
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.hintColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: Image.network(
              message,
              fit: BoxFit.cover, // Adjust the BoxFit as needed
              width: 300.w, // Take the available width
              height: 400.h, // Set a fixed height or adjust as needed
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 25.h,
            vertical: 25.w,
          ),
          decoration: const BoxDecoration(
            color: AppColors.hintColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            message,
            style: poppins16W500white(),
          ),
        ),
      );
    }
  }
}
