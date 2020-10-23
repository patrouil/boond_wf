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

import 'package:boond_wf/entity/BoondAction.dart';
import 'package:meta/meta.dart';
import 'package:boond_api/boond_api.dart' as boond
    show CandidateGet, CandidateSearch;

abstract class BoondCandidateUIState {
  const BoondCandidateUIState();
}

class BoondCandidateUIStateDisconnected extends BoondCandidateUIState {}

class BoondCandidateUIStateInfo extends BoondCandidateUIState {
  final String infoMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateInfo &&
          runtimeType == other.runtimeType &&
          infoMessage == other.infoMessage;

  @override
  int get hashCode => infoMessage.hashCode;

  const BoondCandidateUIStateInfo({@required this.infoMessage});
}

class BoondCandidateUIStateWarning extends BoondCandidateUIState {
  final String warningMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateWarning &&
          runtimeType == other.runtimeType &&
          warningMessage == other.warningMessage;

  @override
  int get hashCode => warningMessage.hashCode;

  const BoondCandidateUIStateWarning({@required this.warningMessage});
}

class BoondCandidateUIStateConnected extends BoondCandidateUIStateInfo {
  const BoondCandidateUIStateConnected({@required infoMessage})
      : super(infoMessage: infoMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateConnected &&
          runtimeType == other.runtimeType &&
          infoMessage == other.infoMessage;

  @override
  int get hashCode => super.hashCode;
}

class BoondCandidateUIStateLookupDone extends BoondCandidateUIState {
  final boond.CandidateSearch candidateFound;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateLookupDone &&
          runtimeType == other.runtimeType &&
          candidateFound == other.candidateFound;

  @override
  int get hashCode => candidateFound.hashCode;

  const BoondCandidateUIStateLookupDone({@required this.candidateFound});
}

class BoondCandidateUIStateLoaded extends BoondCandidateUIState {
  final boond.CandidateGet candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateSaved &&
          runtimeType == other.runtimeType &&
          candidate == other.candidate;

  @override
  int get hashCode => candidate.hashCode;

  const BoondCandidateUIStateLoaded({@required this.candidate});
}

class BoondCandidateUIStateModified extends BoondCandidateUIState {}

class BoondCandidateUIStateSaved extends BoondCandidateUIState {
  final boond.CandidateGet candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateSaved &&
          runtimeType == other.runtimeType &&
          candidate == other.candidate;

  @override
  int get hashCode => candidate.hashCode;

  const BoondCandidateUIStateSaved({@required this.candidate});
}

class BoondCandidateUIStateMergeSender extends BoondCandidateUIState {
  final String senderFullName;
  final String senderEmail;

  BoondCandidateUIStateMergeSender(
      {@required this.senderFullName, @required this.senderEmail});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateMergeSender &&
          runtimeType == other.runtimeType &&
          senderEmail == other.senderEmail;

  @override
  int get hashCode => senderEmail.hashCode;
}

class BoondCandidateUIStateMergeAction extends BoondCandidateUIState {
  final BoondAction actionMessage;

  BoondCandidateUIStateMergeAction({@required this.actionMessage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateMergeAction &&
          runtimeType == other.runtimeType &&
          actionMessage == other.actionMessage;

  @override
  int get hashCode => actionMessage.hashCode;
}
/*
class BoondCandidateUIStateMergeFiles extends BoondCandidateUIState {
  final List<MailNavigatorMessagePart> attachments;

  BoondCandidateUIStateMergeFiles({@required this.attachments});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondCandidateUIStateMergeFiles &&
          runtimeType == other.runtimeType &&
          attachments == other.attachments;

  @override
  int get hashCode => attachments.hashCode;
}


 */
