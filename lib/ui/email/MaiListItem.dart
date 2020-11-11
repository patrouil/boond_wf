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

import 'package:intl/intl.dart' as Intl;
import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/MailNavigatorBloc.dart';
import '../../entity/MailNavigatorMessage.dart';
import '../../business/MailUIState.dart';
import '../../business/MailUIEvent.dart';

class MailListItem extends StatelessWidget {
  static final _log = Logger('MailListItem');

  static final ListTile waitWidget = ListTile(title: Text("loading ..."));
  static final Intl.DateFormat parser = Intl.DateFormat("[d-MMM hh:mm]");

  final MailNavigatorMessage mailHeader;

  const MailListItem({Key key, @required this.mailHeader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.mailHeader == null) return waitWidget;

    MailNavigatorBloc mailBloc = BlocProvider.of<MailNavigatorBloc>(context);
    String dateStr = "";

    if (this.mailHeader.date != null)
      dateStr = parser.format(this.mailHeader.date);

    return Draggable<MailNavigatorMessage>(
      data: this.mailHeader,
      maxSimultaneousDrags: 1,
      feedback: Text("${this.mailHeader.from}"),
      child: ListTile(
          enabled: true,
          dense: true,
          title: Text("$dateStr ${this.mailHeader.from}"),
          onTap: () {
            _log.fine("[_mailItemBuilder] select ${this.mailHeader.id} entry");
            mailBloc.add(
                MailUIEventMessageContentRequest(msgId: this.mailHeader.id));
          },
          subtitle: Text("${this.mailHeader.subject}")),
    );
  }
}
