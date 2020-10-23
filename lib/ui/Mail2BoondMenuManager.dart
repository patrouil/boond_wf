/*
 * Copyright (c) patrouil 2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 */
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import '../widget/BoondAuthBrowser.dart';

import '../widget/menu_widget.dart';
import 'AboutPage.dart';
import 'Mail2BoondSettings.dart';

enum _Mail2BoondMenuEvent { appsSettings, about }

class Mail2BoondMenuManager extends StatefulWidget {
  final Logger _log = Logger('Mail2BoondMenuManager');

  Mail2BoondMenuManager() : super() {
    // _log.level = Level.FINE;
  }

  @override
  Mail2BoondMenuManagerState createState() => Mail2BoondMenuManagerState();
}

class Mail2BoondMenuManagerState extends State<Mail2BoondMenuManager> {
  final Logger _log = Logger('Mail2BoondMenuManager');

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
        entryCode: _Mail2BoondMenuEvent.about,
        label: "About",
        icon: Icon(Icons.info, color: Colors.black)));

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
      case _Mail2BoondMenuEvent.about:
        Navigator.of(this.context).pushNamed(AboutPage.route);
        break;
      default:
        throw UnimplementedError();
    }
  }
}
