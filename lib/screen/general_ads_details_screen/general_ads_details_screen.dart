import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:octo_image/octo_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GeneralAdsDetailsScreen extends StatelessWidget {
    GeneralAdsDetailsScreen({Key? key}) : super(key: key);

  // final controller = Get.put(PlaceController());
  String theCurrentImageSelected = '';
int currentImageIndex=0;
  @override
  Widget build(BuildContext context) {
    // final aboutUsController = Get.put(AboutUsController());

    // final Completer<GoogleMapController> gcontroller =
    // Completer<GoogleMapController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            // Obx(() =>
            // controller.isLoading.value == true ? const Center(
            //     child: CupertinoActivityIndicator(color: K.mainColor,))
            //     :

            Row(
              children: [
                InkWell(
                  child: Icon(Icons.share, color: Colors.red),
                  onTap: () {
                    // controller.shareContent();
                  },
                ),
              ],
            ),
            // ),
          ],
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              // color: K.mainColor,
            ),
            onPressed: () {
              // Get.back();
            },
          )),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Stack(
            children: [
              Positioned(
                child: InkWell(
                  child: CarouselSlider(
                    options: CarouselOptions(
                        autoPlay: false,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height / 2.4,
                        viewportFraction: 1,
                        onPageChanged: (index1, reason) {
                          // controller.currentImageIndex.value = index1;
                          // theCurrentImageSelected = index.photos![index1];
                        }),
                    items: index
                        .map(
                          (item) =>
                          Container(
                            clipBehavior: Clip.antiAlias,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            margin: null,
                            padding: null,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.transparent, width: 0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: OctoImage(
                              image: CachedNetworkImageProvider(
                                item,
                              ),
                              placeholderBuilder: OctoPlaceholder.blurHash(
                                  'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                  fit: BoxFit.cover),
                              errorBuilder: (context, url, error) {
                                return const BlurHash(
                                    hash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj');
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                    )
                        .toList(),
                  ),
                  onTap: () {
                    showImageViewer(
                        context,
                        Image
                            .network('https://media.istockphoto.com/photos/generic-red-suv-on-a-white-background-side-view-picture-id1157655660?b=1&k=20&m=1157655660&s=612x612&w=0&h=ekNZlV17a3wd_yN9PhHXtIabO_zFo4qipCy2AZRpWUI=')
                            .image,
                        // Image.network(index.photos!.first).image,
                        swipeDismissible: true,
                        doubleTapZoomable: true);
                    // Get.toNamed(AppRoute.detailsScreen);
                  },
                ),
              ),

                    Positioned(
                        bottom: 120,
                        right: MediaQuery
                            .of(context)
                            .size
                            .width / 2.7,
                        child: AnimatedSmoothIndicator(
                          activeIndex:  currentImageIndex,
                          count: index.length,
                          effect:   WormEffect(
                            spacing: 8.0,
                            radius: 7.0,
                            dotWidth: 5,
                            dotHeight: 5.0,
                            paintStyle: PaintingStyle.stroke,
                            strokeWidth: 1.5,
                            dotColor:Colors.white,
                            activeDotColor: Colors.white,
                          ),
                        )),
            ],
              ),

          DraggableScrollableSheet(
              minChildSize: 0.6,
              maxChildSize: 1,
              initialChildSize: 0.6,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Directionality( textDirection:TextDirection.ltr,
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
                              // Obx(()=> Text( controller.distanceInKm.value.toString())),
                              // Obx(()=>  controller.handleLocationPermission(context)?
                              // Obx(()=>  controller.handleLocationPermission(context)?

                              //  controller.disLoad.value?const CircularProgressIndicator(): Text( controller.calculateDistance().toString())
                              // :SizedBox(),),
                              //  Obx(() {
                              //    if (controller.disLoad.value) {
                              //      return CircularProgressIndicator();
                              //    } else if (controller.distanceInKm.value > 0) {
                              //      return Container(
                              //        padding: EdgeInsets.all(5.sp),
                              //        decoration: BoxDecoration(
                              //            borderRadius:
                              //            BorderRadius.circular(15.r),
                              //            color:
                              //            K.blackColor.withOpacity(.6)),
                              //        child: Text('${(controller
                              //            .distanceInKm.toStringAsFixed(2))} ${ CacheHelper
                              //            .getData(
                              //            key: 'distanceMeters')
                              //            ? 'km'
                              //            : 'miles'.tr
                              //        }',
                              //            style: K.whiteTextStyle
                              //        ),
                              //      );
                              //      // Text(controller.distanceInKm.value.toString());
                              //    } else {
                              //      return Text('Location permission not granted');
                              //    }
                              //  }),

                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 1.5,
                                    child: Text('commercial use ✓ '?? '',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),


                                ],
                              ),
                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  customButtonForCalling(onTap: () async {
                                    // await URLUtils.makePhoneCall(
                                    //     aboutUsController.model.data!.phone1
                                    //         .toString());
                                  }, text: 'call'),
                                  SizedBox(width: 20,),

                                  customButtonForCalling(onTap: () async {

                                    // await URLUtils.launchInBrowser("whatsapp://send?phone="
                                    //     "${
                                    //     aboutUsController.model.data!.whatsapp
                                    //         .toString()}"
                                    //     "&text=hello");


                                  }, text: 'whatsapp')
                                ],),
                              SizedBox(height: 20,),

                              SizedBox(
                                width: double.infinity,
                                child: Text('commercial use ✓ No attribution required ✓ Cop '?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 20,),
                              // K.sizedboxH,
                              Center(
                                child: SizedBox(
                                    width: 300,
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.contain,
                                    )),
                              ),
                              SizedBox(height: 20,),
                              Center(
                                child: RatingBar.builder(
                                  initialRating: double.tryParse('3' ?? '') ??
                                      0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  ignoreGestures: true,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  // itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) =>
                                  const Icon(
                                    Icons.star,
                                    color: Colors.red,
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
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
      // floatingActionButton: Obx(() =>
      // controller.places.length != 0
      //     ? FloatingActionButton.extended(
      //     elevation: 50,
      //     backgroundColor: K.mainColor,
      //     autofocus: true,
      //     onPressed: () {
            // Get.to(MapScreen(placeName: index.name.toString(),
            //   placeLocation: LatLng(double.parse(index.lat!),
            //       double.parse(index.lng!)),
            //   currentlocationOfTheUser: controller.currentPosition!,));

            // controller.checkPermission
            //   (context,
            //     isRoute:false,
            //     endLatLng: LatLng(double.parse(index.lat!),
            //         double.parse(index.lng!)),
            //     func: Get.to(MapScreen(placeName: index.name.toString(),
            //       placeLocation: LatLng(double.parse(index.lat!),
            //           double.parse(index.lng!)),
            //       currentlocationOfTheUser: controller.currentPosition??Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0),))
              // placeName: index.name.toString(),
              // placeLocation: LatLng(double.parse(index.lat!),
              //     double.parse(index.lng!)),
              // currentlocationOfTheUser: controller.currentPosition!,
      //       ); }, label: const Text('SHOW MAP'),
      //     icon: const Icon(Icons.location_on_outlined))
      //     : SizedBox()),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
Widget customButtonForCalling({required Function ()onTap, text}){
  return  InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          padding:   EdgeInsets.only(
              left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
               ),
          child: Text(text,// 'call'.tr,
              // style: K.whiteTextStyle
          ),
        ),
      )
  );
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final int dotCount;
  final Color dotColor;
  final Color backgroundColor;

  CustomCircularProgressIndicator({
    this.dotCount = 3,
    this.dotColor = Colors.black,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          dotCount,
              (index) => Padding(
            padding:   EdgeInsets.all(5.0),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: index == 0 ? dotColor : backgroundColor.withOpacity(.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


List index=[
  'https://media.istockphoto.com/photos/generic-red-suv-on-a-white-background-side-view-picture-id1157655660?b=1&k=20&m=1157655660&s=612x612&w=0&h=ekNZlV17a3wd_yN9PhHXtIabO_zFo4qipCy2AZRpWUI=',
  'https://media.istockphoto.com/photos/generic-red-suv-on-a-white-background-side-view-picture-id1157655660?b=1&k=20&m=1157655660&s=612x612&w=0&h=ekNZlV17a3wd_yN9PhHXtIabO_zFo4qipCy2AZRpWUI=',
  'https://media.istockphoto.com/photos/generic-red-suv-on-a-white-background-side-view-picture-id1157655660?b=1&k=20&m=1157655660&s=612x612&w=0&h=ekNZlV17a3wd_yN9PhHXtIabO_zFo4qipCy2AZRpWUI=',
  'https://media.istockphoto.com/photos/generic-red-suv-on-a-white-background-side-view-picture-id1157655660?b=1&k=20&m=1157655660&s=612x612&w=0&h=ekNZlV17a3wd_yN9PhHXtIabO_zFo4qipCy2AZRpWUI=',
];