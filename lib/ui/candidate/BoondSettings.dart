/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_api/net/BoondApi.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import '../../widget/settings_widget.dart';

class BoondSettings extends StatelessWidget {
  static final Logger _log = Logger('BoondSettings');

  static const String BoondServerNameKey = "mail2boond.boond.server.name";
  static const String BoondUserNameKey = "mail2boond.boond.user.name";
  static const String BoondClientKeyKey = "mail2boond.boond.client_key.key";
  static const String BoondClientTokenKey = "mail2boond.boond.client_token.key";

  static const String BoondDefaultActionTypeOfKey =
      "mail2boond.boond.actions.typeOf.key";

  final String title;

  BoondSettings({String this.title = "Boond Manager Settings"});

  @override
  Widget build(BuildContext context) {
    return ExpansionSettingsTile(
      title: this.title,
      visibleByDefault: true,
      initiallyExpanded: true,
      children: [
        RadioSettingsTile(
            settingKey: BoondServerNameKey,
            defaultKey: BoondApi.LIVE_HOSTNAME,
            title: "Server host name :",
            values: {
              BoondApi.LIVE_HOSTNAME: 'Production',
              BoondApi.SANDBOX_HOSTNAME: 'Recette'
            }),
        TextFieldSettingsTile(
          settingKey: BoondClientKeyKey,
          title: "Boond workspace Client Key :",
        ),
        TextFieldSettingsTile(
          settingKey: BoondClientTokenKey,
          title: "Boond workspace Client Token :",
        ),
      ],
    );
  }
}
