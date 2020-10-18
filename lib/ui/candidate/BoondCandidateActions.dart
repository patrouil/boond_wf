/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_wf/business/BoondCandidateUIEvent.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider;
import 'package:url_launcher/url_launcher.dart';
import 'package:boond_api/boond_api.dart' as boond show CandidateGet;

import '../../widget/notification.dart';
import '../../widget/ConnectButton.dart';
import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIState.dart';

class BoondCandidateActions extends StatefulWidget {
  /// Default Constructor
  BoondCandidateActions() : super();

  @override
  State<StatefulWidget> createState() => _BoondCandidateActionsState();
}

class _BoondCandidateActionsState extends State<BoondCandidateActions> {
  static final Logger _log = Logger("BoondCandidateActions");

  bool isSaveRequired = false;

  @override
  initState() {
    super.initState();
    //_log.level = Level.FINE;
  }

  @override
  Widget build(BuildContext c) {
    return ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [_connectButton(c)],
          ),
          ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [_openUrlButton(c), _saveButton(c)])
        ]);
  }

  void _raiseNotification(BoondCandidateUIState s) {
    if (s is BoondCandidateUIStateInfo && s.infoMessage != null)
      NotificationWrapper.showInfoNotification(s.infoMessage);
    if (s is BoondCandidateUIStateWarning)
      NotificationWrapper.showWarningNotification(s.warningMessage);
  }

  Widget _connectButton(BuildContext c) {
    Widget w = BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
      buildWhen:
          (BoondCandidateUIState previousState, BoondCandidateUIState state) {
        final List<Type> criteria = [
          BoondCandidateUIStateConnected(infoMessage: null).runtimeType,
          BoondCandidateUIStateDisconnected().runtimeType
        ];
        // special feature. Raise a notification for each message present in the state.
        // not need to put notification somewhere else.
        _log.fine("[_connectButton] condition <${state}>");
        _raiseNotification(state);

        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext c, BoondCandidateUIState s) {
        // dont know why but have to locate the bloc.
        BoondCandidateBloc candidateBloc =
            BlocProvider.of<BoondCandidateBloc>(c);
        return ConnectButton(
          icon: Icon(LineAwesomeIcons.firefox),
          isConnected: () {
            BoondCandidateBloc candidateBloc =
                BlocProvider.of<BoondCandidateBloc>(this.context);
            return candidateBloc.isConnected();
          },
          onConnect: _onConnectAction,
        );
      },
    );
    return w;
  }

  void _onConnectAction() {
    BoondCandidateBloc candidateBloc =
        BlocProvider.of<BoondCandidateBloc>(this.context);
    _log.fine("[_onConnectButton] connect button ${this.context} ");

    if (candidateBloc.isConnected()) {
      candidateBloc.add(BoondCandidateUIEventDisconnectRequest());
    } else
      candidateBloc.connect(this.context);
  }

  Widget _openUrlButton(BuildContext _context) {
    _log.fine("[_openUrlButton] build ");

    return BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
      buildWhen:
          (BoondCandidateUIState previousState, BoondCandidateUIState state) {
        final List<Type> criteria = [
          BoondCandidateUIStateConnected(infoMessage: null).runtimeType,
          BoondCandidateUIStateDisconnected().runtimeType,
          BoondCandidateUIStateLoaded(candidate: null).runtimeType
        ];

        _log.fine("[_openUrlButton] condition <${state}>");

        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext c, BoondCandidateUIState s) {
        // dont know why but have to locate the bloc.
        BoondCandidateBloc candidateBloc =
            BlocProvider.of<BoondCandidateBloc>(c);
        boond.CandidateGet candidate = candidateBloc.editedCandidate;
        _log.fine("[_openUrlButton] build <${candidate}>");

        return ConnectButton(
          icon: Icon(Icons.open_in_browser),
          onConnect: () async {
            _onOpenUrlAction(candidateBloc, candidate);
          },
          isConnected: () => (candidate?.data?.id != null),
          tooltip: "View Candidate",
        );
      },
    );
  }

  void _onOpenUrlAction(
      BoondCandidateBloc candidateBloc, boond.CandidateGet candidate) async {
    String url = candidateBloc.model.getCandidateUrl(candidate);
    _log.fine("[_onOpenUrlAction] opening $url");

    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _saveButton(BuildContext c) {
    Widget w = BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
      // bloc: BlocProvider.of<BoondCandidateBloc>(c),
      buildWhen:
          (BoondCandidateUIState previousState, BoondCandidateUIState state) {
        final List<Type> criteria = [
          BoondCandidateUIStateModified().runtimeType,
          BoondCandidateUIStateDisconnected().runtimeType,
          BoondCandidateUIStateSaved(candidate: null).runtimeType,
          BoondCandidateUIStateLoaded(candidate: null).runtimeType
        ];

        // special feature. Raise a notification for each message present in the state.
        // not need to put notification somewhere else.
        _log.fine(
            "[_saveButton] condition <${state.toString()}> , in ${criteria.contains(state.runtimeType)}");

        this.isSaveRequired =
            (state.runtimeType == BoondCandidateUIStateModified().runtimeType);

        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext c, BoondCandidateUIState s) {
        // dont know why but have to locate the bloc.
        BoondCandidateBloc candidateBloc =
            BlocProvider.of<BoondCandidateBloc>(c);
        boond.CandidateGet candidate = candidateBloc.editedCandidate;
        _log.fine("[_saveButton] build <${candidate}>");

        return ConnectButton(
          icon: Icon(Icons.save),
          onConnect: _onSaveAction,
          isConnected: () => (this.isSaveRequired),
          tooltip: "Save Candidate",
        );
      },
    );
    return w;
  }

  void _onSaveAction() {
    BoondCandidateBloc candidateBloc =
        BlocProvider.of<BoondCandidateBloc>(this.context);
    assert(candidateBloc.editedCandidate != null);
    candidateBloc.add(BoondCandidateUIEventSaveRequest(
        candidate: candidateBloc.editedCandidate));
  }
}
