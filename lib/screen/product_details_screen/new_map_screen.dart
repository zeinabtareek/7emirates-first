import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewMapScreen extends StatefulWidget {

  NewMapScreen({Key? key,required this.placeLocation,required this.currentlocationOfTheUser,required this.placeName}) : super(key: key);
  final LatLng placeLocation;
  final Position currentlocationOfTheUser;
  final String placeName;
  GoogleMapController ?googleMapController;
    var markers =<Marker> [];
    var circles =<Circle> [];
  late Future mapFuture;
  bool check = false;
  var maptype  =MapType.normal;
  bool  isNormalMapType =false;
  final myMarkerId=1;


  @override
  State<NewMapScreen> createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  Completer<GoogleMapController> controller = Completer();

  onCameraMove(CameraPosition position) {
    setState(() {
    position.target;

    });
  }
  switchMapType(){
    setState(() {

      widget.isNormalMapType=!widget.isNormalMapType;
      widget.isNormalMapType?widget.maptype=MapType.hybrid:widget.maptype=MapType.normal;
    });

  }
  showPinsOnMap({currentLocation, placeLocation})  {
    try {
      widget.markers.add(Marker(
          markerId: MarkerId(widget.myMarkerId.toString()),
          position: placeLocation,
          infoWindow: InfoWindow(title: 'Place Location', snippet: "Location"),
          onTap: () {}));
      widget. markers.add(Marker(
          markerId: MarkerId('id'.toString()),
          position: currentLocation,
          infoWindow: InfoWindow(title: 'your current location', snippet: "Pick Up Location"),
          onTap: () {}));

     } catch (e) {
      print( '############no#########');
    }
  }
  addCircles(currentLocation){
    setState(() {


   widget. circles.add(
        Circle(
          circleId: CircleId('myCircle'),
          center:currentLocation,
          radius: 500.0, // radius in meters
          strokeWidth: 2,

          strokeColor: Colors.blueAccent.withOpacity(.1),
          fillColor: Colors.blue.withOpacity(0.1),
        )
    );
    });
  }
  @override
  Widget build(BuildContext context) {
     return  WillPopScope(
      onWillPop: () async {
        return disposeMethod();
      },
      child:Scaffold(
        backgroundColor: Colors.white,
        appBar:AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text( widget.placeName,
                style: TextStyle(fontSize: 20, color: Colors.black)),

            leading:  IconButton(onPressed: (){disposeMethod();},
                icon: const Icon(Icons.arrow_back_ios_outlined),color:Colors.black),
            actions: []),


        body:   SingleChildScrollView(
          child: Stack(
            children: [

              // GetBuilder<MapController>(
              //   init: MapController(currentlocationOfTheUser: currentlocationOfTheUser),
              //   builder: (controller)
              //   =>
                    Container(
                  // padding: EdgeInsets.all(10.sp),
                  // decoration:K.boxDecoration,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height/1.36,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child:   FutureBuilder(
                        future:  widget.mapFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            print("empty");
                            return const CircularProgressIndicator(
                              color: Colors.black
                            );
                          }
                          return GoogleMap(
                            gestureRecognizers: Set()
                              ..add(Factory<PanGestureRecognizer>(
                                      () => PanGestureRecognizer()))
                              ..add(Factory<ScaleGestureRecognizer>(
                                      () => ScaleGestureRecognizer()))
                              ..add(Factory<TapGestureRecognizer>(
                                      () => TapGestureRecognizer()))
                              ..add(Factory<
                                  VerticalDragGestureRecognizer>(
                                      () =>VerticalDragGestureRecognizer())),
                            mapType:  widget.maptype,
                            zoomControlsEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomGesturesEnabled: true,
                            markers:  widget.markers.toSet(),
                            mapToolbarEnabled: true,
                            compassEnabled: true,
                            initialCameraPosition: CameraPosition(
                                target: widget.placeLocation,
                                zoom: 15),
                            circles:  widget.circles.toSet(),
                            onCameraMove: onCameraMove,
                            onMapCreated: (GoogleMapController gcontroller) async {
                              setState(() {


                              controller.complete(gcontroller);
                              widget.googleMapController = gcontroller;
                               showPinsOnMap(placeLocation:widget.placeLocation,currentLocation:
                               LatLng(widget.currentlocationOfTheUser.latitude, widget.currentlocationOfTheUser.longitude));
                             addCircles(widget.placeLocation);

                              });
                            },
                            onTap: (LatLng loc) {   },
                          );
                        }),
                  ),
                ),

              Positioned(
                  left: 0,
                  top: 0,
                  child:
               Switch(
                    value:  widget.check,
                    onChanged: (v) {
                      setState(() {
                        widget. check = v;
                    switchMapType();
                      });
                    },
                    activeTrackColor: Colors.grey,

                    inactiveThumbColor:Colors.white,
                    activeColor:Colors.white,
                  )

                  )


            ],
          ),
          ),


        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(icons.length, (index) =>   Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,splashColor:icons[index]['color'],
                child:   Icon(icons[index]['icon']),
                onPressed: () async {
                  print('widget.placeLocation${widget.placeLocation}');
                  if(index==0){

                    final cameraUpdate = CameraUpdate.newLatLng(widget.placeLocation);
                    widget.googleMapController!.animateCamera(cameraUpdate);
                  }else if(index==1){

                    final cameraUpdate = CameraUpdate.newLatLng(LatLng(widget.currentlocationOfTheUser.latitude, widget.currentlocationOfTheUser.longitude));
                    widget.googleMapController!.animateCamera(cameraUpdate);
                  }
                },
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
 disposeMethod() {
Navigator.pop(context);
  }

  @override
  void initState() {
    print('widget.placeLocation${widget.placeLocation}');
   widget. mapFuture = Future.delayed(Duration(milliseconds: 10), () => true);

  }

 }

List icons=[
  {'icon':Icons.location_on_outlined, 'color': Colors.black,},
  {'icon':Icons.my_location,'color':Colors.red},
];