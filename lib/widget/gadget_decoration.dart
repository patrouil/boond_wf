/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';

class GadgetDecoration extends Container {
  static final Logger log = Logger("GadgetDecoration");

  GadgetDecoration({Key key, @required Widget child, Color color})
      : super(
            key: key,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Material(
                elevation: 12.0,
                borderRadius: BorderRadius.circular(24.0),
                child: child));

  static const double ALPHA_SHIFT_RATIO = 0.10;

  static screenColor(BuildContext context, {double shift = ALPHA_SHIFT_RATIO}) {
    ThemeData d = Theme.of(context);
    Color c = d.backgroundColor;
    double newAlpha =
        ((c.alpha > 127) ? c.alpha * (1.0 - shift) : c.alpha * shift);
    Color r = Color(c.value);

    return r.withAlpha(newAlpha.round());
  }

  static const double COLOR_SHIFT_RATIO = 0.10;

  static gadgetColor(BuildContext context, {double shift = COLOR_SHIFT_RATIO}) {
    ThemeData d = Theme.of(context);
    Color c = d.backgroundColor;

    double newRed = ((c.red > 127) ? c.red * (1.0 - shift) : c.red * shift);
    double newBlue = ((c.blue > 127) ? c.blue * (1.0 - shift) : c.blue * shift);
    double newGreen =
        ((c.green > 127) ? c.green * (1.0 - shift) : c.green * shift);
    return Color.fromARGB(
        128, newRed.round(), newGreen.round(), newBlue.round());
  }
}
