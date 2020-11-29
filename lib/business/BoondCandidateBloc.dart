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
import 'package:bloc/bloc.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import 'package:boond_api/net/BoondApiError.dart';
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

  ///
  BoondCandidateBloc() : super(BoondCandidateUIStateDisconnected()) {
    //_log.level = Level.FINEST;
  }

  ///
  @override
  Stream<BoondCandidateUIState> mapEventToState(
      BoondCandidateUIEvent event) async* {
    _log.fine(
        "[mapEventToState] event to state is ${event.runtimeType.toString()}");
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
        //
      } else if (event is BoondCandidateUIEventSelectRequest) {
        yield BoondCandidateUIStateSelectRequest(
            listToSelectIn: event.listToSelectIn);
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
      // save candidates data.
      this.editedCandidate =
          await this.model.saveCandidate(this.editedCandidate);
      // at this step the candidate object has an id.
      r.add(BoondCandidateUIStateSaved(candidate: this.editedCandidate));

      _log.fine("[_handleSaveRequest] saving ${this.editedActions}");
      // save action data.
      // get and empty action related to the Candidate.
      boond.ActionsGet actions =
          await this.model.newActions(this.editedCandidate);

      if (actions != null) {
        actions.data.attributes.typeOf = this.editedActions.typeOf;
        BoondSettings.newActionType = this.editedActions.typeOf;

        actions.data.attributes.creationDate = this.editedActions.creationDate;
        actions.data.attributes.text = this.editedActions.bodyText;
      }
      actions = await this.model.saveActions(actions);
      // at the step we have an actions objects with a valid ID.
      // at last post documents related to actions.
      try {
        for (BoondActionAttachment p in this.editedActions.attachments) {
          boond.DocumentsPost postDoc;

          if (await BoondSettings.isActionAttachment) {
            _log.fine("[_handleSaveRequest] attach to action");

            postDoc = boond.DocumentsPost(
                parentId: actions.data.id,
                parentType: actions.data.type,
                filename: p.filename,
                fileContent: p.fileContent,
                fileType: p.fileType);
          } else {
            _log.fine("[_handleSaveRequest] attach to candidate");

            postDoc = boond.DocumentsPost(
                parentId: this.editedCandidate.data.id,
                parentType: 'candidateResume',
                filename: p.filename,
                fileContent: p.fileContent,
                fileType: p.fileType);
          }

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

      // AT THE END CLEAN UP Candidate and ACTION CONTENT
      this.editedCandidate = null;
      this.editedActions = BoondAction();

      r.add(BoondCandidateUIStateModified());
      //
    } on boond.BoondApiError catch (e) {
      String m = e.reasonPhrase;

      r.add(BoondCandidateUIStateWarning(warningMessage: "saving error : $m"));
    }
    return r;
  }

  static final List<String> _validMimeTypes = ["word", "application/pdf"];

  Future<List<BoondCandidateUIState>> _handleMergeRequest(
      BoondCandidateUIEventMerge event) async {
    List<BoondCandidateUIState> r = List<BoondCandidateUIState>();

    // if no current candidate to merge
    // a lookup as not ben done.
    // search for a user with the same email.
    // if not found create an emptu one
    if (this.editedCandidate == null) {
      String s = event.messageToMerge.fromEmail;
      boond.CandidateSearch canLookup = await this
          .model
          .searchCandidates(["keywordsType=emails", "keywords=$s"]);

      if (canLookup.data.isEmpty) {
        this.editedCandidate = await this.model.newCandidate();
        r.add(BoondCandidateUIStateInfo(infoMessage: "new candidate creation"));
      } else {
        this.editedCandidate =
            await this.model.getCandidate(canLookup.data.first.id);
        r.add(BoondCandidateUIStateInfo(
            infoMessage:
                "found ${canLookup.data.length} matching candidate(s)"));
      }
    }
    // notify a new candidate loaded.
    r.add(BoondCandidateUIStateMergeSender(
        senderFullName: event.messageToMerge.fromFullName,
        senderEmail: event.messageToMerge.fromEmail));

    // make a new action fro the email.
    this.editedActions =
        BoondAction.fromMailNavigatorMessage(event.messageToMerge);
    this.editedActions.typeOf =
        await Settings().getInt(BoondSettings.BoondDefaultActionTypeOfKey, 0);
    this.editedActions.filterMimeType(_validMimeTypes);
    // notify of this new action.
    r.add(new BoondCandidateUIStateMergeAction(
        actionMessage: this.editedActions));

    return r;
  }

  Future<boond.CandidateSearch> searchByEmailAndName(
      List<List<String>> criteriaSet) async {
    boond.CandidateSearch sumList = null;

    for (List<String> e in criteriaSet) {
      _log.fine("[_handleSearchRequest] look for ${e.toString()}");

      boond.CandidateSearch s = await this.model.searchCandidates(e);
      _log.fine("[_handleSearchRequest] got ${s.data.length}");

      if (sumList == null)
        sumList = s;
      else
        sumList.data.addAll(s.data);
    }
    return sumList;
  }

  Future<List<BoondCandidateUIState>> _handleSearchRequest(
      BoondCandidateUIEventLookupRequest event) async {
    List<BoondCandidateUIState> r = List<BoondCandidateUIState>();

    boond.CandidateSearch sumList =
        await this.searchByEmailAndName(event.criteria);

    _log.fine(
        "[_handleSearchRequest] final result is ${sumList?.data?.length}");

    this.editedCandidate = null;
    if ((sumList == null) || sumList.data.isEmpty) {
      r.add(BoondCandidateUIStateInfo(infoMessage: "no candidate found"));
      r.add(BoondCandidateUIStateLoaded(candidate: null));
    }
    // load the first one.
    else if (sumList.data.length == 1) {
      r.add(BoondCandidateUIStateInfo(
          infoMessage: "found ${sumList.data.length} candidates"));
      // pas beau doit faire appel direcrement a la fonction de search
      this.add(
          BoondCandidateUIEventLoadRequest(candidateId: sumList.data.first.id));
    } else {
      r.add(BoondCandidateUIStateSelectRequest(listToSelectIn: sumList));
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
