/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/MailNavigatorBloc.dart';
import '../../business/MailUIState.dart';
import '../../business/MailUIEvent.dart';

import 'MaiListItem.dart';

class MailListBrowser extends StatefulWidget {
  static final Logger _log = Logger('MailListBrowser');

  MailListBrowser({Key key}) : super(key: key) {
    //_log.level = Level.FINE;
  }

  @override
  _MailListBrowserState createState() => _MailListBrowserState();
}

class _MailListBrowserState extends State<MailListBrowser> {
  static final Logger _log = Logger('MailListBrowser');

  static final ListTile notConnectedWidget =
      ListTile(title: Text("connect to your GMail first"));

  List<String> messageIdList;

  @override
  Widget build(BuildContext context) {
    BlocBuilder msgList = BlocBuilder<MailNavigatorBloc, MailUIState>(
        buildWhen: (MailUIState previousState, MailUIState state) {
      final List<Type> criteria = [
        MailUIStateConnected(infoMessage: null).runtimeType,
        MailUIStateDisconnected(infoMessage: null).runtimeType,
        MailUIStateInboxListLoaded(messageIdList: null).runtimeType,
        MailUIStateMessageDeleted(messageIdList: null).runtimeType,
      ];
      _log.fine(
          "[buildWhen] got a status condition ${state.runtimeType.toString()}");

      if ((state is MailUIStateInboxListLoaded)) {
        this.messageIdList = state.messageIdList;
      } else if ((state is MailUIStateMessageDeleted)) {
        for (String id in state.messageIdList) {
          _log.fine("[builder] list builder remove $id");
          this.messageIdList.remove(id);
        }
      } else if (state is MailUIStateDisconnected) {
        this.messageIdList = null;
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
          scrollDirection: Axis.vertical,
          itemCount: this.messageIdList?.length ?? 1,
          itemBuilder: (BuildContext c, int idx) {
            return _mailItemBuilder(c, idx);
          });
    }); //;

    return msgList;
  }

  Widget _mailItemBuilder(BuildContext c, int entryIndex) {
    _log.fine("[_mailItemBuilder] entry ${entryIndex}");

    if (this.messageIdList == null) return notConnectedWidget;
    MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(c);

    String msgId = this.messageIdList[entryIndex];
    return MailListItem(msgId: msgId);
  }
}
