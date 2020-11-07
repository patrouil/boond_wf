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
//import 'package:boond_api/entities/candidate-body.dart';

import 'package:meta/meta.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences_settings/shared_preferences_settings.dart';

import 'package:boond_api/boond_api.dart'
    show
        ActionsGet,
        ActionsPost,
        AppCurrentUserGet,
        AppDictionnaryGet,
        BoondApi,
        BoondApiError,
        CandidateGet,
        CandidatePost,
        CandidateSearch,
        DocumentsGet,
        DocumentsPost;

import '../widget/BoondAuthBrowser.dart';
import '../ui/candidate/BoondSettings.dart';

enum BoondCandidateModelResponse { ok, no, bad }

class BoondCandidateStatus {
  BoondCandidateModelResponse code;
  String message;
  BoondCandidateStatus(this.code, this.message);
}

class BoondCandidateModel {
  // const attributes.
  static final Logger _log = Logger('BoondCandidateModel');

  // private attributes.
  @protected
  BoondApi boond;
  @protected
  BoondCandidateStatus lastStatus;

  AppCurrentUserGet _appCurrentUser;
  AppCurrentUserGet get connected_user {
    return _appCurrentUser;
  }

  AppDictionnaryGet _application_dict;
  AppDictionnaryGet get application_dict {
    return _application_dict;
  }

  // public attributes

  /// Default Constructor
  BoondCandidateModel() {
    //_log.level = Level.FINE;
  }

// Private Methods
  BoondCandidateStatus _makeResponse(BoondCandidateModelResponse status,
      [String msg]) {
    this.lastStatus = BoondCandidateStatus(status, msg);
    return this.lastStatus;
  }

// Public Methods.
  get status => lastStatus;

  Future<BoondCandidateStatus> connect(BuildContext context) async {
    try {
      _log.fine("[connect] begin $context ");

      String clientToken = await BoondSettings.clientToken;
      String clientKey = await BoondSettings.clientKey;
      String workspace = await BoondSettings.serverHostName;

      BoondApi bapi = await BoondAuthBrowser.clientViaUserConsent(
        context: context,
        clientToken: clientToken,
        clientKey: clientKey,
        boondHost: workspace,
        level: _log.level,
      );
      _log.fine("[connect] end dialog $context ");

      if (bapi == null)
        return _makeResponse(BoondCandidateModelResponse.bad, "login failed");

      // prefetch datas
      _appCurrentUser = await bapi.currentuser.get();
      _application_dict = await bapi.app_dict.get();
      this.boond = bapi;

      return _makeResponse(BoondCandidateModelResponse.ok);
    } on BoondApiError catch (e) {
      return _makeResponse(BoondCandidateModelResponse.no, e.toString());
    } catch (e) {
      _log.shout("[connect] undefined error $e ");
      return _makeResponse(BoondCandidateModelResponse.bad, e.toString());
    }
  }

  Future<BoondCandidateStatus> close() async {
    BoondAuthBrowser.forgiveUserConsent();
    if (this.boond != null) this.boond.httpClient.close();
    this.boond = null;
    this._appCurrentUser = null;
    return _makeResponse(BoondCandidateModelResponse.ok);
  }

  bool isConnected() {
    return this.boond != null;
  }

  String get fullUserName => (this.connected_user == null)
      ? null
      : "${connected_user.data.attributes.firstName} ${connected_user.data.attributes.lastName}";

  Future<CandidateSearch> searchCandidates(List<String> criteria) async {
    Map<String, String> c = Map<String, String>();
    criteria.forEach((element) {
      List<String> v = element.split("=");
      if (v.length != 2) {
        throw BoondApiError(BoondApiError.PARSE_ERROR,
            "criteria syntax is 'key=value' : $element");
      }
      c.addAll({v[0]: v[1]});
    });
    _log.fine("[searchCandidates] looking for candidates ${c.toString()}");
    return this.boond.candidate.search(c);
  }

  Future<CandidateGet> getCandidate(String id) {
    return this.boond.candidate.information(id);
  }

  Future<CandidateGet> newCandidate() {
    return this.boond.candidate.empty();
  }

  Future<CandidateGet> saveCandidate(CandidateGet can) {
    assert(can != null);
    _log.fine("[saveCandidate] saving $can");
    if (can?.data?.id == "0")
      return this.boond.candidate.post(CandidatePost.fromCandidateGet(can));
    else
      return this.boond.candidate.put_information(can);
  }

  Future<ActionsGet> newActions(CandidateGet can) {
    assert(can != null);
    return this.boond.actions.empty(can.data.type, can.data.id);
  }

  Future<ActionsGet> saveActions(ActionsGet can) {
    assert(can != null);
    _log.fine("[saveActions] saving $can");
    if (can?.data?.id == "0")
      return this.boond.actions.post(ActionsPost.fromActionsGet(can));
    else
      return this.boond.actions.put(can);
  }

  Future<DocumentsGet> saveDocument(DocumentsPost can) {
    assert(can != null);

    _log.fine("[saveDocument] saving $can");

    return this.boond.documents.post(can);
  }

  String getCandidateUrl(CandidateGet candidate) {
    assert(candidate?.data != null);
    Uri r = this.boond.candidate.getInformationUri(candidate.data.id);
    return r.toString();
  }
}
