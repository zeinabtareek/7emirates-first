import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sevenemirates/screen/product_details_screen/product_details_screen.dart';
import 'package:story_time/story_page_view/story_page_view.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:video_player/video_player.dart';

import '../../components/image_viewer.dart';
import '../../components/url_open.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';
import '../user/add_product_screen/add_product_screen.dart';
import '../user/add_product_screen/model/CategoryModel.dart';
import '../user/dashboard/model/products_model.dart';
import '../user/product_view_screen.dart';
import 'model/model.dart';

import 'package:http/http.dart' as http;




class UserModel {
  UserModel(this.stories, this.userName, this.imageUrl);

  final  Product stories;
  final String userName;
  final String imageUrl;
}

class StoryModel {
  StoryModel(this.imageUrl);

  final String imageUrl;
}

// class StoryPage extends StatefulWidget {
//   final List<Product> stories;
//    final List  storiesLength;
//   final Category category;
//    final selectedCategoryId;
//
//     StoryPage({required this.stories
//     ,required this.storiesLength
//      ,required this.selectedCategoryId
//     ,required this.category});
//
//   @override
//   StoryPageState createState() => StoryPageState();
// }
//
// class StoryPageState extends State<StoryPage> {
//   late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
//
//    @override
//   void initState() {
//     super.initState();
//
//     indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
//       IndicatorAnimationCommand(resume: true),
//     );
//   }
//
//   @override
//   void dispose() {
//     indicatorAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StoryPageView(
//         onStoryIndexChanged: (int newStoryIndex) {
//             if (newStoryIndex == 1) {
//             indicatorAnimationController.value = IndicatorAnimationCommand(
//               duration: const Duration(seconds: 5),
//             );
//
//           } else {
//             indicatorAnimationController.value = IndicatorAnimationCommand(
//               duration: const Duration(seconds: 5),
//             );
//           }
//         },
//         onPageBack: (int newPageIndex) {
//           int oldPage = newPageIndex + 1;
//           print("from oldPage:$oldPage to newPage:$newPageIndex");
//         },
//         onPageForward: (int newPageIndex) {
//           // int oldPage = newPageIndex - 2;
//           int oldPage = newPageIndex - 1;
//           // printCategoryId(oldPage);
//           //
//            Navigator.pop(context);
//           // print("from oldPage:$oldPage to newPage:$newPageIndex");
//           print('yalllaaa');
//
//         },
//         onStoryUnpaused: () {
//           print("Story is unpaused!!");
//         },
//         onStoryPaused: () {
//           print("Story is paused!!");
//         },
//         itemBuilder: (context, pageIndex, storyIndex) {
//           final stories = widget.stories.where((story) => story.cId == widget.category.id).toList();
//           final story = stories[storyIndex];
//           return Stack(
//             children: [
//               Positioned.fill(
//                 child: Container(color: Colors.black),
//               ),
//               Positioned.fill(
//                 child: CustomeImageView(
//                   image: Urls.imageLocation + widget.stories[storyIndex].pImage,
//                   placeholder: Urls.DummyImageBanner,
//                   fit: BoxFit.cover,
//                   blurBackground: false,
//                    width: Width(context),
//                 ),
//                 // story.imageUrl,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 44, left: 8),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 32,
//                       width: 32,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(Urls.imageLocation + widget.stories[storyIndex].pImage,),
//                           fit: BoxFit.cover,
//                         ),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 8,
//                     ),
//                     Text(
//                       widget.stories[storyIndex].name,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//         gestureItemBuilder: (context, pageIndex, storyIndex) {
//           return Stack(
//             children: [
//               Align(
//                 alignment: Alignment.topRight,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 32),
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     color: Colors.white,
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ),
//               // if (pageIndex == 0)
//               //   Center(
//               //     child: ElevatedButton(
//               //       child: const Text('show modal bottom sheet'),
//               //       onPressed: () async {
//               //         indicatorAnimationController.value =
//               //             IndicatorAnimationCommand(
//               //               pause: true,
//               //             );
//               //         await showModalBottomSheet(
//               //           context: context,
//               //           builder: (context) => SizedBox(
//               //             height: MediaQuery.of(context).size.height / 2,
//               //             child: Padding(
//               //               padding: const EdgeInsets.all(24),
//               //               child: Text(
//               //                 'Look! The indicator is now paused\n\n'
//               //                     'It will be coutinued after closing the modal bottom sheet.',
//               //                 style: Theme.of(context).textTheme.headline5,
//               //                 textAlign: TextAlign.center,
//               //               ),
//               //             ),
//               //           ),
//               //         );
//               //         indicatorAnimationController.value =
//               //             IndicatorAnimationCommand(
//               //               resume: true,
//               //             );
//               //       },
//               //     ),
//               //   ),
//             ],
//           );
//         },
//         indicatorAnimationController: indicatorAnimationController,
//         initialStoryIndex: (pageIndex) {
//           print(pageIndex);
//           if (pageIndex == 2) {//0
//             return 3;
//           }
//           return 0;
//         },
//         pageLength:  widget.storiesLength.length,//2
//         storyLength: (int pageIndex) {
//           final stories = widget.stories.where((story) => story.cId == widget.category.id).toList();
//           return stories.length;
//         },
//         // storyLength: (int pageIndex) {
//         //   // return widget.storiesLength.length;
//         //   return widget.stories.length;//3,1
//         // },
//         onPageLimitReached: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }

