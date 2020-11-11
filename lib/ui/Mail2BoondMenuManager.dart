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

import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import '../widget/BoondAuthBrowser.dart';

import 'AboutPage.dart';
import 'Mail2BoondSettings.dart';

class Mail2BoondMenuManager extends StatelessWidget {
  static final _log = Logger("Mail2BoondMenuManager");

  const Mail2BoondMenuManager() : super();

  List<ListTile> _buildMenuItems(BuildContext c) {
    List<ListTile> menuList = new List<ListTile>();
    _log.fine("[buildMenu] start");

    menuList.add(ListTile(
        title: Settings().onStringChanged(
            settingKey: BoondAuthBrowser.BOONDUSER_SETTINGS_KEY,
            defaultValue: '',
            childBuilder: (BuildContext context, String value) => Text(
                  value,
                  textAlign: TextAlign.left,
                ))));

    menuList.add(ListTile(
        leading: Icon(Icons.settings, color: Colors.black),
        title: Text("Settings"),
        onTap: () => Mail2BoondSettings.mainSettings.show(c)));

    menuList.add(ListTile(
        leading: Icon(Icons.info, color: Colors.black),
        title: Text("About"),
        onTap: () => Navigator.of(c).pushNamed(AboutPage.route)));

    _log.fine("[buildMenu] done");

    return menuList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _buildMenuItems(context),
    );
  }
}
