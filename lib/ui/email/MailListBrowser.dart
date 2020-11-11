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

import 'package:quiver/cache.dart' as QuiverCache;

import '../../business/MailNavigatorBloc.dart';
import '../../business/MailUIState.dart';
import '../../business/MailUIEvent.dart';
import '../../entity/MailNavigatorMessage.dart';

import 'MaiListItem.dart';

class MailListBrowser extends StatefulWidget {
  static final Logger _log = Logger('MailListBrowser');

  const MailListBrowser({Key key}) : super(key: key);

  @override
  _MailListBrowserState createState() => _MailListBrowserState();
}

class _MailListBrowserState extends State<MailListBrowser> {
  static final Logger _log = Logger('MailListBrowser');

  static final ListTile notConnectedWidget =
      ListTile(title: Text("connect to your GMail first"));

  List<String> messageIdList;
  Map<String, MailNavigatorMessage> mailCache;

  @override
  void initState() {
    super.initState();
    this._purgeCache();
  }

  @override
  void dispose() {
    super.dispose();
    this._purgeCache();
  }

  void _purgeCache() {
    this.mailCache = Map<String, MailNavigatorMessage>();
  }

  @override
  Widget build(BuildContext context) {
    BlocBuilder msgList = BlocBuilder<MailNavigatorBloc, MailUIState>(
        buildWhen: (MailUIState previousState, MailUIState state) {
      final List<Type> criteria = [
        MailUIStateConnected(infoMessage: null).runtimeType,
        MailUIStateDisconnected(infoMessage: null).runtimeType,
        MailUIStateInboxListLoaded(messageIdList: null).runtimeType,
        MailUIStateHeaderLoaded(message: null).runtimeType,
        MailUIStateMessageDeleted(messageIdList: null).runtimeType,
      ];
      _log.fine(
          "[buildWhen] got a status condition ${state.runtimeType.toString()}");

      if ((state is MailUIStateInboxListLoaded)) {
        this.messageIdList = state.messageIdList;
        this._purgeCache();
      }
      //
      else if ((state is MailUIStateMessageDeleted)) {
        for (String id in state.messageIdList) {
          _log.fine("[builder] list builder remove $id");
          this.messageIdList.remove(id);
        }
      }
      //
      else if (state is MailUIStateDisconnected) {
        this.messageIdList = null;
        this._purgeCache();
      }
      //
      else if (state is MailUIStateHeaderLoaded) {
        MailNavigatorMessage msg = state.message;
        this.mailCache[msg.id] = msg;
      }

      return criteria.contains(state.runtimeType);
    }, //
        builder: (BuildContext _context, MailUIState state) {
      _log.fine("[builder] list builder ${this.messageIdList?.length} <");
      MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(_context);

      if (state is MailUIStateConnected) {
        // once connected trigger a mail list claim.
        mailBloc.add(MailUIEventInboxListRequest());
      }
      return ListView.builder(
          reverse: true,
          primary: false,
          scrollDirection: Axis.vertical,
          itemCount: this.messageIdList?.length ?? 1,
          itemBuilder: (BuildContext c, int idx) {
            return _mailItemBuilder(c, idx);
          });
    }); //;

    return msgList;
  }

  Widget _mailItemBuilder(BuildContext c, int entryIndex) {
    if (this.messageIdList == null) return notConnectedWidget;

    String msgId = this.messageIdList[entryIndex];
    _log.fine("[_mailItemBuilder] entry ${entryIndex} / $msgId");
    MailNavigatorMessage msg = mailCache[msgId];
    MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(c);

    if (msg == null) {
      // claim add to cache.
      mailBloc.add(MailUIEventMessageHeaderRequest(msgId: msgId));
    }
    return MailListItem(mailHeader: msg);
  }
}