///new

class StoryPage extends StatefulWidget {
  List<Product> stories;
  final List  storiesLength;
  final Category category;
  final selectedCategoryId;

  StoryPage({required this.stories
    ,required this.storiesLength
    ,required this.selectedCategoryId
    ,required this.category});

  @override
  StoryPageState createState() => StoryPageState();
}

class StoryPageState extends State<StoryPage> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
func(cid){


}

  getNewProductsByType(
      {required String restEndPoint, required String adType}) async {
    final url =
    Uri.parse('https://www.7emiratesapp.ae/API/mobile_api/$restEndPoint');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final data = <String, String>{
      'type': adType,
      'key': '2520',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: data,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final productList = ProductList.fromJson(jsonResponse);
      return productList.productlist;
    } else {
      throw Exception('Failed to load data');
    }
  }
  getCategoryStories(String cid) async {
    var resultsOfStories = await getNewProductsByType(
        restEndPoint: 'products_by_type.php', adType: 'stories');
    var resultOfCategory =
    await getNewCategory(restEndPoint: 'cats_by_type.php', adType: 'stories');

    var category = resultOfCategory.firstWhere((category) => category.id == cid);
    var storyList = <Product>[];

    for (var story in resultsOfStories) {
      if (story.cId == cid) {
        storyList.add(story);
      }
    }
    print({'category ..': category.name, 'stories': storyList});
    return  storyList;
    // return {'category ..': category, 'stories': storyList};
  }
  @override
  initState()   {
    super.initState();
    widget.stories;
     getCategoryStories(widget.selectedCategoryId);

    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
      IndicatorAnimationCommand(resume: true),


    );
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

    return Scaffold(
      body: StoryPageView(
        onStoryIndexChanged: (int newStoryIndex) {
          if (newStoryIndex == 1) {
            indicatorAnimationController.value = IndicatorAnimationCommand(
              duration: const Duration(seconds: 5),
            );

          } else {
            indicatorAnimationController.value = IndicatorAnimationCommand(
              duration: const Duration(seconds: 5),
            );
          }
        },
        onPageBack: (int newPageIndex) {
          int oldPage = newPageIndex + 1;
          print("from oldPage:$oldPage to newPage:$newPageIndex");
        },
        onPageForward: (int newPageIndex) {
          // int oldPage = newPageIndex - 2;
          // int oldPage = newPageIndex - 1;
          // printCategoryId(oldPage);
          //
          Navigator.pop(context);
           print('yalllaaa');
           setState(() {

          // widget.stories =  getCategoryStories(oldPage.toString());
           });

        },
        onStoryUnpaused: () {
          print("Story is unpaused!!");
        },
        onStoryPaused: () {
          print("Story is paused!!");
        },
        itemBuilder: (context, pageIndex, storyIndex) {
          final stories = widget.stories.where((story) => story.cId == widget.category.id).toList();
          final story = stories[storyIndex];
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: CustomeImageView(
                  image: Urls.imageLocation + widget.stories[storyIndex].pImage,
                  placeholder: Urls.DummyImageBanner,
                  fit: BoxFit.cover,
                  blurBackground: false,
                  width: Width(context),
                ),
                // story.imageUrl,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(Urls.imageLocation + widget.stories[storyIndex].pImage,),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // widget.stories[storyIndex].pTitle,
                          '${widget.stories[storyIndex].pTitle}$cur_Lang'.capitalize(),
                       style: ts_Bold(20, fc_1)),

                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          // widget.stories[storyIndex].pTitle,
                          '${widget.stories[storyIndex].pDated}$cur_Lang'.capitalize(),
                          style:  ts_Bold(10, fc_1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // if (pageIndex == 0)
                Positioned(
                  bottom:MediaQuery.of(context).size.height/5,
                  right: MediaQuery.of(context).size.width/20,
                  left: MediaQuery.of(context).size.width/20,
                  // top: ,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(  '${widget.stories[storyIndex].name}$cur_Lang'.capitalize() ??'',style: ts_Bold(20, fc_1),),
                      // Text(  '${widget.stories[storyIndex].pDetail}$cur_Lang'.capitalize() ??'',style: ts_Bold(20, fc_1),),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.phone, color: fc_5,size: 20,),
                          SizedBox(width: 5,),
                          GestureDetector(
                            child:   Text(  '${widget.stories[storyIndex].phone}$cur_Lang'.capitalize()??'' ,style: ts_Bold(20, fc_1),),
                            onTap: () async {
                              UrlOpenUtils.call(_scaffoldKey ,widget.stories[storyIndex].phone);



                              // indicatorAnimationController.value =
                              //     IndicatorAnimationCommand(
                              //       pause: true,
                              //     );
                              // await showModalBottomSheet(
                              //   context: context,
                              //   builder: (context) => SizedBox(
                              //     height: MediaQuery.of(context).size.height / 2,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(24),
                              //       child: Text(
                              //         'Look! The indicator is now paused\n\n'
                              //             'It will be coutinued after closing the modal bottom sheet.',
                              //         style: Theme.of(context).textTheme.headline5,
                              //         textAlign: TextAlign.center,
                              //       ),
                              //     ),
                              //   ),
                              // );
                              // indicatorAnimationController.value =
                              //     IndicatorAnimationCommand(
                              //       resume: true,
                              //     );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Positioned(
                bottom: 10,
                  right: 0,
                  left: 0,
                  // top: 0,
                  child: IconButton(
                onPressed: () async {
                indicatorAnimationController.value =
                    IndicatorAnimationCommand(
                      pause: true,
                    );
                await showModalBottomSheet(
                  context: context,
                  builder: (context) =>   ProductViewScreen(
                      pid: widget.stories[storyIndex].pId.toString(),
                      pname: widget.stories[storyIndex].pTitle.toString(),
                      pimage: widget.stories[storyIndex].pImage.toString(),
                    ),

                );
                indicatorAnimationController.value =
                    IndicatorAnimationCommand(
                      resume: true,
                    );
              }, icon: Icon(Icons.keyboard_arrow_down_sharp,size: 40,),
                
              ))
            ],
          );
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          print(pageIndex);
          if (pageIndex == 2) {//0
            return 3;
          }
          return 0;
        },
        pageLength:  widget.storiesLength.length,//2
        storyLength: (int pageIndex) {
          final stories = widget.stories.where((story) => story.cId == widget.category.id).toList();
          return stories.length;
        },
        // storyLength: (int pageIndex) {
        //   // return widget.storiesLength.length;
        //   return widget.stories.length;//3,1
        // },
        onPageLimitReached: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}