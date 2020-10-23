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

import 'package:intl/intl.dart' as Intl;
import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/MailNavigatorBloc.dart';
import '../../entity/MailNavigatorMessage.dart';
import '../../business/MailUIState.dart';
import '../../business/MailUIEvent.dart';

class MailListItem extends StatefulWidget {
  static final _log = Logger('MailListItem');

  final String msgId;

  MailListItem({Key key, @required this.msgId}) : super(key: key) {
    //_log.level = Level.FINE;
  }

  @override
  _MailListItemState createState() => _MailListItemState();
}

class _MailListItemState extends State<MailListItem> {
  static final _log = Logger('MailListItem');

  static final ListTile waitWidget = ListTile(title: Text("loading ..."));
  String get myMessageId => widget.msgId;
  bool get isInitialized => (this.paintedWidget != waitWidget);

  Widget paintedWidget = waitWidget;

  @override
  void initState() {
    super.initState();
  }

  bool _isThisMyHeader(MailUIState s) {
    return (s is MailUIStateHeaderLoaded) && (s.message.id == this.myMessageId);
  }

  Widget _buildFinalWidget(BuildContext c, MailUIStateHeaderLoaded state) {
    MailNavigatorMessage msg = state.message;

    final Intl.DateFormat parser = Intl.DateFormat("[d-MMM hh:mm]");

    MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(c);
    String dateStr = "";

    if (msg.date != null) dateStr = parser.format(msg.date);

    this.paintedWidget = Draggable<MailNavigatorMessage>(
      data: msg,
      maxSimultaneousDrags: 1,
      feedback: Text("${msg.from}"),
      child: ListTile(
          enabled: true,
          dense: true,
          title: Text("$dateStr ${msg.from}"),
          onTap: () {
            _log.fine("[_mailItemBuilder] select $myMessageId entry");
            mailBloc.add(MailUIEventMessageContentRequest(msgId: myMessageId));
          },
          subtitle: Text("${msg.subject}")),
    );

    return this.paintedWidget;
  }

  @override
  Widget build(BuildContext _context) {
    return BlocBuilder<MailNavigatorBloc, MailUIState>(
        //bloc: BlocProvider.of<MailNavigatorBloc>(_context),
        buildWhen: (MailUIState previousState, MailUIState state) {
      _log.fine(
          " [buildWhen] got a status condition ${state.runtimeType.toString()} / ${this.isInitialized}");
      if (!this.isInitialized) return true;
      _log.fine(
          " [builder] got a status condition is my ${this._isThisMyHeader(state)} iam ${this.myMessageId}");
      return this._isThisMyHeader(state);
    }, builder: (BuildContext c, MailUIState s) {
      _log.fine(
          " [builder] got a status condition ${s.runtimeType.toString()} iam ${this.myMessageId}");

      if (this._isThisMyHeader(s)) return this._buildFinalWidget(c, s);

      MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(c);
      if (!this.isInitialized) {
        _log.fine(" [builder] push request for ${this.myMessageId}");
        mailBloc.add(MailUIEventMessageHeaderRequest(msgId: this.myMessageId));
      }
      return this.paintedWidget;
    });
  }
}
