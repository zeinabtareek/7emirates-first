import 'package:sevenemirates/utils/const.dart';

class PriceUtils {
  static String convert(var price) {
    String passPrice = price.toString();
    double getPrice = 0;

    if (passPrice == '' || passPrice == 'null') {
      passPrice = '0';
    }

    try {
      getPrice = double.parse(passPrice.toString());
    } catch (e) {
      getPrice = 0;
    }

    double getCurrancyVal = 1;
    switch (Const.CURRENCY_LAB) {
      case 'AED':
        getCurrancyVal = Const.CUR_AED;
        break;
      case 'BHD':
        getCurrancyVal = Const.CUR_BHD;
        break;
      case 'KWD':
        getCurrancyVal = Const.CUR_KWD;
        break;
      case 'EGP':
        getCurrancyVal = Const.CUR_EGP;
        break;
      case 'OMR':
        getCurrancyVal = Const.CUR_OMR;
        break;
      case 'QAR':
        getCurrancyVal = Const.CUR_QAR;
        break;
      case 'SAR':
        getCurrancyVal = Const.CUR_SAR;
        break;
      case 'INR':
        getCurrancyVal = Const.CUR_INR;
        break;
    }

    double finalPrice = getCurrancyVal * getPrice;

    return finalPrice.toStringAsFixed(0) + ' ' + Const.CURRENCY_LAB + " ";
  }

  static String convertWithoutLable(var price) {
    String passPrice = price.toString();
    double getPrice = 0;

    if (passPrice == '' || passPrice == 'null') {
      passPrice = '0';
    }

    try {
      getPrice = double.parse(passPrice.toString());
    } catch (e) {
      getPrice = 0;
    }

    double getCurrancyVal = 1;
    switch (Const.CURRENCY_LAB) {
      case 'AED':
        getCurrancyVal = Const.CUR_AED;
        break;
      case 'BHD':
        getCurrancyVal = Const.CUR_BHD;
        break;
      case 'KWD':
        getCurrancyVal = Const.CUR_KWD;
        break;
      case 'EGP':
        getCurrancyVal = Const.CUR_EGP;
        break;
      case 'OMR':
        getCurrancyVal = Const.CUR_OMR;
        break;
      case 'QAR':
        getCurrancyVal = Const.CUR_QAR;
        break;
      case 'SAR':
        getCurrancyVal = Const.CUR_SAR;
        break;
      case 'INR':
        getCurrancyVal = Const.CUR_INR;
        break;
    }

    double finalPrice = getCurrancyVal * getPrice;

    return finalPrice.toStringAsFixed(0);
  }

  static String convertWithQuantity(var price, var quantity) {
    String passPrice = price.toString();
    double getPrice = 0;
    int getQuantity;
    try {
      getQuantity = int.parse(quantity.toString());
    } catch (e) {
      getQuantity = 1;
    }

    if (passPrice == '' || passPrice == 'null') {
      passPrice = '0';
    }

    try {
      getPrice = double.parse(passPrice.toString());
    } catch (e) {
      getPrice = 0;
    }

    double getCurrancyVal = 1;
    switch (Const.CURRENCY_LAB) {
      case 'AED':
        getCurrancyVal = Const.CUR_AED;
        break;
      case 'BHD':
        getCurrancyVal = Const.CUR_BHD;
        break;
      case 'KWD':
        getCurrancyVal = Const.CUR_KWD;
        break;
      case 'EGP':
        getCurrancyVal = Const.CUR_EGP;
        break;
      case 'OMR':
        getCurrancyVal = Const.CUR_OMR;
        break;
      case 'QAR':
        getCurrancyVal = Const.CUR_QAR;
        break;
      case 'SAR':
        getCurrancyVal = Const.CUR_SAR;
        break;
      case 'INR':
        getCurrancyVal = Const.CUR_INR;
        break;
    }

    double finalPrice = getCurrancyVal * getPrice * getQuantity;

    return finalPrice.toStringAsFixed(0) + ' ' + Const.CURRENCY_LAB + " ";
  }
}
