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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:boond_api/boond_api.dart' as boond;
import '../../entity/MailNavigatorMessage.dart';

import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIState.dart';

class CandidateListBrowser extends StatefulWidget {
  static final Logger _log = Logger('CandidateListBrowser');

  CandidateListBrowser({Key key}) : super(key: key) {
    //_log.level = Level.FINE;
  }

  @override
  _CandidateListBrowserState createState() => _CandidateListBrowserState();
}

class _CandidateListBrowserState extends State<CandidateListBrowser> {
  static final Logger _log = Logger('CandidateListBrowser');

  boond.CandidateSearch candidateList;

  static final ListTile notConnectedWidget =
      ListTile(title: Text("connect to Boond Manager First"));
  static final ListTile emptyListWidget =
      ListTile(title: Text("drag/drop email to search candidate"));

  Widget _buildList(BuildContext c) {
    BlocBuilder candWidget =
        BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
            // bloc: BlocProvider.of<BoondCandidateBloc>(context),
            buildWhen: (BoondCandidateUIState previousState,
                BoondCandidateUIState state) {
      final List<Type> criteria = [
        BoondCandidateUIStateLookupDone(candidateFound: null).runtimeType,
        BoondCandidateUIStateConnected(infoMessage: null).runtimeType,
        BoondCandidateUIStateDisconnected().runtimeType
      ];

      _log.fine(
          " [${_log.name}:build] got a status condition ${state.toString()}");
      return criteria.contains(state.runtimeType);
    }, builder: (BuildContext c, BoondCandidateUIState s) {
      _log.fine(" [${_log.name}:build] list builder");
      BoondCandidateBloc boondBloc = BlocProvider.of<BoondCandidateBloc>(c);

      if ((s is BoondCandidateUIStateLookupDone)) {
        this.candidateList = s.candidateFound;
      } else if (s is BoondCandidateUIStateConnected) {
        // once connected trigger a mail list claim.
        //boondBloc.add(BoondCandidateUIEventLookupRequest(criteria: null));
      } else if (s is BoondCandidateUIStateDisconnected) {
        this.candidateList = null;
      }

      Widget w = ListView.builder(
          reverse: true,
          itemCount:
              (this.candidateList == null || this.candidateList.data == null)
                  ? 1
                  : this.candidateList.data.length,
          itemBuilder: (BuildContext _context, int idx) {
            return _candidateItemBuilder(_context, idx);
          });
      return DragTarget<MailNavigatorMessage>(
        builder: (BuildContext _context,
            List<MailNavigatorMessage> candidateData,
            List<dynamic> rejectedData) {
          return w;
        },
        onAccept: (MailNavigatorMessage data) {
          //String senderName = data.fromFullName;
          _log.fine(" [onAccept] dragdrop accept ${data.from}");
          String senderMail = data.fromEmail;
          _log.fine(" [onAccept] dragdrop accept $senderMail");
          BoondCandidateBloc boondBloc = BlocProvider.of<BoondCandidateBloc>(c);
          if (!boondBloc.isConnected()) {
            boondBloc.add(BoondCandidateUIEventWarning(
                warningMessage: "please connect first"));
            return;
          }
          boondBloc.add(BoondCandidateUIEventLookupRequest(
              criteria: ["keywordsType=emails", "keywords=$senderMail"]));
        },
      );
    }); //;
    return candWidget;
  }

  @override
  Widget build(BuildContext _context) {
    return _buildList(_context);
  }

  Widget _candidateItemBuilder(BuildContext _context, int entryIndex) {
    Widget resultW;

    BoondCandidateBloc boondBloc =
        BlocProvider.of<BoondCandidateBloc>(_context);

    if (!boondBloc.isConnected())
      resultW = notConnectedWidget;
    else if ((this.candidateList == null || this.candidateList.data == null))
      resultW = emptyListWidget;
    else {
      boond.CandidateSearchData data = this.candidateList.data[entryIndex];
      resultW = _candidateListItem(boondBloc, data);
    }
    return resultW;
  }

  Widget _candidateListItem(
      BoondCandidateBloc bloc, boond.CandidateSearchData data) {
    boond.CandidateAttributes attr = data.attributes;

    String user = "${attr.lastName} ${attr.firstName}";
    String email = attr.email1;
    String userId = data.id;

    return ListTile(
        enabled: true,
        dense: true,
        title: Text(user),
        onTap: () {
          _log.fine("[_candidateListItemBuilder] select $userId entry");

          bloc.add(BoondCandidateUIEventLoadRequest(candidateId: userId));
        },
        subtitle: Text(email));
  }
}
