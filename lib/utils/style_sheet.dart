import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Colors
const Color TheamPrimary = Color(0xFF212121);
Color TheamBG = Color(0xFFF5F5F5);
const Color TheamSecondary = Color(0xFF0B98EA);
Color TheamButton = Color(0xFF212121);

Color darkOvery = Color(0xFF1F2328);
Color darkText = Color(0xFF95A1AE);

bool? isDark;
Color? fc_bg;
Color? fc_bg2;
Color? fc_textfield_bg;
Color? fc_1;
Color? fc_2;
Color? fc_3;
Color? fc_4;
Color? fc_5;
Color? fc_6;
Color? fc_icnav_on;
Color? fc_icnav_off;
Color? fc_bg_mild;

//FONTS
double xxl = 20;
double xl = 16;
double ll = 14;
double l = 12;
double n = 10;
double s = 8;
double xs = 6;

double Width(BuildContext context) => MediaQuery.of(context).size.width;
double Height(BuildContext context) => MediaQuery.of(context).size.height;

//APP Theam
ThemeData TheamFont = ThemeData(
    primaryColor: TheamPrimary, textTheme: GoogleFonts.outfitTextTheme());
//TEXT STYLE
TextStyle ts_Regular(double? size, Color? color) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w500,
  );
}

TextStyle ts_Regular_spaced(double? size, Color? color, double space) {
  return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w500,
      letterSpacing: space);
}

TextStyle ts_Bold_Weight(double size, Color? color, FontWeight fontWeight) {
  return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal);
}

TextStyle ts_Italic(double? size, Color? color) {
  return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic);
}

TextStyle ts_Bold(double? size, Color? color,
    {FontWeight fontWeight = FontWeight.w700}) {
  return TextStyle(color: color, fontSize: size, fontWeight: fontWeight);
}

TextStyle ts_Bold_space(double? size, Color? color, double space) {
  return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: space);
}

TextStyle ts_regular_strike(double? size, Color? color) {
  return TextStyle(
    fontSize: size,
    color: color,
    decoration: TextDecoration.lineThrough,
  );
}

TextStyle ts_Bold_strike(double? size, Color? color) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.lineThrough,
  );
}

TextStyle ts_Regular_underline(double? size, Color? color) {
  return TextStyle(
    fontSize: size,
    color: color,
    decoration: TextDecoration.underline,
  );
}

TextStyle ts_stock(double? size, Color? color, Color? stoke) {
  return TextStyle(
    fontSize: size,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = stoke!,
  );
}

BoxDecoration darkBox = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Colors.white,
      TheamPrimary.withOpacity(0.2),
    ],
  ),
);

//TextField
UnderlineInputBorder textfieldBorder(Color color) {
  return UnderlineInputBorder(
    borderSide: BorderSide(color: color),
  );
}

//Container
BoxDecoration decoration_image(
  Color? color,
  String imglink,
  double topLeft,
  double topRight,
  double bottomLeft,
  double bottomRight,
) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    ),
    image: DecorationImage(
      image: AssetImage(imglink),
      fit: BoxFit.cover,
    ),
  );
}

BoxDecoration decoration_round(Color? color, double topLeft, double topRight,
    double bottomLeft, double bottomRight) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    ),
  );
}

BoxDecoration decoration_border(
    Color? color,
    Color? bordercolor,
    double borderWidth,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight) {
  return BoxDecoration(
    color: color,
    border: Border.all(color: bordercolor??Colors.grey, width: borderWidth),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    ),
  );


}

ButtonStyle elevatedButton(Color? color, double radius,{double elevation=0}){
  return ElevatedButton.styleFrom(primary: color,
    elevation: elevation,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  ),);
}


ButtonStyle elevatedButtonTrans(){
  return ElevatedButton.styleFrom(
    primary: Colors.white,
    elevation: 0,
    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

ButtonStyle elevatedButtonBorder(Color? color, double radius){
  return ElevatedButton.styleFrom(primary: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(style: BorderStyle.solid,color: color!,width: 1),
      borderRadius: BorderRadius.circular(radius),
    ),);
}
