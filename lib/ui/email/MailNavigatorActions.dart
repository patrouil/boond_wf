/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/notification.dart';
import '../../widget/ConnectButton.dart';

import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateBloc.dart';

import '../../business/MailNavigatorBloc.dart';
import '../../entity/MailNavigatorMessage.dart';
import '../../business/MailUIEvent.dart';
import '../../business/MailUIState.dart';

class MailNavigatorActions extends StatefulWidget {
  /// Default Constructor
  MailNavigatorActions() : super();

  @override
  State<StatefulWidget> createState() => _MailNavigatorActionsState();
}

class _MailNavigatorActionsState extends State<MailNavigatorActions> {
  static final Logger _log = Logger("MailNavigatorActions");

  MailNavigatorMessage dispMessage;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext c) {
    return ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [_trashButton(c), _archiveButton(c), _connectButton(c)],
          ),
          ButtonBar(
              alignment: MainAxisAlignment.end, children: [_transfertButton(c)])
        ]);
  }

  Widget _trashButton(BuildContext c) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: _onTrashAction,
      tooltip: "Trash message",
    );
  }

  Widget _archiveButton(BuildContext c) {
    return IconButton(
      icon: Icon(Icons.archive),
      onPressed: null,
      tooltip: "Archive message",
    );
  }

  void _raiseNotification(MailUIState s) {
    if (s is MailUIStateWarning)
      NotificationWrapper.showWarningNotification(s.warningMessage);
    else if (s is MailUIStateInfo && s.infoMessage != null)
      NotificationWrapper.showInfoNotification(s.infoMessage);
  }

  Widget _connectButton(BuildContext c) {
    Widget w = BlocBuilder<MailNavigatorBloc, MailUIState>(
      //bloc: BlocProvider.of<MailNavigatorBloc>(c),
      buildWhen: (MailUIState previousState, MailUIState state) {
        final List<Type> criteria = [
          MailUIStateConnected().runtimeType,
          MailUIStateDisconnected().runtimeType,
        ];
        // special feature. Raise a notification for each message present in the state.
        // not need to put notification somewhere else.
        _raiseNotification(state);
        // keep trace of loaded message to apply future actions.
        if (state is MailUIStateMessageLoaded)
          dispMessage = state.message;
        else if (state is MailUIStateDisconnected) dispMessage = null;

        _log.fine(
            "[_connectButton] got a status condition ${state.runtimeType.toString()}");
        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext _context, MailUIState s) {
        _log.fine("[_connectButton] button builder");
        return ConnectButton(
          icon: Icon(Icons.email),
          isConnected: () {
            MailNavigatorBloc mailBloc =
                BlocProvider.of<MailNavigatorBloc>(_context);
            return mailBloc.isConnected();
          },
          onConnect: _onConnectButton,
        );
      },
    );
    return w;
  }

  Widget _transfertButton(BuildContext c) {
    return IconButton(
      icon: Icon(Icons.g_translate),
      onPressed: _onTransfertAction,
      tooltip: "... is a Boond Candidate",
    );
  }

  void _onConnectButton() {
    MailNavigatorBloc mailBloc =
        BlocProvider.of<MailNavigatorBloc>(this.context);
    _log.fine(" [_onConnectButton] connect button");

    mailBloc.add(MailUIEventConnectRequest());
  }

  void _onTrashAction() {
    MailNavigatorBloc mailBloc =
        BlocProvider.of<MailNavigatorBloc>(this.context);
    assert(mailBloc != null);

    if (dispMessage != null) {
      _log.fine(
          " [_onTrashAction] delete  button for $dispMessage / ${dispMessage?.id}");
      mailBloc.add(MailUIEventDeleteRequest(msgId: dispMessage.id));
    }
  }

  ///
  /// Map mime type with a fancy Icon.
  ///

  void _onTransfertAction() {
    BoondCandidateBloc boondBloc =
        BlocProvider.of<BoondCandidateBloc>(this.context);

    if (this.dispMessage == null) return;
    _log.fine(
        " [_onTransfertAction] merge with a Boond item  $dispMessage / ${dispMessage?.id}");
    boondBloc
        .add(new BoondCandidateUIEventMerge(messageToMerge: this.dispMessage));
  }
}
