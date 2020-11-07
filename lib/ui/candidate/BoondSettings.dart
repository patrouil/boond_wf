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

import 'package:boond_api/net/BoondApi.dart';

import '../../widget/settings_widget.dart';

class BoondSettings extends StatelessWidget {
  static final Logger _log = Logger('BoondSettings');

  static const String BoondServerNameKey = "boond-wf.boond.server.name";

  static const String BoondUserNameKey = "boond-wf.boond.user.name";
  static const String BoondClientKeyKey = "boond-wf.boond.client_key.key";
  static const String BoondClientTokenKey = "boond-wf.boond.client_token.key";
  static const String BoondAttachmentRuleKey =
      "boond-wf.boond.attachmnt.rule.key";

  static const String BoondDefaultActionTypeOfKey =
      "boond-wf.boond.actions.typeOf.key";

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
        SwitchSettingsTile(
          settingKey: BoondAttachmentRuleKey,
          title: ' attachments link rule',
          subtitle: 'link to actions',
          subtitleIfOff: 'link to candidate resume',
          defaultValue: true,
        ),
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

  static Future<String> get clientToken async {
    return await Settings().getString(BoondSettings.BoondClientTokenKey, null);
  }

  static Future<String> get clientKey async {
    return await Settings().getString(BoondSettings.BoondClientKeyKey, null);
  }

  static Future<String> get serverHostName async {
    return await Settings()
        .getString(BoondSettings.BoondServerNameKey, BoondApi.LIVE_HOSTNAME);
  }

  static Future<int> get defaultActionType async {
    return await Settings()
        .getInt(BoondSettings.BoondDefaultActionTypeOfKey, 0);
  }

  static set newActionType(int t) {
    Settings().save(BoondSettings.BoondDefaultActionTypeOfKey, t);
  }

  static Future<bool> get isActionAttachment async {
    return await Settings().getBool(BoondSettings.BoondAttachmentRuleKey, true);
  }
}
