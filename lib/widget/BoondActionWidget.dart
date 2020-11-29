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

import 'package:flutter/material.dart'
    show
        TextFormField,
        InputDecoration,
        OutlineInputBorder,
        ListTile,
        IconButton,
        Icons;
import 'package:line_awesome_icons/line_awesome_icons.dart';

import '../entity/BoondAction.dart';

class BoondActionWidget extends StatefulWidget {
  static final Logger log = Logger("BoondActionWidget");

  final BoondAction theAction;
  final bool editEnabled;
  final void Function(BoondAction a) asChanged;

  /// Default Constructor
  BoondActionWidget({Key key, this.theAction, this.editEnabled, this.asChanged})
      : super(key: key) {
    //log.level = Level.FINE;
  }

  @override
  State<StatefulWidget> createState() => _BoondActionWidgetState();
}

class _BoondActionWidgetState extends State<BoondActionWidget> {
  static final Logger log = BoondActionWidget.log;

  @override
  initState() {
    super.initState();
  }

  void _triggerValueChanged() {
    if (this.widget.asChanged != null)
      this.widget.asChanged(this.widget.theAction);
  }

  Widget _buildBody(BuildContext context) {
    log.fine("[_buildBody] ${this?.widget?.theAction?.bodyText}");

    // should manage editing mode
    TextEditingController controler =
        TextEditingController(text: this?.widget?.theAction?.bodyText ?? "");

    return TextFormField(
        readOnly: !this.widget.editEnabled,
        textInputAction: TextInputAction.none,
        showCursor: this.widget.editEnabled,
        enabled: this.widget.editEnabled,
        controller: controler,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Message',
        ),
        minLines: 5,
        maxLines: 30,
        onChanged: (String v) {
          this?.widget?.theAction?.bodyText = controler.value.text.trim();
          _triggerValueChanged();
        });
  }

  ///
  /// Map mime type with a fancy Icon.
  ///
  Map<String, IconData> _mimeIcons = const {
    "word": LineAwesomeIcons.file_word_o,
    "application/pdf": LineAwesomeIcons.file_pdf_o,
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
        LineAwesomeIcons.file_excel_o
  };

  List<Widget> _attachmentWidget(BuildContext _context) {
    List<ListTile> result = List<ListTile>();
    log.fine("[_attachmentWidget]");
    List<BoondActionAttachment> att = this.widget.theAction.attachments;

    for (BoondActionAttachment p in att) {
      Widget delButton;
      log.fine("[_attachmentWidget] ${p.filename}");

      if (this.widget.editEnabled)
        delButton = IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _handleDelete(p),
        );

      IconData icn = _mimeIcons[p.fileType.mimeType];
      if (icn == null) icn = LineAwesomeIcons.paperclip;

      result.add(ListTile(
        leading: Icon(icn),
        title: Text(p.filename),
        subtitle: Text(p.fileType.mimeType),
        trailing: delButton,
      ));
    }
    return result;
  }

  void _handleDelete(BoondActionAttachment att) {
    setState(() {
      this.widget.theAction.attachments.remove(att);
    });
    _triggerValueChanged();
  }

  @override
  Widget build(BuildContext _context) {
    log.fine("[build] ");

    List<Widget> l = List<Widget>();
    Widget contentShow = this._buildBody(_context);
    l.add(contentShow);
    l.addAll(this._attachmentWidget(_context));

    return Container(
        constraints: BoxConstraints.expand(height: 200), // width: 100,
        child: ListView(
          shrinkWrap: true,
          children: l,
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
        ));
  }
}
