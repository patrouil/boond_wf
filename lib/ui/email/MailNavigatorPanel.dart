/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';

import '../../widget/gadget_decoration.dart';

import '../../widget/notification.dart';

import 'MailListBrowser.dart';
import 'MailNavigatorActions.dart';
import 'MailNavigatorViewer.dart';

class MailNavigatorPanel extends StatefulWidget {
  MailNavigatorPanel() : super();

  @override
  State<StatefulWidget> createState() => MailNavigatorPanelState();
}

@protected
class MailNavigatorPanelState extends State<MailNavigatorPanel> {
  @override
  Widget build(BuildContext context) {
    Color cb = GadgetDecoration.gadgetColor(context);

    return (NotificationWrapper(
      child: Column(
        children: [
          Expanded(
            flex: 40,
            child: GadgetDecoration(color: cb, child: MailListBrowser()),
          ),
          Expanded(
            flex: 50,
            child: GadgetDecoration(color: cb, child: MailNavigatorViewer()),
          ),
          Flexible(
            flex: 15,
            child: GadgetDecoration(color: cb, child: MailNavigatorActions()),
          )
        ],
      ),
    ));
  }
}
