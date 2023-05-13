import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ImageFullScreen extends StatelessWidget {
  final String imgurl;
  ImageFullScreen({Key? key,@required this.imgurl=''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            width: Width(context),
            height: Height(context),
            child:  Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Zoom(
                    maxZoomWidth: 1800,
                    maxZoomHeight: 1800,
                    initZoom: 0.0,
                    backgroundColor: Colors.white,
                    child:  Container(

                      color: Colors.white,
                      child: FadeInImage.assetNetwork(
                        image: imgurl,
                        placeholder:  Urls.DummyImageBanner,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                      ),
                    ),

                  ),),
                Positioned(
                  top:10,
                  right: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop(true);

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
