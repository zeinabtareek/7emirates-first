import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class ProgressButton extends StatefulWidget {
  bool? showProgress;
  double? btwidth;
  double btheight;
  double btpadding;
  double btround;
  String? bttext;
  double bttextsize;
  Color btcolor;
  Color bttxtcolor;

  ProgressButton({Key? key,required this.showProgress,required this.btwidth,this.btheight=35,this.btpadding=0 ,required this.bttext,this.btround=5 ,this.bttextsize=10,this.btcolor=TheamSecondary,this.bttxtcolor=Colors.white}) : super(key: key);

  @override
  _ProgressButtonState createState() {
    return _ProgressButtonState();
  }
}

class _ProgressButtonState extends State<ProgressButton>  with RelativeScale{
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    return  Container(
      width: widget.btwidth,
      height: widget.btheight,
      alignment: Alignment.center,
      padding: EdgeInsets.all(widget.btpadding),
      decoration: decoration_round(Colors.transparent, sy(widget.btround), sy(widget.btround), sy(widget.btround), sy(widget.btround)),
      child: (widget.showProgress==false)?Text(widget.bttext!,style: ts_Regular(sy(widget.bttextsize), widget.bttxtcolor),):
      SizedBox(
        width:  widget.btwidth!/4,
        height: widget.btheight/3,
        child: LoadingIndicator(
            indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
            colors: [Colors.white],       /// Optional, The color collections
            strokeWidth: 1,                     /// Optional, The stroke of the line, only applicable to widget which contains line
            backgroundColor: Colors.transparent,      /// Optional, Background of the widget
            pathBackgroundColor: Colors.transparent /// Optional, the stroke backgroundColor
        ),
      ),
    );
  }
}