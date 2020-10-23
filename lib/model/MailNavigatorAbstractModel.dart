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

import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';

import 'MailNavigatorGoogleModel.dart';
import '../entity/MailNavigatorMessage.dart';

enum MailNavigatorModelResponse { ok, no, bad }

class MailNavigatorStatus {
  MailNavigatorModelResponse code;
  String message;
  MailNavigatorStatus(this.code, this.message);
}

abstract class MailNavigatorAbstractModel {
  @protected
  static final Logger log = Logger('MailNavigatorModel');

  get mailLog => MailNavigatorAbstractModel.log;

  bool isConnected();

  @protected
  MailNavigatorStatus lastStatus;

  get status => lastStatus;

  MailNavigatorAbstractModel();

  factory MailNavigatorAbstractModel.google() => MailNavigatorGoogleModel();

  Future<MailNavigatorStatus> connect() async {
    throw UnimplementedError();
  }

  Future<MailNavigatorStatus> logon() async {
    throw UnimplementedError();
  }

  Future<MailNavigatorStatus> close() async {
    throw UnimplementedError();
  }

  Future<MailNavigatorStatus> delete(String id) async {
    throw UnimplementedError();
  }

  Future<List<String>> getMessageList() async {
    throw UnimplementedError();
  }

  Future<MailNavigatorMessage> getMessageHeader(String id) async {
    throw UnimplementedError();
  }

  Future<MailNavigatorMessage> getMessage(String id) async {
    throw UnimplementedError();
  }
}
