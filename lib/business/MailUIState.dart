/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:meta/meta.dart';
import '../entity/MailNavigatorMessage.dart';

abstract class MailUIState {
  const MailUIState();
}

class MailUIStateWarning extends MailUIState {
  final String warningMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateWarning &&
          runtimeType == other.runtimeType &&
          warningMessage == other.warningMessage;

  @override
  int get hashCode => warningMessage.hashCode;

  const MailUIStateWarning({@required this.warningMessage}); // with warning

}

class MailUIStateInfo extends MailUIState {
  final String infoMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateInfo &&
          runtimeType == other.runtimeType &&
          infoMessage == other.infoMessage;

  @override
  int get hashCode => infoMessage.hashCode;

  const MailUIStateInfo({@required this.infoMessage}); // with warning

}

class MailUIStateDisconnected extends MailUIStateInfo {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateDisconnected && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  MailUIStateDisconnected({String infoMessage})
      : super(infoMessage: infoMessage);
}

class MailUIStateConnected extends MailUIStateInfo {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateConnected && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  MailUIStateConnected({String infoMessage}) : super(infoMessage: infoMessage);
}

class MailUIStateLoggedIn extends MailUIStateInfo {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateLoggedIn &&
          runtimeType == other.runtimeType &&
          infoMessage == other.infoMessage;

  @override
  int get hashCode => super.hashCode;

  const MailUIStateLoggedIn({String message}) : super(infoMessage: message);
}

class MailUIStateInboxListLoaded extends MailUIStateInfo {
  final List<String> messageIdList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateInboxListLoaded &&
          runtimeType == other.runtimeType &&
          messageIdList == other.messageIdList;

  @override
  int get hashCode => messageIdList.hashCode;

  const MailUIStateInboxListLoaded(
      {@required this.messageIdList, String infoMessage})
      : super(infoMessage: infoMessage); // with messageListLoaded

}

class MailUIStateHeaderLoaded extends MailUIState {
  final MailNavigatorMessage message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateHeaderLoaded &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  const MailUIStateHeaderLoaded({@required this.message});
}

class MailUIStateMessageLoaded extends MailUIState {
  final MailNavigatorMessage message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateMessageLoaded &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  const MailUIStateMessageLoaded({@required this.message});
}

class MailUIStateMessageDeleted extends MailUIState {
  final List<String> messageIdList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailUIStateMessageDeleted &&
          runtimeType == other.runtimeType &&
          messageIdList == other.messageIdList;

  @override
  int get hashCode => messageIdList.hashCode;

  MailUIStateMessageDeleted(
      {@required this.messageIdList}); // with messageListLoaded

}
