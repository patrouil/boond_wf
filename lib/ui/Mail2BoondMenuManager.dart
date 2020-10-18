/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import '../widget/BoondAuthBrowser.dart';

import '../widget/menu_widget.dart';
import 'Mail2BoondSettings.dart';

enum _Mail2BoondMenuEvent { appsSettings }

class Mail2BoondMenuManager extends StatefulWidget {
  static final Logger _log = Logger('Mail2BoondMenuManager');

  Mail2BoondMenuManager() : super() {
    // _log.level = Level.FINE;
  }

  @override
  Mail2BoondMenuManagerState createState() => Mail2BoondMenuManagerState();
}

class Mail2BoondMenuManagerState extends State<Mail2BoondMenuManager> {
  static final Logger _log = Logger('Mail2BoondMenuManager');

  @override
  void initState() {
    super.initState();
  }

  List<PopupMenuEntry<_Mail2BoondMenuEvent>> buildMenu(BuildContext c) {
    List<PopupMenuEntry<_Mail2BoondMenuEvent>> menuList =
        new List<PopupMenuEntry<_Mail2BoondMenuEvent>>();
    _log.fine("[buildMenu] start");

    menuList.add(MenuItemSettings<_Mail2BoondMenuEvent>(
      settingKey: BoondAuthBrowser.BOONDUSER_SETTINGS_KEY,
    ));

    menuList.add(MenuItemText<_Mail2BoondMenuEvent>(
        entryCode: _Mail2BoondMenuEvent.appsSettings,
        label: "Settings",
        icon: Icon(Icons.settings, color: Colors.black)));

    menuList.add(MenuItemText<_Mail2BoondMenuEvent>(
        label: "About", icon: Icon(Icons.info, color: Colors.black)));

    _log.fine("[buildMenu] done");

    return menuList;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Mail2BoondMenuEvent>(
        icon: new Icon(Icons.menu),
        onSelected: menuSelectedAction,
        itemBuilder: buildMenu);
  }

  void menuSelectedAction(_Mail2BoondMenuEvent code) {
    switch (code) {
      case _Mail2BoondMenuEvent.appsSettings:
        Mail2BoondSettings.mainSettings.show(this.context);
        break;
      default:
        throw UnimplementedError();
    }
  }
}
