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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entity/BoondAction.dart';
import '../../widget/BoondActionWidget.dart';
import '../../business/MailNavigatorBloc.dart';
import '../../entity/MailNavigatorMessage.dart';
import '../../business/MailUIState.dart';

class MailNavigatorViewer extends StatefulWidget {
  static final Logger _log = Logger('MailNavigatorViewer');

  /// Default Constructor
  MailNavigatorViewer({Key key}) : super(key: key) {
    //_log.level = Level.FINEST;
  }

  @override
  State<StatefulWidget> createState() => _MailNavigatorViewerState();
}

class _MailNavigatorViewerState extends State<MailNavigatorViewer> {
  static final Logger _log = Logger('MailNavigatorViewer');

  MailNavigatorMessage dispMessage;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext _context) {
    _log.fine("[build] ");

    return BlocBuilder<MailNavigatorBloc, MailUIState>(
        // bloc: BlocProvider.of<MailNavigatorBloc>(_context),
        buildWhen: (MailUIState previousState, MailUIState state) {
      final List<Type> criteria = [
        MailUIStateInboxListLoaded(messageIdList: null).runtimeType,
        MailUIStateMessageDeleted(messageIdList: null).runtimeType,
        MailUIStateMessageLoaded(message: null).runtimeType,
        MailUIStateDisconnected().runtimeType,
      ];
      if (state is MailUIStateMessageLoaded)
        this.dispMessage = state.message;
      else
        this.dispMessage = null;

      return criteria.contains(state.runtimeType);
    }, builder: (BuildContext _context, MailUIState s) {
      _log.fine("[builder] ${s.runtimeType.toString()}");

      return BoondActionWidget(
          theAction: BoondAction.fromMailNavigatorMessage(this.dispMessage),
          editEnabled: false);
    });
  }
}
