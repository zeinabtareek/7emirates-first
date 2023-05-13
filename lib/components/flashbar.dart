import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class Pop{

  static void successPop(BuildContext context ,String title ,String message, IconData icon) {
    showFlash(
      context: context,
      transitionDuration: Duration(milliseconds: 700),
      duration: Duration(milliseconds: 7000),
      builder: (context, controller) {

        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,

          boxShadows: kElevationToShadow[4],
          backgroundColor: TheamPrimary,
          brightness: Brightness.light,
         // barrierBlur:50,
         // barrierColor:Colors.green,
          barrierDismissible:false,
          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.top,
          child: FlashBar(
          //  padding: EdgeInsets.fromLTRB(10, 30, 30, 10),
            icon: Icon(icon,
              size: 30.0,
              color: Colors.white,
            ),
            title: Text(title,style: ts_Bold(12, Colors.white,),),
            content: Text(message,style: ts_Regular(10, Colors.white,),),
            indicatorColor: Colors.blue,
            showProgressIndicator: true,
            shouldIconPulse: true,
            actions: [

              TextButton(
                onPressed: () => controller.dismiss(),
                child: Text(Lang('Close'  , 'إغلاق' ), style: ts_Bold(15,Colors.white)), )

            ],
          ),
        );;
      },
    );
  }
  static void errorPop(BuildContext context ,String title ,String message, IconData icon) {


    showFlash(
      context: context,
      transitionDuration: Duration(milliseconds: 700),
      duration: Duration(milliseconds: 7000),
      builder: (context, controller) {



        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[4],
          backgroundColor: Colors.red[400],
          brightness: Brightness.light,
          //barrierBlur:50,
         // barrierColor:Colors.red,
          barrierDismissible:false,
          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.top,
          child: FlashBar(
            icon: Icon(icon,
              size: 40.0,
              color: Colors.white,
            ),
            title: Text(title,style: ts_Bold(15, Colors.white,),),
            content: Text(message,style: ts_Regular(12, Colors.white,),),
            indicatorColor: Colors.blue,
            showProgressIndicator: true,
            shouldIconPulse: true,
            actions: [

              TextButton(
                onPressed: () => controller.dismiss(),
                child: Text(Lang('Close'  , 'إغلاق' ), style: ts_Bold(15,Colors.white)), )

            ],
          ),
        );
      },
    );
  }

  static void messagePop(BuildContext context ,String title ,String message, IconData icon,List<Widget> widgetlist) {
    showFlash(
      context: context,
      transitionDuration: Duration(milliseconds: 700),
      duration: Duration(milliseconds: 4000),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          boxShadows: kElevationToShadow[4],
          behavior: FlashBehavior.floating,
          backgroundColor: TheamPrimary,
          position: FlashPosition.top,
          child: FlashBar(
            icon: Icon(icon,
              size: 40.0,
              color: Colors.white,
            ),
            title: Text(title,style: ts_Bold(17, Colors.white,),),
            content: Text(message,style: ts_Regular(14, Colors.white,),),
            shouldIconPulse: true,
            actions: [

              TextButton(
                onPressed: () => controller.dismiss(),
                child: Text(Lang('Close'  , 'إغلاق' ), style: ts_Bold(12,Colors.white)), ),

              widgetlist[0],

            ],
          ),
        );
      },
    );
  }

  static void success(BuildContext context ,String message, IconData icon) {

    showFlash(
      context: context,
      duration: Duration(milliseconds: 3000),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[4],
          backgroundColor: TheamPrimary,
          brightness: Brightness.light,

          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.bottom,
          child: FlashBar(
            icon: Icon( icon,
              size: 20.0,
              color: Colors.white,
            ),
            content: Text(message,style: ts_Regular(12, Colors.white),),
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child: Text(Lang(  'Ok','موافق'  ), style: TextStyle(color: Colors.white,fontSize: n)),
            ),
          ),
        );
      },
    );
  }
  static void error(BuildContext context ,String message, IconData icon) {

    showFlash(
      context: context,
      duration: Duration(milliseconds: 3000),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[4],
          backgroundColor: Colors.red[400],
          brightness: Brightness.light,

          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.bottom,
          child: FlashBar(
            icon: Icon( icon,
              size: 20.0,
              color: Colors.white,
            ),
            content: Text(message,style: ts_Regular(12, Colors.white),),
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child: Text(Lang(  'Ok','موافق'  ), style: TextStyle(color: Colors.white,fontSize: n)),
            ),
          ),
        );
      },
    );
  }
  static void successTop(BuildContext context ,String message, IconData icon) {

    showFlash(
      context: context,
      duration: Duration(milliseconds: 3000),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[4],
          backgroundColor: Colors.green.shade600,
          brightness: Brightness.light,

          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.top,
          child: FlashBar(
            shouldIconPulse: true,
            icon: Icon( icon,
              size: 20.0,
              color: Colors.white,
            ),
            content: Text(message,style: ts_Regular(12, Colors.white),),
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child: Text(Lang(  'Ok','موافق'  ), style: TextStyle(color: Colors.white,fontSize: n)),
            ),
          ),
        );
      },
    );
  }
  static void errorTop(BuildContext context ,String message, IconData icon) {

    showFlash(
      context: context,
      duration: Duration(milliseconds: 3000),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[3],
          backgroundColor: Colors.red[500],
          brightness: Brightness.light,
          horizontalDismissDirection: HorizontalDismissDirection.endToStart,
          position: FlashPosition.top,
           child: FlashBar(
            shouldIconPulse: true,
            icon: Icon( icon,
              size: 25.0,
              color: Colors.grey[200],
            ),
            content: Text(message,style: ts_Regular(l, Colors.white),),
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child: Text(Lang(  'Ok','موافق'  ), style: TextStyle(color: Colors.white,fontSize: n)),
            ),
          ),
        );
      },
    );
  }

  static void successBar(BuildContext context ,String title ,String message, IconData icon) {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      transitionBuilder: (mcontext, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (mcontext, anim1, anim2) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(mcontext).pop();
        });
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            height: 200,
            width: Width(context),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),

            ),
            child:Column(
              children: [
                Image.asset('assets/images/complete.gif',width: 100,height: 100,fit: BoxFit.contain,),
                SizedBox(height: 50,),
                Text(title,style: ts_Regular(12, Colors.white),)
              ],
            ),
          ),
        );
      },

    );
  }


}