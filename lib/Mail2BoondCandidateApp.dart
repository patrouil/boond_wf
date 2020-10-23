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

import 'package:boond_wf/ui/AboutPage.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'ui/Mail2BoondCandidateHomePage.dart';

class Mail2BoondCandidateApp extends StatefulWidget {
  final log = Logger('Mail2BoondCandidateApp');

  static String APP_TITLE = 'Boond Candidate Workflow';

  Mail2BoondCandidateApp() : super() {}

  @override
  State<StatefulWidget> createState() => _Mail2BoondCandidateAppState();
}

class _Mail2BoondCandidateAppState extends State<Mail2BoondCandidateApp> {
  final log = Logger('Mail2BoondCandidateApp');

  @override
  Widget build(BuildContext context) {
    this.log.fine("[build]");
    return MaterialApp(
      initialRoute: Mail2BoondCandidateHomePage.route,
      routes: {
        Mail2BoondCandidateHomePage.route: (context) =>
            Mail2BoondCandidateHomePage(
                title: Mail2BoondCandidateApp.APP_TITLE),
        AboutPage.route: (context) => AboutPage(),
      },
      title: 'Boond Candidate Workflow',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
