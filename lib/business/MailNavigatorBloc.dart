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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../model/MailNavigatorAbstractModel.dart';
import '../entity/MailNavigatorMessage.dart';
import 'MailUIEvent.dart';
import 'MailUIState.dart';

class MailNavigatorBloc extends Bloc<MailUIEvent, MailUIState> {
  static final Logger _log = Logger('MailNavigatorBloc');

  ///
  final MailNavigatorAbstractModel _dataModel =
      MailNavigatorAbstractModel.google();

  MailNavigatorAbstractModel get model => _dataModel;

  ///
  MailNavigatorBloc() : super(MailUIStateDisconnected()) {
    //_log.level = Level.FINEST;
  }

  @override
  Future<void> close() {
    this.model.close();
    return super.close();
  }

  @override
  Stream<MailUIState> mapEventToState(MailUIEvent event) async* {
    _log.fine(
        "[mapEventToState] event to map is ${event.runtimeType.toString()}");

    if (event is MailUIEventConnectRequest) {
      yield await this._connect();
    } else if (event is MailUIEventDisconnectRequest) {
      if (model.isConnected()) {
        await model.close();
        yield MailUIStateDisconnected();
      }
    } else if (event is MailUIEventWarning) {
      yield MailUIStateWarning(warningMessage: event.warningMessage);
    } else if (event is MailUIEventInboxListRequest) {
      yield await this._getInboxList();
    } else if (event is MailUIEventMessageContentRequest) {
      MailNavigatorMessage msg = await model.getMessage(event.msgId);
      if (msg == null) {
        yield MailUIStateWarning(warningMessage: model.status.message);
      } else
        yield MailUIStateMessageLoaded(message: msg);
    } else if (event is MailUIEventMessageHeaderRequest) {
      MailNavigatorMessage msg = await model.getMessageHeader(event.msgId);
      if (msg == null) {
        yield MailUIStateWarning(warningMessage: model.status.message);
      } else
        yield MailUIStateHeaderLoaded(message: msg);
    } else if (event is MailUIEventDeleteRequest) {
      yield await this._delete(event.msgId);
    } else
      throw UnimplementedError(
          " unhandled event ${event.runtimeType.toString()} ");
  }

  Future<MailUIState> _getInboxList() async {
    List<String> l = await model.getMessageList();

    if (l == null) {
      return MailUIStateWarning(warningMessage: model.status.infoMessage);
    } else {
      return MailUIStateInboxListLoaded(
          messageIdList: l, infoMessage: "found ${l.length} messages");
    }
  }

  bool isConnected() {
    return model.isConnected();
  }

  Future<MailUIState> _connect() async {
    if (model.isConnected()) {
      await model.close();
      return MailUIStateDisconnected();
    }
    MailNavigatorStatus b = await model.connect();
    _log.fine("[connect] model connect response ${b.code} / ${b.message}");

    if (b.code != MailNavigatorModelResponse.ok) {
      return MailUIStateWarning(warningMessage: b.message);
    }
    b = await model.logon();
    _log.fine("[connect] model login response ${b.code} / ${b.message}");

    if ((b.code == MailNavigatorModelResponse.ok) && model.isConnected()) {
      return MailUIStateConnected(infoMessage: b.message);
    } else {
      return MailUIStateDisconnected(infoMessage: b.message);
    }
  }

  Future<MailUIState> _delete(String id) async {
    MailNavigatorStatus b = await model.delete(id);
    if (b.code == MailNavigatorModelResponse.ok) {
      return MailUIStateMessageDeleted(messageIdList: [id]);
    } else {
      return MailUIStateWarning(warningMessage: b.message);
    }
  }
}
