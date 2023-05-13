import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';


class SplashScreenSecond extends StatefulWidget {
  SplashScreenSecond({Key? key}) : super(key: key);

  @override
  _SplashScreenSecondState createState() {
    return _SplashScreenSecondState();
  }
}

class _SplashScreenSecondState extends State<SplashScreenSecond> {


  Timer? timer;
  bool _visible=true;
  _SplashScreenSecondState() {
    timer = Timer(const Duration(milliseconds:3000), () {
      setState(() {
        splashScreen=1;
        Navigator.of(context).pop(true);
      });
    });

  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds:2000), () { //asynchronous delay
      if (this.mounted) { //checks if widget is still active and not disposed
        setState(() { //tells the widget builder to rebuild again because ui has updated
          _visible=false; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TheamFont,
      builder: (context, child) {
        return Directionality(
          textDirection: Const.AppLanguage==0?TextDirection.ltr:TextDirection.rtl,
          child: child!,
        );
      },
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF0F0F0),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      AnimatedOpacity(
                        opacity: _visible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 1500),
                        // The green box must be a child of the AnimatedOpacity widget.
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: MediaQuery.of(context).size.width*0.3,
                          height:MediaQuery.of(context).size.width*0.3,
                          fit: BoxFit.contain,
                        ),
                      )

                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}