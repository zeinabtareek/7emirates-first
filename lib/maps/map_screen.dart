import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with RelativeScale {
  double lat = 24.319831;
  double lng = 54.799529;
  LatLng _kMapCenter = LatLng(24.319831, 54.799529);

  late GoogleMapController _mapcontroller;
  late CameraPosition _kInitialPosition;
  bool _serviceEnabled = false;
  loc.Location location = loc.Location();
  loc.PermissionStatus _permissionGranted = loc.PermissionStatus.denied;
  loc.LocationData? _locationData;
  bool showMap = false;
  Uint8List? markerIcon;
  Marker locMarker = Marker(
    markerId: MarkerId("Here"),
  );
  List<Placemark> placemarks = [];
  String address = '';
  String city = '';
  String country = '';

  TextEditingController ETname = TextEditingController();
  TextEditingController ETstreet = TextEditingController();
  TextEditingController ETsearch = TextEditingController();
  List<dynamic> _placeList = [];
  var uuid = new Uuid();
  String _sessionToken = '';
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _kMapCenter = LatLng(lat, lng);

    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
    getLocation();
    getLocationFromPoints();
  }

  @override
  void dispose() {
    super.dispose();
    _mapcontroller.dispose();
  }

  getLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationServiceEnabled == true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _kMapCenter = LatLng(position.latitude, position.longitude);
        _kInitialPosition = CameraPosition(
            target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
      });
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    setState(() {
      _kMapCenter = LatLng(_locationData!.latitude!.toDouble(),
          _locationData!.longitude!.toDouble());
      _kInitialPosition =
          CameraPosition(target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
    });

    _mapcontroller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _kMapCenter, zoom: 15),
      ),
    );
    getLocationFromPoints();
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: Provider.of<AppSetting>(context).appTheam,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection:
              Const.AppLanguage == 0 ? TextDirection.ltr : TextDirection.rtl,
          child: child!,
        );
      },
      home: Container(
          child: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: mapWidget(),
          ),
        ),
      )),
    );
  }

  mapWidget() {
    return Container(
        width: Width(context),
        height: Height(context),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: sy(0),
              right: 0,
              bottom: 0,
              child: Container(
                  color: fc_bg,
                  width: Width(context),
                  height: Height(context),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: GoogleMap(
                                  mapType: MapType.normal,
                                  myLocationEnabled: false,
                                  zoomControlsEnabled: false,
                                  initialCameraPosition: _kInitialPosition,
                                  //markers: _createMarker(),
                                  onCameraMove: _onCameraMove,

                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _mapcontroller = controller;
                                    // changeMapMode();
                                    // getLocation();
                                  },
                                ),
                              ),
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.gps_fixed,
                                size: sy(25),
                                color: TheamPrimary,
                              ),
                            )
                          ],
                        ),
                      ),
                      //   if(_keyboardVisible == false)addressBar(),
                    ],
                  )),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                      margin:
                          EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
                      width: MediaQuery.of(context).size.width,
                      child: Material(
                        borderRadius: BorderRadius.circular(sy(5)),
                        color: fc_bg,
                        elevation: 2,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(
                                sy(5), sy(0), sy(10), sy(0)),
                            width: MediaQuery.of(context).size.width,
                            decoration: decoration_round(
                                fc_bg, sy(5), sy(5), sy(5), sy(5)),
                            alignment: Alignment.center,
                            height: sy(35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: sy(xl),
                                    color: fc_3,
                                  ),
                                ),
                                SizedBox(
                                  width: sy(7),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: ETsearch,
                                    textAlign: TextAlign.left,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: ts_Regular(sy(n), fc_1),
                                    //  expands: true,

                                    decoration: InputDecoration(
                                      hintText:
                                          Lang('Search here', 'البحث هنا'),
                                      hintStyle: ts_Regular(sy(n), fc_4),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      border: InputBorder.none,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    autofocus: false,
                                    onChanged: (val) {
                                      if (_sessionToken.isEmpty) {
                                        setState(() {
                                          _sessionToken = uuid.v4();
                                        });
                                      }
                                      getSuggestion(ETsearch.text);
                                      if (ETsearch.text == '') {
                                        setState(() {
                                          _placeList.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                (ETsearch.text != '')
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _placeList.clear();
                                            ETsearch.clear();
                                            FocusScope.of(context).unfocus();
                                          });
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          size: sy(xl),
                                          color: fc_2,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          getLocation();
                                        },
                                        child: Icon(
                                          Icons.gps_fixed,
                                          size: sy(xl),
                                          color: fc_4,
                                        ),
                                      )
                              ],
                            )),
                      )),
                  if (_placeList.length != 0)
                    Container(
                      margin:
                          EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
                      padding:
                          EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),
                      decoration:
                          decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
                      child: Column(
                        children: [
                          for (int i = 0; i < _placeList.length; i++)
                            GestureDetector(
                              onTap: () {
                                getPlaceName(
                                    _placeList[i]["place_id"].toString());
                              },
                              child: Container(
                                  width: Width(context),
                                  decoration: decoration_round(
                                      fc_bg, sy(5), sy(5), sy(5), sy(5)),
                                  padding: EdgeInsets.fromLTRB(
                                      sy(10), sy(5), sy(10), sy(5)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: sy(xl),
                                            color: Colors.grey.shade400,
                                          ),
                                          SizedBox(
                                            width: sy(5),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _placeList[i]["description"],
                                              style: ts_Regular(sy(n), fc_3),
                                            ),
                                          )
                                        ],
                                      ),
                                      if (i != _placeList.length - 1)
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              sy(0), sy(5), sy(0), sy(0)),
                                          width: Width(context),
                                          height: sy(1),
                                          color: Colors.grey.shade300,
                                        )
                                    ],
                                  )),
                            )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_keyboardVisible == false)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: addressBar(),
              )
          ],
        ));
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _kMapCenter = position.target;
    });

    // _mapcontroller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _kMapCenter,zoom: 13)));
    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
    getLocationFromPoints();
  }

  Set<Marker> _createMarker() {
    locMarker = Marker(
        markerId: MarkerId("Pin Location"),
        position: _kMapCenter,
        draggable: false,
        //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: Lang('Here', 'هنا')),
        onTap: () {
          getLocationFromPoints();
        },
        onDragEnd: (val) {
          setState(() {
            _kMapCenter = val;
            _kInitialPosition = CameraPosition(
                target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
            getLocationFromPoints();
          });
        });
    setState(() {
      showMap = true;
      getLocationFromPoints();
    });
    return {locMarker};
  }

  changeMapMode() async {
    getJsonFile("assets/images/nightmode.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _mapcontroller.setMapStyle(mapStyle);
  }

  getLocationFromPoints() async {
    //  placemarks = await placemarkFromCoordinates(locMarker.position.latitude, locMarker.position.longitude);
    placemarks = await placemarkFromCoordinates(
        _kMapCenter.latitude, _kMapCenter.longitude);
try{
    setState(() {
      address = placemarks[0].street.toString() +
          ', ' +
          placemarks[0].thoroughfare.toString() +
          ', ' +
          placemarks[0].subLocality.toString() +
          ', ' +
          placemarks[0].locality.toString() +
          ' ' +
          placemarks[0].postalCode.toString();

      city = placemarks[0].locality.toString();
      ETname.text = placemarks[0].locality.toString();
      ETstreet.text = address;
      country = placemarks[0].country.toString();
    });
  }catch(e){

  }
  }

  addressBar() {
    return Container(
      height: sy(100),
      margin: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sy(10)),
        child: Container(
            color: Colors.white.withOpacity(0.7),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              address,
                              style: ts_Regular(sy(n), fc_1),
                            ),
                            scrollDirection: Axis.vertical,
                          ),
                        ),
                        SizedBox(
                          height: sy(5),
                        ),
                        ElevatedButton(
                            style: elevatedButton(TheamPrimary, sy(5)),
                            onPressed: () {
                              setState(() {
                                try {
                                  address = ETname.text.toString() +
                                      ',' +
                                      ETstreet.text.toString();
                                  address =
                                      address.toString().replaceAll("'", ' ');
                                  address =
                                      address.toString().replaceAll('"', ' ');
                                  address =
                                      address.toString().replaceAll('/', ' ');
                                  Navigator.of(context).pop({
                                    'lat': _kMapCenter.latitude.toString(),
                                    'long': _kMapCenter.longitude.toString(),
                                    'address': address.toString(),
                                    'city': ETname.text.toString(),
                                    'country': country.toString()
                                  });
                                } catch (e) {
                                  apiTest(e.toString());
                                }
                              });
                            },
                            child: Container(
                              width: Width(context),
                              height: sy(30),
                              alignment: Alignment.center,
                              child: Text(
                                Lang('Confirm Location', 'تأكيد الموقع'),
                                style: ts_Regular(sy(n), Colors.white),
                              ),
                            )),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  getPlaceName(String input) async {
    String kPLACES_API_KEY = Const.GOOGLE_MAP_PLACE;

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$input&key=$kPLACES_API_KEY';
    apiTest(url);
    var response = await http.get(Uri.parse(url));

    var jsonRes = json.decode(response.body)['result'] as Map<String, dynamic>;

    var lat = jsonRes['geometry']['location']['lat'];
    var lng = jsonRes['geometry']['location']['lng'];
    print(url);

    setState(() {
      _kMapCenter =
          LatLng(double.parse(lat.toString()), double.parse(lng.toString()));
      _mapcontroller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _kMapCenter, zoom: 13)));
      FocusScope.of(context).unfocus();
      _placeList.clear();
      ETsearch.clear();
    });

    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 18.0, tilt: 0, bearing: 0);
    getLocationFromPoints();
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = Const.GOOGLE_MAP_PLACE;
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    log('${response.body}',name: 'data');
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception(Lang('Failed to load predictions', 'فشل تحميل التوقعات'));
    }
  }
}
