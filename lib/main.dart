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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as Intl;
import 'package:logging/logging.dart';
import 'package:global_configuration/global_configuration.dart';

import 'Mail2BoondCandidateApp.dart';

void main() async {
  Logger.root.level = Level.CONFIG;
  hierarchicalLoggingEnabled = true;
  recordStackTraceAtLevel = Level.SHOUT;
  Logger.root.onRecord.listen((LogRecord record) {
    String f = Intl.DateFormat("HH:mm:ss ").format(record.time);

    String obj = (record.error == null) ? "" : record.error.toString();
    print('$f: ${record.toString()} - $obj');
    if (record.stackTrace != null) {
      print('$f: stack trace : ${record.stackTrace.toString()}');
    }
  });
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // await GlobalConfiguration().loadFromAsset("settings");
    await GlobalConfiguration().loadFromUrl("/assets/cfg/settings.json");

    runApp(Mail2BoondCandidateApp());
  } catch (e, s) {
    Logger.root.severe("main uncatched exception ", e, s);
  }
}
