import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/components/relative_scale.dart';

import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../user/add_product_screen/add_product_screen.dart';

class ChooseType extends StatelessWidget {
  const ChooseType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:  Text(
          Lang(" CHOOSE AD TYPE  ", " اختر نوع الإعلان "),
          style: ts_Regular(15, fc_1),
        ),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined,size: 15,color: Colors.black,),onPressed: (){
          Navigator.pop(context);
        },),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0,right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ..AddProduct
            SizedBox(
              height: 30,
            ),
            Text(
              Lang(" Select your ad category type ",
                  "حدد نوع فئة الإعلان الخاصة بك "),
              style: ts_Bold(15, fc_2),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              Lang(
                  " You can choose between vip , general and, story ad ",
                  "يمكنك الاختيار بين إعلان vip و General و Story "),
              style: ts_Regular(12, fc_4),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
            children:  List.generate(3, (i) =>  Center(
               child: GestureDetector(
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>AddProduct(adType:Const.adsList[i].toString())));
                 },
                 child: Container(
                   height: MediaQuery.of(context).size.height/20,
                   width: MediaQuery.of(context).size.width/2,
                    color: fc_6,
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.all(5),
                    child: Text(
                      Const.adsList[i].toUpperCase(),
                      style: ts_Regular(15,  fc_2),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
               ),
             ))),

          ],
        ),
      ),
    );
  }
}
