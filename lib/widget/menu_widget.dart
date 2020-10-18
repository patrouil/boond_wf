/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

class MenuItemText<T> extends PopupMenuItem<T> {
  MenuItemText({T entryCode, @required String label, Icon icon})
      : super(
          value: entryCode,
          child:
              (icon == null ? Text(label) : Row(children: [icon, Text(label)])),
        );
}

class MenuItemSettings<T> extends PopupMenuItem<T> {
  MenuItemSettings({T entryCode, @required String settingKey, Icon icon})
      : super(
            value: entryCode,
            child: Settings().onStringChanged(
                settingKey: settingKey,
                defaultValue: '',
                childBuilder: (BuildContext context, String value) {
                  return (icon == null
                      ? Text(
                          value,
                          textAlign: TextAlign.left,
                        )
                      : Row(children: [
                          icon,
                          Text(value, textAlign: TextAlign.left)
                        ]));
                })) {
    Future.delayed(Duration.zero, () {
      Settings().pingString(settingKey, '');
    });
  }
}
