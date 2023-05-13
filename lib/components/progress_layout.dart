import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyProgressLayout extends StatelessWidget {

  bool showProgress;
  MyProgressLayout(this.showProgress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Visibility(
      visible: showProgress,
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Container(
          color: Colors.white,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade50,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.5,
                                height: MediaQuery.of(context).size.width*0.45,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.2,
                                height: 10.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5,),
                              Container(

                                width: MediaQuery.of(context).size.width*0.3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5,),
                              Container(
                                width:  MediaQuery.of(context).size.width*0.3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),

                            ],
                          ),),
                          SizedBox(width: 15,),
                          Expanded(child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.5,
                                height: MediaQuery.of(context).size.width*0.45,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.2,
                                height: 10.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5,),
                              Container(

                                width: MediaQuery.of(context).size.width*0.3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5,),
                              Container(
                                width:  MediaQuery.of(context).size.width*0.3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),

                            ],
                          ),),
                        ],
                      )
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
