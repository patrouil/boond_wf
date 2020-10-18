/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

import 'MailNavigatorMessage.dart';

class BoondActionAttachment {
  final String filename;
  final Uint8List fileContent;
  final MediaType fileType;

  BoondActionAttachment(this.filename, this.fileContent, this.fileType);

  factory BoondActionAttachment.fromMailNavigatorMessagePart(
          MailNavigatorMessagePart p) =>
      BoondActionAttachment(p.filename, p.binary,
          MediaType(p.contentType.mimeType, p.contentType.subType));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoondActionAttachment &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          fileType == other.fileType;

  @override
  int get hashCode => filename.hashCode ^ fileType.hashCode;
}

class BoondAction {
  String bodyText;
  DateTime creationDate;
  int typeOf;

  List<BoondActionAttachment> attachments = List<BoondActionAttachment>();

  BoondAction({this.bodyText, this.creationDate, this.typeOf = 0});

  factory BoondAction.fromMailNavigatorMessage(MailNavigatorMessage m) {
    BoondAction action = BoondAction(
        bodyText: m?.bodyContentAsText ?? "", creationDate: m?.date);
    if (m != null)
      m.attachements.forEach((element) {
        action.attachments
            .add(BoondActionAttachment.fromMailNavigatorMessagePart(element));
      });

    return action;
  }

  void add(BoondActionAttachment a) => this.attachments.add(a);
}
