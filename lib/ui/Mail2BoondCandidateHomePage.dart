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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../business/MailNavigatorBloc.dart';
import 'Mail2BoondMenuManager.dart';
import 'email/MailNavigatorPanel.dart';
import 'candidate/BoondCandidatePanel.dart';
import '../business/BoondCandidateBloc.dart';

import 'Mail2BoondCandidateAppBar.dart';
import 'Mail2BoondSettings.dart';

class Mail2BoondCandidateHomePage extends StatefulWidget {
  static String route = "/";

  final String title;

  const Mail2BoondCandidateHomePage({Key key, this.title}) : super(key: key);

  @override
  _Mail2BoondCandidateHomePageState createState() =>
      _Mail2BoondCandidateHomePageState();
}

class _Mail2BoondCandidateHomePageState
    extends State<Mail2BoondCandidateHomePage> {
  final MailNavigatorBloc mailBloc = MailNavigatorBloc();
  final BoondCandidateBloc candidBloc = BoondCandidateBloc();

  @override
  void dispose() {
    super.dispose();

    mailBloc.close();
    candidBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    Mail2BoondSettings();

    return MultiBlocProvider(
        providers: [
          BlocProvider<MailNavigatorBloc>(create: (BuildContext c) => mailBloc),
          BlocProvider<BoondCandidateBloc>(
              create: (BuildContext c) => candidBloc),
        ],
        child: Scaffold(
          appBar: Mail2BoondCandidateAppBar(widget.title),
          drawer: Drawer(child: Mail2BoondMenuManager()),
          body: Row(children: <Widget>[
            Flexible(flex: 1, fit: FlexFit.tight, child: MailNavigatorPanel()),
            Flexible(flex: 1, fit: FlexFit.tight, child: BoondCandidatePanel())
          ]),
        ));
  }
}
