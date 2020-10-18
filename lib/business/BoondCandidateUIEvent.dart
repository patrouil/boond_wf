/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_wf/entity/BoondAction.dart';
import 'package:meta/meta.dart';

import 'package:boond_api/boond_api.dart' as boond show CandidateGet;

import '../entity/MailNavigatorMessage.dart';

abstract class BoondCandidateUIEvent {
  const BoondCandidateUIEvent();
}

class BoondCandidateUIEventDisconnectRequest extends BoondCandidateUIEvent {}

class BoondCandidateUIEventConnectRequest extends BoondCandidateUIEvent {
  final String infoMessage;
  const BoondCandidateUIEventConnectRequest({this.infoMessage});
}

class BoondCandidateUIEventWarning extends BoondCandidateUIEvent {
  final String warningMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIEventWarning &&
          runtimeType == other.runtimeType &&
          warningMessage == other.warningMessage;

  @override
  int get hashCode => warningMessage.hashCode;

  const BoondCandidateUIEventWarning({@required this.warningMessage});
}

class BoondCandidateUIEventLookupRequest extends BoondCandidateUIEvent {
  final List<String> criteria;

  const BoondCandidateUIEventLookupRequest({@required this.criteria});
}

class BoondCandidateUIEventLoadRequest extends BoondCandidateUIEvent {
  final String candidateId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIEventLoadRequest &&
          runtimeType == other.runtimeType &&
          candidateId == other.candidateId;

  @override
  int get hashCode => candidateId.hashCode;

  const BoondCandidateUIEventLoadRequest({@required this.candidateId});
}

class BoondCandidateUIEventEditing extends BoondCandidateUIEvent {
  final boond.CandidateGet candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIEventEditing &&
          runtimeType == other.runtimeType &&
          candidate == other.candidate;

  @override
  int get hashCode => candidate.hashCode;

  const BoondCandidateUIEventEditing({this.candidate});
}

class BoondActionUIEventChanged extends BoondCandidateUIEvent {
  final BoondAction action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondActionUIEventChanged &&
          runtimeType == other.runtimeType &&
          action == other.action;

  @override
  int get hashCode => action.hashCode;

  const BoondActionUIEventChanged({this.action});
}

class BoondCandidateUIEventSaveRequest extends BoondCandidateUIEvent {
  final boond.CandidateGet candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIEventSaveRequest &&
          runtimeType == other.runtimeType &&
          candidate == other.candidate;

  @override
  int get hashCode => candidate.hashCode;

  const BoondCandidateUIEventSaveRequest({@required this.candidate});
}

class BoondCandidateUIEventMerge extends BoondCandidateUIEvent {
  final MailNavigatorMessage messageToMerge;

  BoondCandidateUIEventMerge({@required this.messageToMerge});
}
