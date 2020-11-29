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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold, AppBar;

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static String route = "/about";

  const AboutPage() : super();

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static final Logger _log = Logger('AboutPage');

  static String _content;

  @override
  void dispose() {
    super.dispose();
  }

  String _loadAboutText(BuildContext c) {
    if (_content == null) {
      DefaultAssetBundle.of(c).loadString('README.md').then((value) {
        setState(() => _content = value);
      }).catchError(() => _log.fine("[loadAsset] load error"));
    }
    _log.fine("[loadAsset] end of load");

    return _content ?? "";
  }

  @override
  Widget build(BuildContext context) {
    _log.fine("[build] start");

    String data = this._loadAboutText(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Center(
          child:
              //Text("hello world"),
              Markdown(
        selectable: true,
        data: data,
        onTapLink: (String text, String href, String title) async {
          _log.fine("[onTapLink] opening $href");

          if (await canLaunch(href)) {
            await launch(href);
          }
        },
      )),
    );
  }
}
