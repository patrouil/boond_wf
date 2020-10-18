/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_wf/entity/BoondAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';

import '../../business/BoondCandidateUIState.dart';
import '../../business/BoondCandidateBloc.dart';

class CandidateDocumentEditor extends StatefulWidget {
  static final Logger _log = Logger("CandidateDocumentEditor");

  /// Default Constructor
  CandidateDocumentEditor() : super() {
    //_log.level = Level.FINE;
  }

  @override
  State<StatefulWidget> createState() => _CandidateDocumentEditorState();
}

class _CandidateDocumentEditorState extends State<CandidateDocumentEditor> {
  static final Logger _log = Logger("CandidateDocumentEditor");

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext _context) {
    BlocBuilder listWidget =
        BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
      // bloc: BlocProvider.of<BoondCandidateBloc>(context),
      buildWhen:
          (BoondCandidateUIState previousState, BoondCandidateUIState state) {
        final List<Type> criteria = [
          BoondCandidateUIStateConnected(infoMessage: null).runtimeType,
          BoondCandidateUIStateDisconnected().runtimeType
        ];

        _log.fine(
            " [${_log.name}:build] got a status condition ${state.toString()}");
        return criteria.contains(state.runtimeType);
      }, //
      builder: (BuildContext c, BoondCandidateUIState s) {
        _log.fine(" [${_log.name}:build] list builder");
        BoondCandidateBloc boondBloc = BlocProvider.of<BoondCandidateBloc>(c);
        BoondAction act = boondBloc.editedActions;

        return ListView.builder(
            reverse: false,
            itemCount: (act.attachments == null || act.attachments.length == 0)
                ? 0
                : act.attachments.length,
            itemBuilder: (BuildContext c, int idx) {
              BoondActionAttachment p = act.attachments[idx];

              return _attachmentWidget(boondBloc, p);
            });
      },
    );
    //;
    return listWidget;
  }

  Map<String, IconData> _mimeIcons = const {
    "word": LineAwesomeIcons.file_word_o,
    "application/pdf": LineAwesomeIcons.file_pdf_o,
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
        LineAwesomeIcons.file_excel_o
  };

  Widget _attachmentWidget(
      BoondCandidateBloc boondBloc, BoondActionAttachment part) {
    Widget w;

    Widget delButton = IconButton(
      // alignment: Alignment.center,
      icon: Icon(Icons.delete),
      onPressed: () => _handleDelete(boondBloc, part),
    );

    IconData icn = _mimeIcons[part.fileType.mimeType];
    if (icn != null)
      w = ListTile(
        title: Text(part.filename),
        leading: Icon(icn),
        trailing: delButton,
      );
    else {
      w = ListTile(
        leading: Icon(LineAwesomeIcons.paperclip),
        title: Text(part.filename),
        subtitle: Text(part.fileType.mimeType),
        trailing: delButton,
      );
    }
    return w;
  }

  void _handleDelete(BoondCandidateBloc boondBloc, BoondActionAttachment part) {
    this.setState(() {
      boondBloc.editedActions.attachments.remove(part);
    });
  }
}
