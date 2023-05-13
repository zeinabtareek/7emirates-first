import 'package:flutter/material.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';

class WidgetHelp{

  static getNameFromId(String id,List arr,String key,String value){
    for(int i=0;i<arr.length;i++)
      if(id==arr[i][key]){
        return arr[i][value].toString();
      }
  }

  static Widget profilePic(String image,String name,double width,double height,double radius){
    return  Container(
      height:height,
      width:width,
      alignment: Alignment.center,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: (image!='' && image!='null')?CustomeImageView(
            image: Urls.imageLocation+image.toString(),
            placeholder: Urls.DummyImageBanner,
            fit: BoxFit.cover,
            height: height,
            width:width,
          ):Container(
            height:height,
            width:width,
            color: TheamPrimary,
            alignment: Alignment.center,
            child: Text(name.toString().toUpperCase().substring(0,2),style: ts_Bold(width/2.5, fc_bg),),
          )),
    );
  }
}
