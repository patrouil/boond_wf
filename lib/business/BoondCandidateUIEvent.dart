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

import 'package:meta/meta.dart';

import 'package:boond_api/boond_api.dart' as boond
    show CandidateGet, CandidateSearch;

import '../entity/MailNavigatorMessage.dart';
import '../entity/BoondAction.dart';

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
  /// This a a List of List of criteria pair.
  /// each entry in the first list level leads to a seach process.
  /// as a result, the aggregate of every search is expected.
  final List<List<String>> criteria;

  const BoondCandidateUIEventLookupRequest({@required this.criteria});
}

class BoondCandidateUIEventSelectRequest extends BoondCandidateUIEvent {
  final boond.CandidateSearch listToSelectIn;

  const BoondCandidateUIEventSelectRequest({@required this.listToSelectIn});
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
