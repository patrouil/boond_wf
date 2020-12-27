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

import 'package:boond_api/boond_api.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import 'package:boond_api/net/BoondAuth.dart';

class BoondAuthBrowser {
  static final Logger log = Logger("BoondAuthBrowser");

  static const BOONDUSER_SETTINGS_KEY = "BoondAuthBrowser.login.user";
  static const BOONDUSERTOKEN_SETTINGS_KEY = "BoondAuthBrowser.token.user";

  static Future<BoondApi> clientViaUserConsent(
      {bool immediate = false,
      @required BuildContext context,
      String clientToken,
      String clientKey,
      @required String boondHost,
      Level level = Level.OFF}) async {
    return showDialog<BoondApi>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext c) {
          return _BoondAuthUI(clientToken, clientKey, boondHost);
        });
  }

  static void forgetUserConsent() {
    Settings().save(BOONDUSERTOKEN_SETTINGS_KEY, "");
  }
}

class _BoondAuthUI extends StatefulWidget {
  final String clientToken;
  final String clientKey;
  final String boondHost;

  _BoondAuthUI(
      String this.clientToken, String this.clientKey, String this.boondHost)
      : super();

  @override
  State<StatefulWidget> createState() => _BoondAuthUIState();
}

class _BoondAuthUIState extends State<_BoondAuthUI> {
  final TextStyle style =
      const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  TextField emailField;
  TextField passwordField;
  Text messageField;

  String userToken;

  _BoondAuthUIState() : super() {
    this.emailField = TextField(
      obscureText: false,
      controller: TextEditingController(),
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Boond user identifier",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    this.passwordField = TextField(
      obscureText: true,
      style: style,
      controller: TextEditingController(),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Boond password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    this.messageField = Text("");
  }
  @override
  void initState() {
    super.initState();
    _attemptAutoConnect();
  }

  void set warningMessage(String s) {
    final TextStyle warningStyle = this.style.copyWith(color: Colors.red);
    setState(() {
      this.messageField = Text(s, style: warningStyle);
    });
  }

  void set infoMessage(String s) {
    final TextStyle infoStyle = this.style.copyWith(color: Colors.black);
    setState(() {
      this.messageField = Text(s, style: infoStyle);
    });
  }

  void _onLoginPressed() async {
    String emailValue = this.emailField.controller.text;
    String passwordValue = this.passwordField.controller.text;

    // this.infoMessage = "login action ${emailValue} / ${passwordValue}";
    if (emailValue == null) {
      this.warningMessage = "please enter your Boond user identifier";
      return;
    }
    try {
      BoondAuthBrowser.log.fine(
          "[_onLoginPressed] trying boond session for $emailValue / $passwordValue");

      http.Client returnClient = BoondAuth.basicAuth(
          user: emailValue,
          password: passwordValue,
          traceLevel: BoondAuthBrowser.log.level);
      if (returnClient == null) {
        this.warningMessage = "invalid login or password";
        return;
      }
      BoondApi p = BoondApi(returnClient, this.widget.boondHost);
      BoondAuthBrowser.log
          .fine("[_onLoginPressed] trying boond session api $p");

      if (p == null) {
        this.warningMessage = "unable to connect to Boond manager";
        return;
      }
      p.currentuser.get().then((AppCurrentUserGet cu) {
        if (cu == null) {
          this.warningMessage =
              "identification error please check login/password";
          return;
        }
        BoondAuthBrowser.log.fine("[_onLoginPressed] did find user ");

        this.userToken = cu.data.attributes.userToken;
        Settings().save(BoondAuthBrowser.BOONDUSER_SETTINGS_KEY, emailValue);
        Settings()
            .save(BoondAuthBrowser.BOONDUSERTOKEN_SETTINGS_KEY, this.userToken);

        // close dialog and return api session
        Navigator.pop(this.context, p);
      }).catchError((e) {
        BoondAuthBrowser.log.fine(
            "[_onLoginPressed] got a future error (${e.runtimeType.toString()}): ${e.toString()}");

        this.warningMessage =
            "unable to load user '$emailValue' from Boond workspace";
        return null;
      });
    } catch (e) {
      this.warningMessage = e.toString();
    }
  }

  void _onCancelPressed() {
    Navigator.pop(this.context, null);
  }

  Widget _actionButton(Color btnColor, String label, BuildContext context,
      void Function() pressCallback) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: btnColor,
      child: SimpleDialogOption(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: pressCallback,
        child: Text(label,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<BoondApi> _attemptAutoConnect() async {
    // upload settings
    this.emailField.controller.text = await Settings()
        .getString(BoondAuthBrowser.BOONDUSER_SETTINGS_KEY, null);

    this.userToken = await Settings()
        .getString(BoondAuthBrowser.BOONDUSERTOKEN_SETTINGS_KEY, null);

    if (this.widget.clientKey == null || this.widget.clientToken == null) {
      BoondAuthBrowser.log
          .fine("[_attemptAutoConnect] null client key/client tokent");

      return null;
    }

    BoondAuthBrowser.log.fine("[_attemptAutoConnect] start auto connect");
    if (this.userToken == null || this.userToken == "") {
      BoondAuthBrowser.log.fine("[_attemptAutoConnect]  null user token");

      return null;
    }

    http.Client c = BoondAuth.clientTokenAuth(
        clientToken: this.widget.clientToken,
        userToken: this.userToken,
        clientKey: this.widget.clientKey);
    if (c == null) {
      BoondAuthBrowser.log
          .fine("[_attemptAutoConnect] no http session created.");
      return null;
    }

    this.infoMessage = "autoconnect with token ${this.userToken}";

    BoondApi p = BoondApi(c, this.widget.boondHost);
    BoondAuthBrowser.log.fine("[_attemptAutoConnect] launch future user get");

    try {
      AppCurrentUserGet cu = await p.currentuser.get();
      if (cu == null) {
        BoondAuthBrowser.log.fine("[_attemptAutoConnect] no current user ");

        return null;
      }
      BoondAuthBrowser.log.fine("[_attemptAutoConnect] did find user ");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(this.context, p);
      });
    } catch (e) {
      BoondAuthBrowser.log.fine(
          "[_attemptAutoConnect] got a future error (${e.runtimeType.toString()}): ${e.toString()}");
      this.infoMessage = "";
      return null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loginActions = Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _actionButton(Colors.amber, "Login", context, _onLoginPressed),
      SizedBox(width: 45.0),
      _actionButton(Colors.grey, "Cancel", context, _onCancelPressed)
    ]));
    BoondAuthBrowser.log.fine("[build] begin");

    return SimpleDialog(
        title: const Text(
          'Boondmanager Login',
          textAlign: TextAlign.center,
        ),
        elevation: 5,
        children: [
          Container(
            padding: const EdgeInsets.all(36.0),
            constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height * 0.9),
            //height: MediaQuery.of(context).size.height * 0.9,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                  child: Image.asset(
                    "boond-icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(height: 35.0),
                loginActions,
                SizedBox(height: 25.0),
                this.messageField
              ],
            ),
          ),
        ]);
  }
}
