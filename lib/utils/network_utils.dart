import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'helper.dart';

class NetworkUtil {
  // ignore: prefer_final_fields
  static NetworkUtil _instance = NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  Dio dio = Dio();

  Future<Response?> get(
    String url, {
    BuildContext? context,
    String? specificLangCode,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool withHeader = true,
    bool useAppDomain = true,
  }) async {
    if (kDebugMode) {
      log('your url is $url');
    }
    Response? response;
    try {
      // (dio.httpClientAdapter as BrowserHttpClientAdapter).onHttpClientCreate =
      //     (HttpClient client) {
      //   client.badCertificateCallback =
      //       (X509Certificate cert, String host, int port) => true;
      //   return client;
      // };
      var options2 = Options(
          responseType: responseType, headers: withHeader ? {} : headers);

      // print('$url ${options2.headers}');
      response = await dio.get(url, options: options2);
    } on DioError catch (e) {
      log('Error is : ${e.message}');
      response = e.response;

      // var prefs = context.read(sharedPreferences).prefs;
      // var _prefs = prefs;
      // if (e.response != null) {
      //   if (e.response.statusCode >= 500) {
      //     log('ssgggdsdsdsd yup');

      //     await N.replaceAll(
      //       const SplashScreen(),
      //     );
      //     log('ssgggdsdsdsd yup');
      //     await _prefs.clear().then((value) => log('done'));
      //     Phoenix.rebirth(context);
      //   }
      //   response = e.response;
      //   log("response bbb: " + e.response.toString());
      // } else {}
    }
    return response == null ? null : handleResponse(response, context, url);
  }

  Future<Response?> post(String url,
      {BuildContext? context,
      Map<String, dynamic>? headers,
      FormData? body,
      bool withHeader = true,
      encoding}) async {
    if (kDebugMode) {
      log('your url is $url');
    }
    Response? response;

    // (dio.httpClientAdapter as BrowserHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };

    try {
      response = await dio.post(url,
          data: body,
          options: Options(
              headers: withHeader ? {} : headers, requestEncoder: encoding));
    } on DioError catch (e) {
      log(' from post ${e.error} + message ${e.message}');
      if (e.response != null) {
        log('response : => ${e.response?.data}');
        response = e.response;
      }
      // var prefs = context.read(sharedPreferences).prefs;

      // var _prefs = prefs;
      // if (e.response != null) {
      //   if (e.response.statusCode >= 500) {
      //     log('ssdsdsdsd yup');
      //     await N.replaceAll(
      //       const SplashScreen(),
      //     );
      //     await _prefs.clear().then((value) => log('done'));
      //     Phoenix.rebirth(context);
      //   }
      //   response = e.response;
      //   log("response bb: " + e.response.toString());
      // } else {}
    }
    return response == null ? null : handleResponse(response, context, url);
  }

  Future<Response?> handleResponse(
      Response response, BuildContext? context, String url) async {
    final int? statusCode = response.statusCode;
    log("$url response: ..." + response.toString());

    // Future.delayed(const Duration(milliseconds: 1), () async {
    //   var _prefs = context.read(sharedPreferences).prefs;
    //   if (response.statusCode >= 500 || response.data['success'] != null) {
    //     log('ssdsdsdsd yup');
    //     if ((response.data['message'] as String)
    //         .toLowerCase()
    //         .contains('token')) {
    //       await _prefs.remove('user').then((value) => log('done'));
    //       Phoenix.rebirth(context);
    //       N.replaceAll(
    //         const SplashScreen(),
    //       );
    //       return;
    //     }
    //   }
    // });
    log('handle $statusCode');
    if (statusCode! >= 200 && statusCode < 300) {
      return response;
    }
    return response;
  }
}
