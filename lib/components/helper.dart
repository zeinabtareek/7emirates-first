import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../utils/const.dart';
import '../utils/shared_preferences.dart';
import '../utils/urls.dart';

class SendCodeHelper {
  SendCodeHelper._();

  static SendCodeHelper get instance => SendCodeHelper._();

  Future<bool> sendEmailApi({
    required String email,
  }) async {
    var sendEmail = Urls.sendEmail;
    var body2 = {
      'email': email,
    };
    log('${sendEmail} $body2', name: 'send_Email');
    final response = await http.post(
      Uri.parse(sendEmail),
      headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
      body: body2,
    );

    var otp = jsonDecode(response.body)["OTP"]?.toString();
    log('$otp', name: 'OTP-Email');
    if (otp == null) {
      return false;
    }
    SharedStoreUtils.setValue(
      Const.OTP,
      otp,
    );
    return true;
  }

  Future<void> sendPhoneCode({
    required String phoneNumber,
    required void Function(String) onCodeSend,
  }) async {
    log(phoneNumber, name: 'phoneNumber');
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(minutes: 2),
      verificationCompleted: (PhoneAuthCredential credential) {
        // log('ffffff');
        // Navigator.push(
        //     context,
        //     LeftOpenScreen(
        //         widget: OtpScreen(
        //       countryId: countryId,
        //       getPhone: ETphone.text.toString(),
        //       getEmail: ETemail.text.toString(),
        //       getCountry: countryName,
        //       getCountryArab: countryNameArab,
        //       getCountryCode: countryCodeint,
        //       starting: widget.starting,
        //     )));
      },
      verificationFailed: (FirebaseAuthException e) {
        log('${e.message}', name: 'firebase_error');
        Fluttertoast.showToast(
            msg: e.message ?? '', backgroundColor: Colors.red);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSend(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
