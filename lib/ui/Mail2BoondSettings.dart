/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import 'candidate/BoondSettings.dart';

class Mail2BoondSettings {
  // singleton
  static Mail2BoondSettings mainSettings;
  static final Logger log = Logger('Mail2BoondSettings');

  final String titre;

  Mail2BoondSettings({String this.titre = "Settings"}) {
    if (Mail2BoondSettings.mainSettings == null)
      Mail2BoondSettings.mainSettings = this;
  }

  void show(BuildContext c) {
    assert(c != null);
    showDialog(
      context: c,
      builder: (BuildContext c) {
        return SettingsScreen(
          title: this.titre,
          children: [
            Container(
                width: MediaQuery.of(c).size.width / 2,
                child: BoondSettings(title: "Boond Manager workflow"))
          ],
        );
      },
    );
  }
}
