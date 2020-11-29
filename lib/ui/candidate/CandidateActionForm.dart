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

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:boond_api/boond_api.dart' as boond
    show AppDictionnaryGet, AppDictApp;

import '../../entity/BoondAction.dart';
import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateUIState.dart';
import '../../widget/BoondDropdownFormField.dart';
import '../../widget/BoondActionWidget.dart';

class CandidateActionForm extends StatefulWidget {
  const CandidateActionForm() : super();

  @override
  State<StatefulWidget> createState() => _CandidateActionFormState();
}

class _CandidateActionFormState extends State<CandidateActionForm> {
  static final Logger _log = Logger("CandidateActionForm");

  final _formKey = GlobalKey<FormState>();

  static final _emptyAvailabilityList = [
    boond.AppDictApp(id: 0, value: "")
  ]; // List<boond.AppDictApp>();

  BoondAction currentAction;

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
      selectedId: this.currentAction?.typeOf ?? 0,
      onChanged: (boond.AppDictApp v) {
        _log.fine("[_buildTypeOfField.onChanged] $v.id");

        this.currentAction?.typeOf = v.id;
      },
      idOf: (boond.AppDictApp e) => e.id,
      labelOf: (boond.AppDictApp e) => e.value,
    );
    return w;
  }

  Widget _buildTextField(BuildContext _context) {
    // currentAction could be null
    return BoondActionWidget(
      theAction: this.currentAction ?? BoondAction(),
      editEnabled: true,
      asChanged: (BoondAction a) {
        this.currentAction?.bodyText = a.bodyText;
      },
    );
  }

  void _handleEditingComplete() {
    _log.fine("[_handleEditingComplete] ");

    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(this.context);

    if ((this.currentAction != null) && this._formKey.currentState.validate())
      b.add(BoondActionUIEventChanged(action: this.currentAction));
  }

  Widget _buildFormWrapper(BuildContext _context) {
    return Form(
      key: this._formKey,
      onChanged: _handleEditingComplete,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Column(
            children: [
              _buildTypeOfField(_context),
              Expanded(child: _buildTextField(_context)),
            ],
          )),
    );
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
          BoondCandidateUIStateDisconnected().runtimeType,
          BoondCandidateUIStateConnected(infoMessage: null).runtimeType
        ];

        if (criteria.contains(state.runtimeType)) {
          BoondCandidateBloc candidateBloc =
              BlocProvider.of<BoondCandidateBloc>(_context);
          this.currentAction = candidateBloc.editedActions;
        }

        return criteria.contains(state.runtimeType);
      },
      builder: (BuildContext c, BoondCandidateUIState s) {
        // dont know why but have to locate the bloc.

        _log.fine("[build.builder] ");

        return _buildFormWrapper(c);
      },
    );
  }
}
