import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/url_open.dart';
import '../../maps/map_screen.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/url.dart';
import '../../utils/urls.dart';
import '../user/dashboard/model/products_model.dart';
import '../user/search_screen.dart';
import 'new_map_screen.dart';
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
class ProductDetails extends StatelessWidget {
  ProductDetails({Key? key, required this.product}) : super(key: key);
  Product product;
  String theCurrentImageSelected = '';
  int currentImageIndex = 0;
  Position ?currentPosition ;

  final photos = [
    'https://img.jamesedition.com/listing_images/2022/01/28/17/01/33/5d757c37-393f-4fa4-8cc6-f86d1e22d4b4/je/1040x620xc.jpg',
    'https://img.jamesedition.com/listing_images/2022/01/28/17/01/33/5d757c37-393f-4fa4-8cc6-f86d1e22d4b4/je/1040x620xc.jpg',
    'https://img.jamesedition.com/listing_images/2022/01/28/17/01/33/5d757c37-393f-4fa4-8cc6-f86d1e22d4b4/je/1040x620xc.jpg',
    'https://img.jamesedition.com/listing_images/2022/01/28/17/01/33/5d757c37-393f-4fa4-8cc6-f86d1e22d4b4/je/1040x620xc.jpg',
  ];


  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

    final Completer<GoogleMapController> gcontroller =
        Completer<GoogleMapController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            '${product.pTitle}$cur_Lang'.capitalize(),
//product.pTitle.capitalize()
            style: const TextStyle(

    color: Colors.black,
    overflow:
    TextOverflow.ellipsis)),
        centerTitle: true,
        actions: [
          Row(
            children: [
              // InkWell(
              //   child: Icon(Icons.share, color: fc_3),
              //   onTap: () {
              //     controller.shareContent();
              //   },
              // ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: fc_3,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(alignment: Alignment.topCenter, children: [
        Stack(
          children: [
            Positioned(
              child: InkWell(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  width: MediaQuery.of(context).size.width,
                  margin: null,
                  padding: null,
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: OctoImage(
                    image: CachedNetworkImageProvider(
                      Urls.imageLocation +  product.pImage.toString()??'',
                    ),
                    placeholderBuilder: OctoPlaceholder.blurHash(
                        'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                        fit: BoxFit.cover),
                    errorBuilder: (context, url, error) {
                      return   Image.asset('assets/images/no_image.png',fit: BoxFit.contain,
                      // Text(Lang('no image','لا توجد صورة') )
                      );
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  var image2=Urls.imageLocation +product.pImage;
                  if (product.pImage != null && product.pImage.isNotEmpty) {
                    showImageViewer(
                      context,image2!=''&& !image2.isEmpty?
                  Image.network(image2).image:Image.asset('assets/images/no_image.png').image,
                      // photos[currentImageIndex]).image,
                      // Image.network(index.photos!.first).image,
                      swipeDismissible: true,
                      doubleTapZoomable: true);
                }
                },
              ),
            ),

            Positioned(
                top: 3000,
                // bottom: 20,
                right: MediaQuery.of(context).size.width / 2,
                child: AnimatedSmoothIndicator(
                  activeIndex: currentImageIndex,
                  count: photos.length,
                  effect: WormEffect(
                      spacing: 8.0,
                      radius: 7.0,
                      dotWidth: 5,
                      dotHeight: 5.0,
                      paintStyle: PaintingStyle.stroke,
                      strokeWidth: 1.5,
                      dotColor: Colors.white,
                      activeDotColor: Colors.white),
                )),
            // )
            // ],
            // ),
            DraggableScrollableSheet(
                minChildSize: 0.6,
                maxChildSize: 1,
                initialChildSize: 0.6,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Directionality(
                      textDirection: TextDirection.ltr,
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(top: 20, right: 5, left: 5),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row(
                                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      Text(product.pTitle.capitalize()??'',

                                        // 'MARLO PROPERTY',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      Text(

                                        product.pAddress??'',
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(.7),
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text("${Lang(" Views  ", "المشاهدات  ")  +  ':'  + product.views??0 }",                                        // ' Name Business Centre, First Floor, OurSpace C.N.340, km. 176 · Marbella, 29600, Marbella',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(.7),
                                          fontSize: 14,
                                        ),
                                      ),

                                      Text(
                                        '${product.pAddress??''}',
                                        // 'villa in Benselvina , Andalusian , Spain ',
                                        style: TextStyle(
                                            color: Colors.grey.withOpacity(.9),
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis),
                                      ),   Text(
                                        '${product.pDated??''}',
                                        // 'villa in Benselvina , Andalusian , Spain ',
                                        style: TextStyle(
                                            color: Colors.grey.withOpacity(.9),
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis),
                                      ),

                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                URLUtils.openMap(
                                                    double.parse(product.pLat.toString()??
                                                        ""),
                                                    double.parse(product.pLng.toString() ??
                                                        ""));
                                              },
                                              icon: const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.black)),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.3,
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 20),
                                            child: Text(
                                              Lang('location ', 'الموقع على الخريطه').capitalize(),
                                              // Lang("location":""),
                                              style:   TextStyle(
                                                  color: Colors.black,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    customButtonForCalling(
                                        onTap: () async {
                                          UrlOpenUtils.call(_scaffoldKey ,product.phone);
                                          // await URLUtils.makePhoneCall( "${product.phone}");
                                              // '+201112134871'.toString());
                                        },
                                        text:
                                        Lang('Show Phone Number','اظهر رقم الهاتف'),
                                        textColor: Colors.white,
                                        btnColor: Colors.black),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    customButtonForCalling(
                                        onTap: () async {
                                          try {
                                            await launch(
                                                'whatsapp://send?phone=${product.phone}&text=Sent From 7emirates');
                                                // 'whatsapp://send?phone=201112134871&text=hello');
                                          } on PlatformException catch (e) {
                                            if (e.code ==
                                                'ACTIVITY_NOT_FOUND') {
                                              // Display an error message to the user
                                              print(
                                                  'WhatsApp is not installed on this device');
                                            }
                                          }

                                          // await URLUtils.launchInBrowser(
                                          //     "whatsapp://send?phone="
                                          //     "${product.phone}"
                                          //     // "201112134871"
                                          //     "&text=Sent From 7emirates");

                                          UrlOpenUtils.whatsappShop(_scaffoldKey ,product.phone);

                                        },
                                        textColor: Colors.black,
                                        btnColor: Colors.white,
                                        text:Lang('Send message',"إرسال رسالة" ),)
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    Lang('description ', 'وصف').capitalize(),
                                     style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Text(
                                  '${product.pDetail ??''}',
                                  // 'villa in Benselvina , Andalusian , Spain ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(.9),
                                      fontSize: 13,
                                     ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: SizedBox(
                                      width: 100,
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                        fit: BoxFit.contain,
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: RatingBar.builder(
                                    initialRating:
                                        double.tryParse(product.pRating.toString() ?? '') ?? 0,
                                        // double.tryParse('3' ?? '') ?? 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    ignoreGestures: true,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    // itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) =>
                                        Icon(Icons.star, color: fc_3),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                Container(
                                  height: 300,
                                  width: MediaQuery.of(context).size.width,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      // target: LatLng(37.43296265331129, -122.08832357078792),
                                      target: LatLng(double.parse(product.pLat.toString()),double.parse(product.pLng.toString()),),
                                      // target: LatLng(0.0, 0.0),
                                      zoom: 14,
                                    ),
                                    // markers:
                                    // PlaceController.markers.toSet(),
                                    onMapCreated: (GoogleMapController
                                        Mcontroller) async {
                                      gcontroller.complete(Mcontroller);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ));
                })
          ],
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          elevation: 50,
          backgroundColor: fc_6,
          autofocus: true,
          onPressed: () {

// print(LatLng(double.parse(product.pLat??''),
//     double.parse(product.pLng??'')));
 checkPermission
            (context,
                isRoute:false,
                endLatLng: LatLng(double.parse(product.pLat??''),
            double.parse(product.pLng??'')),
            func:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>NewMapScreen(placeName: product.pTitle.toString(),
             placeLocation:  LatLng(double.parse(product.pLat??''),
                double.parse(product.pLng??'')),
             currentlocationOfTheUser:  currentPosition??Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 100.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0),))));






            //
            // Get.to(MapScreen(placeName: index.name.toString(),
            //   placeLocation: LatLng(double.parse(index.lat!),
            //       double.parse(index.lng!)),
            //   currentlocationOfTheUser: controller.currentPosition!,));
            //
            // controller.checkPermission
            // (context,
            // isRoute:false,
            // endLatLng: LatLng(double.parse(index.lat!),
            // double.parse(index.lng!)),
            // func: Get.to(MapScreen(placeName: index.name.toString(),
            // placeLocation: LatLng(double.parse(index.lat!),
            // double.parse(index.lng!)),
            // currentlocationOfTheUser: controller.currentPosition??Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0),))
            // placeName: index.name.toString(),
            // placeLocation: LatLng(double.parse(index.lat!),
            //     double.parse(index.lng!)),
            // currentlocationOfTheUser: controller.currentPosition!,
            // );
          },
          label: const Text('SHOW MAP'),
          icon: const Icon(Icons.location_on_outlined)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Future<void> getCurrentPosition(BuildContext context, [LatLng? dis]) async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currentPosition = position;

    }).catchError((e) {

      // debugPrint(e);

    });
  }
  checkPermission(context,{endLatLng, required bool isRoute,
    // placeLocation, placeName,  Position? currentlocationOfTheUser
    required Future ?func
  })async{
    try{
      LocationPermission permission;

      bool serviceEnabled = await Geolocator
          .isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
              style: TextStyle(fontSize: 16),
            )));
        return;
      }
      permission =
      await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
        if (permission ==
            LocationPermission.denied) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
              content: Text(
                  'Location permissions are denied')));
          return;
        }
      }
      if (permission ==
          LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
        return;
      }
      if (permission ==
          LocationPermission.always ||
          permission ==
              LocationPermission.whileInUse)
      {
        // await getPlaces(catId);
        await getCurrentPosition(context);
        func;
      }
    }catch(e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          content: Text(
            'Location services are disabled. Please enable the services',
            style: TextStyle(fontSize: 16),
          )));
    }
  }
}

Widget customButtonForCalling(
    {required Function() onTap, text, textColor, btnColor}) {
  return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black.withOpacity(.5)),
              color: btnColor),
          child: Text(text, // 'call'.tr,
              style: TextStyle(color: textColor, fontSize: 16)),
        ),
      ));
}




Future<bool> handleLocationPermission(context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Warning'),
        content: Text('Location services are disabled.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Warning'),
          content: Text('Location permissions are denied.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Warning'),
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.'
      ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    return false;
  }
  return true;
}
