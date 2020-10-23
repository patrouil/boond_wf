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

import 'package:http/http.dart';

import 'package:logging/logging.dart';
import 'package:quiver/cache.dart' as QuiverCache;
import 'package:global_configuration/global_configuration.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import 'package:googleapis/gmail/v1.dart' as GMail;
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_browser.dart' as AuthBrowser;

import '../entity/MailNavigatorGoogleMessage.dart';
import '../entity/MailNavigatorMessage.dart';
import 'MailNavigatorAbstractModel.dart';

///
/// References URL :
/// https://pub.dev/packages/googleapis
/// https://pub.dev/documentation/googleapis_auth/
/// https://developers.google.com/gmail/api/
/// https://developers.google.com/gmail/api/guides
/// https://developers.google.com/gmail/api/v1/reference
/// https://developers.google.com/admin-sdk/directory/v1/guides/delegation
///
/// Quick start
/// https://developers.google.com/gmail/api/quickstart/js
/// Fields selection (and other)
/// https://developers.google.com/gmail/api/guides/performance
///
/// Manage your Appplication Key here
/// https://console.developers.google.com/apis/dashboard?project=mail2boond
///
///
class MailNavigatorGoogleModel extends MailNavigatorAbstractModel {
  static const EMAIL_ADDRESS = "me";
  static const INBOX_LABEL = "INBOX";

  GMail.GmailApi _client;
  AuthClient _httpClient;

  // uploaded message cache
  QuiverCache.MapCache<String, MailNavigatorMessage> messageCache =
      QuiverCache.MapCache.lru(maximumSize: 100);

  MailNavigatorGoogleModel() : super() {
    //super.mailLog.level = Level.FINEST;
  }
  MailNavigatorStatus _makeResponse(MailNavigatorModelResponse status,
      {String msg}) {
    this.lastStatus = MailNavigatorStatus(status, msg);
    return super.status;
  }

  @override
  Future<MailNavigatorStatus> close() async {
    if (_httpClient != null) _httpClient.close();
    _httpClient = null;
    _client = null;
    return _makeResponse(MailNavigatorModelResponse.ok);
  }

  @override
  Future<MailNavigatorStatus> connect() async {
    return connectGoogleAuth();
  }

  /// read here https://pub.dev/packages/googleapis_auth#-readme-tab-
  Future<MailNavigatorStatus> connectGoogleAuth() async {
    const SCOPES = const [GMail.GmailApi.MailGoogleComScope];
    String _clientId = GlobalConfiguration().getValue("gmail.clientId");

    String _apiKey = GlobalConfiguration().getValue("gmail.apiKey");
    String msg;

    mailLog.fine("connectGoogleAuth] connecting");
    ClientId id = new ClientId(_clientId, _apiKey);

    // synchronous version for better understanding
    AuthBrowser.BrowserOAuth2Flow flow;
    try {
      flow = await AuthBrowser.createImplicitBrowserFlow(
        id,
        SCOPES,
      );
      if (flow != null) {
        _httpClient = await flow.clientViaUserConsent(immediate: false);
        this._client = GMail.GmailApi(_httpClient);

        return _makeResponse(MailNavigatorModelResponse.ok, msg: "connected");
      } else {
        return _makeResponse(MailNavigatorModelResponse.bad,
            msg: "unable to get authorizations ");
      }
    } on UserConsentException catch (e) {
      msg = e.toString();
    } catch (e) {
      msg = e.toString();
      mailLog.shout(
          "[connectGoogleAuth] catched error type ${e.runtimeType.toString()} ");

      mailLog.severe("[${mailLog.name}] connect Google : failure $msg ");
    } finally {
      if (flow != null) flow.close();
    }
    return _makeResponse(MailNavigatorModelResponse.no, msg: msg);
  }

  @override
  bool isConnected() {
    return (_client != null) && (_httpClient != null);
  }

  // check the labels to see if we are allowed to connect.
  // WARNING we always use me as a mail address. No settings.
  @override
  Future<MailNavigatorStatus> logon() async {
    mailLog.fine("[connectGoogle] : logon");

    try {
      GMail.Label lbl =
          await this._client.users.labels.get(EMAIL_ADDRESS, INBOX_LABEL);
      mailLog.fine("[connectGoogle] : got inbox label ${lbl.name}");

      return _makeResponse(MailNavigatorModelResponse.ok,
          msg: "connected (got label)");
    } on DetailedApiRequestError catch (e) {
      String msg;
      GMail.DetailedApiRequestError derr = e;
      msg = derr.toString();

      mailLog.shout("[logon] unable to get labels due to Web Request $msg ", e);
      if (derr.jsonResponse != null)
        mailLog.fine("[logon] detailed json ${derr.jsonResponse.toString()} ");
      return _makeResponse(MailNavigatorModelResponse.no, msg: msg);
    } on ClientException catch (e) {
      this.close(); // safer to disconnect
      String msg = e.toString();
      mailLog.shout("[logon] gmail api Client exception : $msg ", e);
      return _makeResponse(MailNavigatorModelResponse.bad, msg: msg);
    } catch (e) {
      String msg = e.toString();
      mailLog.shout(
          "[logon] catched error type ${e.runtimeType.toString()} $msg ", e);
      return _makeResponse(MailNavigatorModelResponse.bad, msg: msg);
    }
  }

