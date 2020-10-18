/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_api/net/BoondApiError.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import 'package:bloc/bloc.dart';

import 'package:boond_api/boond_api.dart' as boond;

import '../ui/candidate/BoondSettings.dart' show BoondSettings;

import '../entity/BoondAction.dart';
import '../model/BoondCandidateModel.dart';
import '../business/BoondCandidateUIState.dart';
import 'BoondCandidateUIEvent.dart';

class BoondCandidateBloc
    extends Bloc<BoondCandidateUIEvent, BoondCandidateUIState> {
  static final Logger _log = Logger('BoondCandidateBloc');

  ///
  BoondCandidateModel model = BoondCandidateModel();

  /// Candidate being currently displayed / edited.
  boond.CandidateGet editedCandidate;
  BoondAction editedActions;
  //boond.ActionsAttributes editedActions;
  //List<MailNavigatorMessagePart> attachements;

  ///
  BoondCandidateBloc() : super(BoondCandidateUIStateDisconnected()) {
    _log.level = Level.FINEST;
  }

  ///
  @override
  Stream<BoondCandidateUIState> mapEventToState(
      BoondCandidateUIEvent event) async* {
    _log.fine("[mapEventToState] event to map is ${event.toString()}");
    try {
      //
      if (event is BoondCandidateUIEventConnectRequest) {
        this.editedCandidate = null;
        this.editedActions = null;
        yield BoondCandidateUIStateConnected(infoMessage: event.infoMessage);
        //
      } else if (event is BoondCandidateUIEventDisconnectRequest) {
        this.model.close();
        this.editedCandidate = null;
        this.editedActions = null;

        yield BoondCandidateUIStateDisconnected();
        //
      } else if (event is BoondCandidateUIEventWarning) {
        //this.model.close();
        yield BoondCandidateUIStateWarning(
            warningMessage: event.warningMessage);
        //
      } else if (event is BoondCandidateUIEventLookupRequest) {
        for (BoondCandidateUIState e in await _handleSearchRequest(event))
          yield e;
        //
      } else if (event is BoondCandidateUIEventLoadRequest) {
        this.editedCandidate = await this.model.getCandidate(event.candidateId);
        this.editedActions = null;

        yield BoondCandidateUIStateLoaded(candidate: this.editedCandidate);
        // yield BoondCandidateUIStateModified();
        //
      } else if (event is BoondCandidateUIEventEditing) {
        yield BoondCandidateUIStateModified();
        //
      } else if (event is BoondCandidateUIEventSaveRequest) {
        for (BoondCandidateUIState e in await _handleSaveRequest(event))
          yield e;
        //
      } else if (event is BoondCandidateUIEventMerge) {
        for (BoondCandidateUIState e in await _handleMergeRequest(event))
          yield e;
        //
      } else if (event is BoondActionUIEventChanged) {
        this.editedActions = event.action;

        yield BoondCandidateUIStateModified();
        //
      } else {
        _log.fine("[mapEventToState] unhandled event ${event.toString()}");

        throw UnimplementedError("unhandled event ${event.toString()} ");
      }
    } catch (e) {
      _log.shout("[mapEventToState] error mapping ${e.toString()}");
    }
  }

  Future<List<BoondCandidateUIState>> _handleSaveRequest(
      BoondCandidateUIEventSaveRequest event) async {
    List<BoondCandidateUIState> r = List<BoondCandidateUIState>();

    try {
      _log.fine("[_handleSaveRequest] saving ${this.editedCandidate}");
      this.editedCandidate =
          await this.model.saveCandidate(this.editedCandidate);
// save action

      r.add(BoondCandidateUIStateSaved(candidate: this.editedCandidate));
      // keep result to  get action id for documents.
      _log.fine("[_handleSaveRequest] saving ${this.editedActions}");

      boond.ActionsGet actions =
          await this.model.newActions(this.editedCandidate);
      if (actions != null) {
        actions.data.attributes.typeOf = this.editedActions.typeOf;
        // TODO deplacer cette ligne dans le widget.
        Settings().save(BoondSettings.BoondDefaultActionTypeOfKey,
            this.editedActions.typeOf);

        actions.data.attributes.creationDate = this.editedActions.creationDate;
        actions.data.attributes.text = this.editedActions.bodyText;
      }
      actions = await this.model.saveActions(actions);

      // at last post documents related to actions.
      try {
        for (BoondActionAttachment p in this.editedActions.attachments) {
          boond.DocumentsPost postDoc = boond.DocumentsPost(
              parentId: actions.data.id,
              parentType: actions.data.type,
              filename: p.filename,
              fileContent: p.fileContent,
              fileType: p.fileType);

          await this.model.saveDocument(postDoc);
        }
      } on BoondApiError catch (e) {
        _log.shout("[_handleSaveRequest] saving error {$e.toString()}");

        if (e.statusCode == BoondApiError.STATUS_DENIED)
          r.add(BoondCandidateUIStateWarning(
              warningMessage: "your are not allowed to attach document"));
        else
          rethrow;
      }
      r.add(
          BoondCandidateUIStateInfo(infoMessage: "candidate and action saved"));

      // AT THE END CLEAN UP ACTION CONTENT
      this.editedActions = BoondAction(bodyText: "saved");

      r.add(BoondCandidateUIStateModified());
      //
    } on boond.BoondApiError catch (e) {
      r.add(BoondCandidateUIStateWarning(
          warningMessage: "saving error : ${e.toString()}"));
    }
    return r;
  }

  Future<List<BoondCandidateUIState>> _handleMergeRequest(
      BoondCandidateUIEventMerge event) async {
    List<BoondCandidateUIState> r = List<BoondCandidateUIState>();
    if (this.editedCandidate == null) {
      this.editedCandidate = await this.model.newCandidate();
    }
    r.add(BoondCandidateUIStateMergeSender(
        senderFullName: event.messageToMerge.fromFullName,
        senderEmail: event.messageToMerge.fromEmail));

    this.editedActions =
        BoondAction.fromMailNavigatorMessage(event.messageToMerge);
    this.editedActions.typeOf =
        await Settings().getInt(BoondSettings.BoondDefaultActionTypeOfKey, 0);

    r.add(new BoondCandidateUIStateMergeAction(
        actionMessage: this.editedActions));

    return r;
  }

  Future<List<BoondCandidateUIState>> _handleSearchRequest(
      BoondCandidateUIEventLookupRequest event) async {
    List<BoondCandidateUIState> r = List<BoondCandidateUIState>();

    boond.CandidateSearch s = await this.model.searchCandidates(event.criteria);

    if (s.data.length == 0) {
      r.add(BoondCandidateUIStateInfo(infoMessage: "no candidate found"));
    }
    // load the first one.
    else {
      r.add(BoondCandidateUIStateInfo(
          infoMessage: "found ${s.data.length} candidates"));

      this.add(BoondCandidateUIEventLoadRequest(candidateId: s.data.first.id));
    }
    return r;
  }

  @override
  void add(BoondCandidateUIEvent event) {
    super.add(event);
  }

  bool isConnected() {
    return model.isConnected();
  }

  void connect(BuildContext context) async {
    _log.fine("[connect] begin $context ");
    BoondCandidateUIEvent e;

    if (model.isConnected()) {
      e = BoondCandidateUIEventDisconnectRequest();
      this.add(e);
      return;
    }
    BoondCandidateStatus b = await model.connect(context);
    _log.fine("[connect] model connect response ${b.code} / ${b.message}");

    if (b.code != BoondCandidateModelResponse.ok) {
      e = (BoondCandidateUIEventWarning(warningMessage: b.message));
    } else {
      e = (BoondCandidateUIEventConnectRequest(
          infoMessage: "connected as ${model.fullUserName}"));
    }
    this.add(e);
  }
}
