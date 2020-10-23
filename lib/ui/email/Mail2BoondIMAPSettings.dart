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
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import '../../widget/settings_widget.dart';

class Mail2BoondIMAPSettings extends ExpansionSettingsTile {
  static final Logger _log = Logger('Mail2BoondIMAPSettings');

  static const String ImapServerNameKey = "mail2boond.imap.server.name";
  static const String ImapServerPortKey = "mail2boond.imap.server.port";

  static const String ImapUserNameKey = "mail2boond.imap.user.name";
  static const String ImapPasswordKey = "mail2boond.imap.password.name";

  Mail2BoondIMAPSettings(titre)
      : super(
          title: titre,
          children: [],
        ) {
    this.children.add(TextFieldSettingsTile(
        settingKey: ImapServerNameKey,
        title: "Server host name : ",
        defaultValue: "hostname.com"));

    this.children.add(TextFieldSettingsTile(
        settingKey: ImapUserNameKey, title: "Login :", defaultValue: "login"));
    this.children.add(TextFieldSettingsTile(
        settingKey: ImapPasswordKey,
        title: "Password :",
        obscureText: true,
        defaultValue: ""));
  }
}
