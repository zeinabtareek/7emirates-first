import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class RatingWidget extends StatelessWidget {
  final String ratings;
  final double size;
  final Color color;
  RatingWidget({Key? key,this.ratings="0",this.size=0.0,this.color=TheamPrimary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RatingStars();
  }

  RatingStars( ) {

    String finalRating= double.parse(ratings).round().toString();
    switch (finalRating) {
      case "0":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
          ],
        );
        break;

      case "1":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
          ],
        );
        break;

      case "2":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
          ],
        );
        break;

      case "3":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
          ],
        );
        break;

      case "4":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star_border,
              color: color,
              size: size,
            ),
          ],
        );
        break;

      case "5":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
            Icon(
              Icons.star,
              color: color,
              size: size,
            ),
          ],
        );
        break;
    }
    ;
  }
}
