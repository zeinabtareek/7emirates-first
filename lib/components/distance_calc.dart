import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/utils/app_settings.dart';

class DistanceCalc{

  static map(BuildContext context,String location,){

    double distanceInMeters=0;
    List maploc=location.toString().split(', ');
    double mylat= double.parse( Provider.of<AppSetting>(context, listen: false).maplat);
    double mylong= double.parse(Provider.of<AppSetting>(context, listen: false).maplon);
    if(maploc.length>1){
      distanceInMeters = Geolocator.distanceBetween(mylat,mylong, double.parse(maploc[0].toString()), double.parse(maploc[1].toString()));
    }

    if(distanceInMeters>1000){
      return (distanceInMeters/1000).toStringAsFixed(0)+' '+'km';
    }else{
      return (distanceInMeters).toStringAsFixed(2)+' '+'m';
    }

  }
}