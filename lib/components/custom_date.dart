import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/dateconvert.dart';

class CustomeDate{

  static dateTime(String userdate){
    if(userdate==null || userdate=='null'){
      return 'Not Updated';
    }else{
      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , false);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).month.toString();
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }


      String splitdate=date +'-'+ month+'-'+year;

      finalOut=splitdate+'   '+splitTime;

      return finalOut;
    }

  }
  static date(String userdate){
    if(userdate==null || userdate=='null'){
      return 'Not Updated';
    }else{
      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , true);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).month.toString();
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }


      String splitdate=date +'-'+ month+'-'+year;

      finalOut=splitdate;

      return finalOut;
    }

  }
  static expdate({int addDays=0}){

      String finalOut='';
      String splitTime=DateConvert.getDated(DateTime.now().toString() , true);
      DateTime dt = DateTime.parse(DateTime.now().add(Duration(days: addDays)).toString());
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).month.toString();
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }


      String splitdate=year + month+date;

      finalOut=splitdate;

      return finalOut;


  }

  static dateMonth(String userdate){
    if(userdate==null || userdate=='null'){
      return 'Not Updated';
    }else{
      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , true);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).MMM;
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }


      String splitdate=month+'  '+year;

      finalOut=splitdate;

      return finalOut;
    }

  }

  static datedaymonth(String userdate){
    if(userdate==null || userdate=='null'){
      return 'Not Updated';
    }else{
      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , true);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).MMM;
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }


      String splitdate=date+' '+month;

      finalOut=splitdate;

      return finalOut;
    }

  }

  static age(String userdate){
    if(userdate==null || userdate=='null'){
      return 'Age';
    }else{
      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , true);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      String date = Jiffy(defaultFormat).date.toString();
      String month = Jiffy(defaultFormat).month.toString();
      String year = Jiffy(defaultFormat).year.toString();
      if(month.length==1){
        month='0'+month;
      }
      if(date.length==1){
        date='0'+date;
      }

      int birthYear=DateTime.now().year-Jiffy(defaultFormat).year;


      String splitdate=birthYear.toString()+' yrs';

      finalOut=splitdate;

      return finalOut;
    }

  }
  static ago(String userdate){

    if(userdate==null || userdate=='null'){
      return 'Not Updated';
    }else{

      String finalOut='';
      String splitTime=DateConvert.getDated(userdate , true);
      DateTime dt = DateTime.parse(userdate);
      String defaultFormat=DateFormat('yyyy-MM-ddT07:12:50').format(dt);

      final date2 = DateTime.now();
      final difference = date2.difference(dt);

      if ((difference.inDays / 7).floor() >= 1) {
        return   Lang('1 week', 'أسبوع 1') ;
      } else if (difference.inDays >= 2) {
        return difference.inDays.toString()+' '+Lang('days', 'أيام');
      } else if (difference.inDays >= 1) {
        return    Lang('1 day', 'يوم 1');
      } else if (difference.inHours >= 2) {
        return '${difference.inHours}'+' '+Lang('hrs', "ساعات");
      } else if (difference.inHours >= 1) {
        return    Lang('1 hrs', "1 ساعة");
      } else if (difference.inMinutes >= 2) {
        return '${difference.inMinutes}'+' '+Lang('min', "اللحظة");
      } else if (difference.inMinutes >= 1) {
        return    Lang('1 min', "1 دقيقة");
      } else if (difference.inSeconds >= 3) {
        return '${difference.inSeconds}'+' '+Lang('sec', "ثانيا");
      } else {
        return Lang('now', "حاليا");
      }

    //  finalOut=difference.toString();

    //  return finalOut;
    }

  }


 }


//AM PM TIME
class DateConvert{

  static getDated(String dated, bool withdate){

    if(dated==null || dated=='' || dated=='null' ){

      return 'Not updated';
    }else{

      int morning, hour, min;
      String getdated;

      morning=0;
      String lab;
      hour=int.parse(dated.substring(11,13));
      min=int.parse(dated.substring(14,16));
      getdated=dated.substring(0,10);

      if(hour>12){
        lab='p.m';
      }else if(hour==12){
        lab='p.m';
      }else{
        lab='a.m';
      }

      if (hour > 23 || min > 59)
      {
        //add Zero
        String thour,tmin;
        if((hour.toString()).length==1){
          thour='0$hour';
        }else{
          thour='$hour';
        }

        if((min.toString()).length==1){
          tmin='0$min';
        }else{
          tmin='$min';
        }


        return (withdate==true)? "$getdated  $thour:$tmin $lab" : "$thour:$tmin $lab";

      }

      if (hour >= 12)
      {
        morning = 1;

        if (hour > 12)
        {
          hour -= 12;
        }

      }

      //if input is 00xx
      if (hour == 0)
      {
        morning = 2;
        hour = hour + 12;
      }
      else
      {
        morning = 0;
      }

      //print the result
      if (morning == 2)
      {
        //add Zero
        String thour,tmin;
        if((hour.toString()).length==1){
          thour='0$hour';
        }else{
          thour='$hour';
        }

        if((min.toString()).length==1){
          tmin='0$min';
        }else{
          tmin='$min';
        }

        return (withdate==true)? "$getdated  $thour:$tmin $lab" : "$thour:$tmin $lab";

      }
      if (morning == 0)
      {
        //add Zero
        String thour,tmin;
        if((hour.toString()).length==1){
          thour='0$hour';
        }else{
          thour='$hour';
        }

        if((min.toString()).length==1){
          tmin='0$min';
        }else{
          tmin='$min';
        }

        return (withdate==true)? "$getdated  $thour:$tmin $lab" : "$thour:$tmin $lab";
      }
      if (morning == 1)
      {
        //add Zero
        String thour,tmin;
        if((hour.toString()).length==1){
          thour='0$hour';
        }else{
          thour='$hour';
        }

        if((min.toString()).length==1){
          tmin='0$min';
        }else{
          tmin='$min';
        }

        return (withdate==true)? "$getdated  $thour:$tmin $lab" : "$thour:$tmin $lab";
      }


    }

  }






}
