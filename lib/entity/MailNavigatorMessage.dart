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
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:html/dom.dart' as dom;
import 'package:logging/logging.dart';

///
/// Generic Email content representation.
/// Inspired form IMAP API.
///
/// To be used by each MavigatorAbstractModel implementation
/// to return specific message content.
///
/// ID
///FLAGS
///INTERNALDATE
///RFC822.SIZE
///HEADER
///ENVELLOPE
///BODY
///HEADERS
///FROM
///SENDER
///REPLY-TO
///TO
///CC
///SUBJECT
///

class MailNavigatorMessagePart {
  Base64Codec BASE64 = const Base64Codec();
  Utf8Codec UTF8 = const Utf8Codec();

  ContentType contentType;
  String filename;

  String attachmentId;

  ///Base64 encoded message part content.
  String content;
  int contentSize;

  ///  decoded content in UTF8.
  String get text => UTF8.decode(BASE64.decode(content));

  /// binary content for files.
  Uint8List get binary => BASE64.decode(content);

  MailNavigatorMessagePart(
      {this.contentType,
      this.content,
      this.filename,
      this.contentSize,
      this.attachmentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailNavigatorMessagePart &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          attachmentId == other.attachmentId;

  @override
  int get hashCode => filename.hashCode ^ attachmentId.hashCode;
}

abstract class MailNavigatorMessage {
  static final Logger _log = Logger('MailNavigatorMessage');
  get msglog => MailNavigatorMessage._log;

  // public attributes to be overridden.
  String get internaldate;
  String get id;
  String get from;
  String get to;
  DateTime get date;
  String get subject;
  Map<String, String> get header;
  List<MailNavigatorMessagePart> get bodies;
  List<MailNavigatorMessagePart> get attachements;

  static final RegExp regExp = RegExp(r"^(.+)<(.+)>$");

  String get fromFullName {
    try {
      String result;
      regExp.allMatches(this.from).forEach((RegExpMatch element) {
        String s = element.group(1);
        if (s.isNotEmpty) {
          result = s;
        }
      });
      return result;
    } catch (e) {
      _log.shout("[fromEmail] ${e.toString()}");
      rethrow;
    }
  }

  String get fromEmail {
    try {
      String result;
      regExp.allMatches(this.from).forEach((RegExpMatch element) {
        String s = element.group(2);
        if (s.isNotEmpty) {
          result = s;
        }
      });
      return result;
    } catch (e) {
      _log.shout("[fromEmail] ${e.toString()}");
      rethrow;
    }
  }
  // body later

  StringBuffer _cleanupElement(dom.Element e) {
    StringBuffer r = StringBuffer("");

    _log.finest(
        "[_cleanupElement] element is ${e.localName} :type ${e.nodeType.toString()} :text ${e.text.length} : nodes : ${e.nodes.length}");

    // ignore some localName
    switch (e.localName) {
      case "style":
        return r;
    }
    String t = ''; // not null by default
    // extra text from current Element by lookging the TEXT Nodes.
    e.nodes.forEach((dom.Node element) {
      if (element.nodeType == dom.Node.TEXT_NODE) {
        t = element.text;
        _log.finest("[_cleanupElement] node text ${t.length} ");
        if (t.trim().isNotEmpty) {
          _log.finest("[_cleanupElement] add text >>${t}<< ");
          r.write(t);
        }
      }
    });
    // recursively apply to child elements.
    e.children.forEach((element) {
      t = _cleanupElement(element).toString();
      if (t.trim().isNotEmpty) {
        _log.finest("[_cleanupElement] child result >>${t}<< ");
        r.write(t);
      }
    });
    // add a chapter separator if needed.
    if (r.isNotEmpty) {
      switch (e.localName) {
        case "br":
        case "p":
        case "table":
        case "tr":
          // no double new line.
          _log.finest("[_cleanupElement] switch result :${r.length}");
          t = r.toString();
          if (t.substring(t.length - 1) != '\n') {
            r.writeln("");
          }
          break;
      }
    }
    return r;
  }

  String _cleanupMessage(String htmlStr) {
    dom.Document doc = dom.Document.html(htmlStr);
    // extract body and return its value as String
    dom.Element e = doc.body;
    return this._cleanupElement(e).toString().trim();
  }

  String get bodyContentAsText {
    String result;
    if (this.bodies == null || this.bodies.length == 0) return null;

    for (MailNavigatorMessagePart p in this.bodies) {
      _log.finest("[bodyContentAsText] making body part $p");
      _log.finest(
          "[bodyContentAsText] reading type ${p.contentType.toString()} ");
      if (p.text != null)
        _log.finest("[bodyContentAsText] reading text ${p.text}");

      try {
        if (p.contentType.mimeType == ContentType.text.mimeType) {
          result = p.text;
        } else if (p.contentType.mimeType == ContentType.html.mimeType) {
          result = _cleanupMessage(p.text);
          _log.finest("[bodyContentAsText] display html : $result");

          _log.fine("[bodyContentAsText] widget html made");
          break; // exit loop when HTML part read.
        } // IF
      } catch (e) {
        _log.shout("[bodyContentAsText] error extract body : $e ");
      }
    } // for
    return result;
  }
  // attachment either.
}