  Future<MailNavigatorStatus> delete(String id) async {
    try {
      mailLog.fine("[delete]: deleting message  ${id}");

      await _client.users.messages.delete(EMAIL_ADDRESS, id);
      this.messageCache.invalidate(id);
      return _makeResponse(MailNavigatorModelResponse.ok);
    } catch (e) {
      return _makeResponse(MailNavigatorModelResponse.no, msg: e.toString());
    }
  }

  Future<List<String>> getMessageList() async {
    List<String> msgList = [];

    if (!isConnected()) {
      _makeResponse(MailNavigatorModelResponse.bad,
          msg: "you must connect first");
      return null;
    }
    mailLog.fine("[getMessageList] looking for messages list");

    try {
      GMail.ListMessagesResponse r;
      String pageToken;
      do {
        GMail.ListMessagesResponse r = await _client.users.messages
            .list(EMAIL_ADDRESS, labelIds: [INBOX_LABEL], pageToken: pageToken);
        mailLog.fine("[getMessageList] loop in list $pageToken");

        if (r != null) {
          for (GMail.Message m in r.messages) {
            msgList.add(m.id);
          }
          pageToken = r.nextPageToken; //
        }
      } while (r != null && pageToken != null);
      mailLog.fine("[getMessageList] got many message ${msgList.length}");
    } catch (e) {
      mailLog.severe("[getMessageList] error getting list $e");
      _makeResponse(MailNavigatorModelResponse.bad, msg: e.toString());
    }
    return msgList;
  }

  @override
  Future<MailNavigatorMessage> getMessageHeader(String id) async {
    MailNavigatorMessage m;
    m = await this.messageCache.get(id);
    if (m != null) return m;

    try {
      // payload required to look for attachments
      GMail.Message msg = await _client.users.messages.get(EMAIL_ADDRESS, id,
          $fields: "id,internalDate,payload,sizeEstimate");

      m = MailNavigatorGoogleMessage(msg);
      this.messageCache.set(id, m);
    } catch (e) {
      mailLog.severe("[getMessageHeader] error getting message $e");
    }
    return m;
  }

  // For my own documentation messages structure is :
  // body
  //    headers.
  //    parts
  //      body
  //        size : 0 : this is the body part. So read the subparts.
  //        filename :
  //        parts
  //          body  : there are many bodies. One per format (text / html ...).
  //            data : part content un base64
  //              warning : if type it multipart there is no data, only subparts.
  //          filename : ''
  //          mimetype :
  //      body
  //        size : > 0
  //        attachmentId : id to fetch the attachement (no data).
  //        filename : not empty.
  //        mimetype : not empty.
  //
  @override
  Future<MailNavigatorMessage> getMessage(String id) async {
    MailNavigatorMessage m = await this.getMessageHeader(id);
    if (m == null) {
      _makeResponse(MailNavigatorModelResponse.bad,
          msg: "unable to locate message $id");
      return null;
    }
    MailNavigatorGoogleMessage gm = m as MailNavigatorGoogleMessage;

    // is already loaded and cached.
    // if (gm.bodies.length > 0) return gm;
    try {
      // get a full message content
      GMail.Message msg =
          await _client.users.messages.get(EMAIL_ADDRESS, id, format: "full");
      gm = MailNavigatorGoogleMessage(msg);
      // Only in debug mode
      String t = msg.toJson().toString();
      mailLog.finest("[getMessage] message content id: $t");
      // load each attachements content.
      for (MailNavigatorMessagePart attach in gm.attachements) {
        if (attach.content == null && attach.attachmentId != null) {
          GMail.MessagePartBody bodyData = await _client
              .users.messages.attachments
              .get(EMAIL_ADDRESS, id, attach.attachmentId);
          attach.content = bodyData.data;
        }
      }
      this.messageCache.set(id, gm); // refresh cache.
      return gm;
    } on ClientException catch (e) {
      mailLog.severe("[getMessage] erreur appel Google ", e.toString());
      _makeResponse(MailNavigatorModelResponse.bad, msg: e.toString());
      return null;
    } catch (e) {
      mailLog.severe("[getMessage] erreur de chargement ", e);
      _makeResponse(MailNavigatorModelResponse.bad, msg: e);
      return null;
    }
  }
}
