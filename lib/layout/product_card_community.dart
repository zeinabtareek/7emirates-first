import 'package:flutter/material.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/distance_calc.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/screen/user/chat_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import '../router/open_screen.dart';
import '../screen/user/product_view_screen.dart';
import '../utils/const.dart';
import '../utils/style_sheet.dart';
import '../utils/translation_widget.dart';
import '../utils/urls.dart';
import '../components/image_viewer.dart';

class ProductCardCommunityMain extends StatefulWidget {
  int i = 0;
  List getProducts = [];
  BuildContext mcontext;
  ProductCardCommunityMain(
      {Key? key, this.i = 0, required this.getProducts, required this.mcontext})
      : super(key: key);

  @override
  State<ProductCardCommunityMain> createState() =>
      _ProductCardCommunityMainState();
}

class _ProductCardCommunityMainState extends State<ProductCardCommunityMain>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
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
    initRelativeScaler(context);
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Container(
        //  height: Width(context) * 0.26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TranslationWidget(
                          message: widget.getProducts[widget.i]["p_title"]
                              .toString(),
                          style: ts_Bold(sy(n), fc_3),
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      Text(
                        CustomeDate.ago(
                            widget.getProducts[widget.i]["p_dated"].toString()),
                        style: ts_Regular(sy(s), fc_5),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  TranslationWidget(
                    message:
                        widget.getProducts[widget.i]["p_detail"].toString(),
                    style: ts_Regular(sy(s), fc_4),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: sy(3),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                          decoration: decoration_round(
                              Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                          child: Text(
                            widget.getProducts[widget.i]["c_name$cur_Lang"]
                                .toString()
                                .toUpperCase(),
                            style: ts_Regular(sy(s - 1), fc_4),
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(sy(1), 0, sy(1), 0),
                          child: Icon(
                            Icons.arrow_right,
                            size: sy(n),
                            color: fc_5,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                          decoration: decoration_round(
                              Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                          child: Text(
                            widget.getProducts[widget.i]["sc_title$cur_Lang"]
                                .toString()
                                .toUpperCase(),
                            style: ts_Regular(sy(s - 1), fc_4),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            UrlOpenUtils.call(
                              _scaffoldKey,
                              widget.getProducts[widget.i]["phone"].toString(),
                            );
                          },
                          style: elevatedButtonBorder(TheamSecondary, sy(3)),
                          child: Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.call,
                                  size: sy(n),
                                  color: TheamSecondary,
                                ),
                                SizedBox(
                                  width: sy(5),
                                ),
                                Text(
                                  Lang('Call', 'اتصال'),
                                  style: ts_Regular(sy(s), TheamSecondary),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        width: sy(8),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                widget.mcontext,
                                OpenScreen(
                                    widget: ChatScreen(
                                  opImage: widget.getProducts[widget.i]
                                          ['profile_pic']
                                      .toString(),
                                  opName: widget.getProducts[widget.i]['name'],
                                  opId: widget.getProducts[widget.i]['u_id']
                                      .toString(),
                                )));
                          },
                          style: elevatedButtonBorder(TheamSecondary, sy(3)),
                          child: Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: sy(n),
                                  color: TheamSecondary,
                                ),
                                SizedBox(
                                  width: sy(5),
                                ),
                                Text(
                                  Lang('Chat', 'دردشة'),
                                  style: ts_Regular(sy(s), TheamSecondary),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
