/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'dart:io';
import 'package:intl/intl.dart' as Intl;
import 'package:logging/logging.dart';
import 'package:googleapis/gmail/v1.dart' as GMail;

import '../entity/MailNavigatorMessage.dart';

class MailNavigatorGoogleMessage extends MailNavigatorMessage {
  String _rfcSubject;
  String _rfcFrom;
  String _rfcTo;
  DateTime _rfcDate;

  final GMail.Message msg;

  List<MailNavigatorMessagePart> _body = List<MailNavigatorMessagePart>();

  List<MailNavigatorMessagePart> _attachements =
      List<MailNavigatorMessagePart>();

  void _addBody(GMail.MessagePart part) {
    msglog.fine(
        "[bodypart] setting body : ${part.mimeType} - ${part.body.size} ");
    MailNavigatorMessagePart m = MailNavigatorMessagePart(
        contentType: ContentType.parse(part.mimeType), content: part.body.data);

    _body.add(m);
  }

  void _addAttachament(GMail.MessagePart part, GMail.MessagePartBody content) {
    msglog.fine(
        "[addPart] adding attachement : ${part.mimeType} ${part.filename} - ${content.size}");
    MailNavigatorMessagePart attach = MailNavigatorMessagePart(
        filename: part.filename,
        contentType: ContentType.parse(part.mimeType),
        content: content.data,
        contentSize: content.size,
        attachmentId: content.attachmentId);

    _attachements.add(attach);
  }

  MailNavigatorGoogleMessage(this.msg) {
    //msglog.level = Level.FINE;
    msglog.fine(
        "[MailNavigatorGoogleMessage] my id is  : ${this.id} - ${this.msg.id}");
    _bindHeader();
    _bindBody();
  }

  void _bindHeader() {
    // Fri, 1 May 2020 01:04:27 +0200
    // Fri, 01 May 2020 06:50:00 +0000 (UTC)
    final List<Intl.DateFormat> parsers = [
      Intl.DateFormat("EEE, d MMM yyyy hh:mm:ss ZZZ", "en_US"),
      Intl.DateFormat("d MMM yyyy hh:mm:ss ZZZ", "en_US")
    ];

    if (msg.payload != null && msg.payload.headers != null) {
      List<GMail.MessagePartHeader> head = msg.payload.headers;
      for (GMail.MessagePartHeader p in head) {
        switch (p.name) {
          case 'Subject':
            _rfcSubject = p.value;
            break;
          case 'From':
            _rfcFrom = p.value;
            break;
          case 'To':
            _rfcTo = p.value;
            break;
          case 'Date':
            // syntax is Fri,  1 May 2020 18:04:22 +0000 (UTC)
            try {
              // remove duplicate spaces for parsing.
              String d = p.value.replaceAll("  ", " ").trim();
              for (Intl.DateFormat parser in parsers) {
                try {
                  _rfcDate = parser.parse(d);
                  break;
                } catch (e) {
                  if (e.runtimeType.toString() != 'FormatException') rethrow;
                  // ignore this FormatException
                  msglog.finest(
                      "[_bindHeader] unable to parse date : ${p.value} - $e");
                }
              }
            } catch (e) {
              msglog.severe(
                  "[_bindHeader] unable to parse date : ${p.value} - $e");
            }
            break;
          default:
          // mailLog.finest(
          //   "[${mailLog.name}:_bind] no binding rule for ${p.name} : ${p.value.substring(0, 30)} ");
        }
      }
    } // end of if
  }

  bool _isBodyPart(GMail.MessagePart p) {
    return ((p.body != null) && (p.body.size > 0) && p.filename.isEmpty);
  }

  bool _isAttachmentPart(GMail.MessagePart p) {
    return ((p.body != null) && (p.body.size > 0) && p.filename.isNotEmpty);
  }

  void _bindSubParts(List<GMail.MessagePart> theParts) {
    for (GMail.MessagePart p in theParts) {
      // GMail.MessagePartBody bodyData;
      // standard body bundled in parts
      if (_isBodyPart(p)) {
        this._addBody(p);
      }
      // handle body parts and subparts.
      else if (p.body != null && p.body.size == 0 && p.parts != null) {
        this._bindSubParts(p.parts);
      }
      // handle an attachment
      else if (_isAttachmentPart(p)) {
        this._addAttachament(p, p.body);
      }
      // neither a body or an attachment
      else {
        msglog.info(
            "[_bindBody] unable to process message part. ${p.toJson().toString()}");
      }
    }
  }

  void _bindBody() {
    if (_isBodyPart(msg.payload)) {
      // this is an immediate body
      this._addBody(msg.payload);
      msglog.fine("[_bindBody] got an included body");
    }

    if (msg.payload.parts != null) {
      this._bindSubParts(msg.payload.parts);
    } // end if parts is null
    // final internal control. At least one body is mandatory
    if (this.bodies.length == 0) {
      String m = msg.toJson().toString();
      throw UnimplementedError("unable to decode bodies : $m");
    }
  }

  @override
  DateTime get date => _rfcDate;

  @override
  String get from => _rfcFrom;

  @override
  // TODO: implement header
  Map<String, String> get header => throw UnimplementedError();

  @override
  String get id => msg.id;

  @override
  String get internaldate => msg.internalDate;

  @override
  String get subject => _rfcSubject;

  @override
  String get to => _rfcTo;

  @override
  List<MailNavigatorMessagePart> get attachements {
    return this._attachements;
  }

  @override
  List<MailNavigatorMessagePart> get bodies {
    return this._body;
  }
}
