import 'dart:convert';

import 'package:flutter/services.dart';

class World {
  static final World _country = World._internal();

  factory World() {
    return _country;
  }
  World._internal();
  static List<dynamic> Countries = [];
  static List<dynamic> States = [];
  Future<void> initCountryJson() async {
    var countryJson =
        await rootBundle.loadString('assets/images/flag/countries.json');
    Countries = jsonDecode(countryJson)['countries'];
    var statesJson =
        await rootBundle.loadString('assets/images/flag/states.json');
    States = jsonDecode(statesJson)['states'];
  }
}
