/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

///
/// The purpose of the class is to wrap sent and received data
/// to trace them in a logger.
///
class BrowserClientWrapper extends BrowserClient {
  static final Logger _log = Logger('BrowserClientWrapper');

  // const attributes.
  // private attributes.

  // public attributes

  /// Default Constructor
  BrowserClientWrapper() {
    _log.level = Level.FINEST;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    _log.fine("[send] ==> url ${request.url.toString()}");
    request.headers.forEach((key, value) {
      _log.finer("[send] header ==> $key : $value");
    });

    try {
      StreamedResponse response = await super.send(request);
      _log.fine("[send] <== status ${response.statusCode}");
      response.headers.forEach((key, value) {
        _log.finer("[send] response head <== $key : $value");
      });

      return response;
    } catch (e) {
      _log.fine(
          "[send] <== error ${e.runtimeType.toString()} : ${e.toString()}");

      rethrow;
    }
  }

// Private Methods

// Public Methods.

}
