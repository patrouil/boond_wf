/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:boond_wf/entity/BoondAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';

import 'package:boond_api/boond_api.dart' as boond
    show AppDictionnaryGet, AppDictApp;

import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateUIState.dart';

import '../../widget/BoondDropdownFormField.dart';
import '../../widget/BoondActionWidget.dart';

class CandidateActionForm extends StatefulWidget {
  static final Logger log = Logger("CandidateActionForm");

  CandidateActionForm() : super() {
    debugPaintSizeEnabled = true;

    log.level = Level.FINE;
  }

  @override
  State<StatefulWidget> createState() => _CandidateActionFormState();
}

class _CandidateActionFormState extends State<CandidateActionForm> {
  static final Logger _log = Logger("CandidateActionForm");

  final _formKey = GlobalKey<FormState>();

  final _emptyAvailabilityList = List<boond.AppDictApp>();

  BoondAction currentAction = BoondAction();

  Widget _buildTypeOfField(BuildContext _context) {
    List<boond.AppDictApp> avail = _emptyAvailabilityList;

    BoondCandidateBloc candidateBloc =
        BlocProvider.of<BoondCandidateBloc>(_context);

    if (candidateBloc.isConnected()) {
      boond.AppDictionnaryGet d = candidateBloc?.model?.application_dict;
      avail = d?.data?.setting?.action?.candidate ?? _emptyAvailabilityList;
    }

    Widget w = BoondDropdownFormField<boond.AppDictApp>(
      entries: avail,
      selectedId: candidateBloc.editedActions?.typeOf ?? 0,
      onChanged: (boond.AppDictApp v) {
        _log.fine("[_buildTypeOfField.onChanged] $v.id");

        candidateBloc.editedActions?.typeOf = v.id;
      },
      onTap: _handleEditingComplete,
      idOf: (boond.AppDictApp e) => e.id,
      labelOf: (boond.AppDictApp e) => e.value,
    );
    return w;
  }

  Widget _buildTextField(BuildContext _context) {
    BoondCandidateBloc candidateBloc =
        BlocProvider.of<BoondCandidateBloc>(this.context);
    assert(this.currentAction != null);
    return BoondActionWidget(
      theAction: this.currentAction,
      editEnabled: true,
      asChanged: _handleEditingComplete,
    );
  }

  void _handleEditingComplete(BoondAction a) {
    _log.fine("[_handleEditingComplete] ");

    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(this.context);

    b.add(BoondActionUIEventChanged(action: a));
  }

  Widget _buildFormWrapper(BuildContext _context) {
    return Form(
      key: this._formKey,
      child: Column(
        children: [
          _buildTypeOfField(_context),
          Expanded(child: _buildTextField(_context)),
        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext _context) {
    return BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
      buildWhen:
          (BoondCandidateUIState previousState, BoondCandidateUIState state) {
        final List<Type> criteria = [
          BoondCandidateUIStateMergeAction(actionMessage: null).runtimeType,
          BoondCandidateUIStateSaved(candidate: null).runtimeType,
          BoondCandidateUIStateLoaded(candidate: null).runtimeType,
          BoondCandidateUIStateDisconnected().runtimeType
        ];

        if (state is BoondCandidateUIStateMergeAction) {
          this.currentAction = state.actionMessage;
          //
        } else if (state is BoondCandidateUIStateSaved)
          this.currentAction = BoondAction();
        else if (state is BoondCandidateUIStateLoaded)
          this.currentAction = BoondAction();
        else if (state is BoondCandidateUIStateDisconnected)
          this.currentAction = BoondAction();

        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext c, BoondCandidateUIState s) {
        // dont know why but have to locate the bloc.
        BoondCandidateBloc candidateBloc =
            BlocProvider.of<BoondCandidateBloc>(c);
        _log.fine("[build.builder] ");

        return _buildFormWrapper(c);
      },
    );
  }
}
