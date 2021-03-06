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

abstract class MailUIEvent {
  const MailUIEvent();
}

class MailUIEventConnectRequest extends MailUIEvent {}

class MailUIEventDisconnectRequest extends MailUIEvent {}

class MailUIEventInboxListRequest extends MailUIEvent {}

class MailUIEventDeleteRequest extends MailUIEvent {
  final String msgId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIEventDeleteRequest &&
          runtimeType == other.runtimeType &&
          msgId == other.msgId;

  @override
  int get hashCode => msgId.hashCode;

  const MailUIEventDeleteRequest(
      {@required this.msgId}); // used with messageHeader messageContent

}

class MailUIEventMessageHeaderRequest extends MailUIEvent {
  final String msgId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIEventMessageHeaderRequest &&
          runtimeType == other.runtimeType &&
          msgId == other.msgId;

  @override
  int get hashCode => msgId.hashCode;

  const MailUIEventMessageHeaderRequest({@required this.msgId});
}

class MailUIEventWarning extends MailUIEvent {
  final String warningMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIEventWarning &&
          runtimeType == other.runtimeType &&
          warningMessage == other.warningMessage;

  @override
  int get hashCode => warningMessage.hashCode;

  const MailUIEventWarning(
      {@required this.warningMessage}); // used with warning

}

class MailUIEventMessageContentRequest extends MailUIEvent {
  final String msgId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIEventMessageContentRequest &&
          runtimeType == other.runtimeType &&
          msgId == other.msgId;

  @override
  int get hashCode => msgId.hashCode;

  const MailUIEventMessageContentRequest({@required this.msgId});
}
