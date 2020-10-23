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
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider;

import 'package:boond_api/boond_api.dart' as boond
    show AppDictionnaryGet, AppDictAvailability, CandidateGet;

import '../../entity/MailNavigatorMessage.dart';
import '../../widget/BoondDropdownFormField.dart';

import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateUIState.dart';

class BasicCandidateForm extends StatefulWidget {
  static final Logger log = Logger("BasicCandidateForm");

  /// Default Constructor
  BasicCandidateForm() : super() {
    //log.level = Level.FINEST;
  }

  @override
  State<StatefulWidget> createState() => _BasicCandidateFormState();
}

class _BasicCandidateFormState extends State<BasicCandidateForm> {
  static final Logger log = Logger("BasicCandidateForm");

  final _formKey = GlobalKey<FormState>();
  final _emptyAvailabilityList = List<boond.AppDictAvailability>();

  @override
  initState() {
    super.initState();
  }

  Widget _buildCivilite(BuildContext c) {
    List<boond.AppDictAvailability> avail;

    BoondCandidateBloc candidateBloc = BlocProvider.of<BoondCandidateBloc>(c);
    boond.AppDictionnaryGet d = candidateBloc?.model?.application_dict;
    boond.CandidateGet shownCandidate = candidateBloc.editedCandidate;

    avail = d?.data?.setting?.civility ?? _emptyAvailabilityList;
    assert(avail != null);
    Widget w = BoondDropdownFormField<boond.AppDictAvailability>(
      entries: avail,
      selectedId: shownCandidate?.data?.attributes?.civility ?? 0,
      onChanged: (boond.AppDictAvailability v) {
        shownCandidate.data.attributes.civility = v.id;
      },
      onTap: _notifyChange,
      idOf: (dynamic e) => e.id,
      labelOf: (dynamic e) => e.value,
    );
    return w;
  }

  void _notifyChange() {
    log.fine("[_notifyChange] ");

    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(this.context);
    boond.CandidateGet shownCandidate = b.editedCandidate;

    b.add(BoondCandidateUIEventEditing(candidate: shownCandidate));
  }

  Widget _buildFirstName(BuildContext c) {
    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(c);
    boond.CandidateGet shownCandidate = b.editedCandidate;

    String v = shownCandidate?.data?.attributes?.firstName;
    return TextFormField(
      controller: TextEditingController(text: v),
      decoration: const InputDecoration(labelText: 'Firstname'),
      onChanged: (String v) {
        if (shownCandidate != null)
          shownCandidate.data.attributes.firstName = v.trim();
        _notifyChange();
      },
    );
  }

  Widget _buildLastName(BuildContext c) {
    TextFormField w;
    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(c);
    boond.CandidateGet shownCandidate = b.editedCandidate;

    String v = shownCandidate?.data?.attributes?.lastName;
    log.fine("[_buildLastName] build $v");

    w = TextFormField(
      controller: TextEditingController(text: v),
      decoration: const InputDecoration(labelText: 'Lastname'),
      onChanged: (String v) {
        log.fine("[_buildLastName] onChanged $v");

        shownCandidate.data.attributes.lastName = v.trim().toUpperCase();
        _notifyChange();
      },
      onEditingComplete: () {
        w.controller.text = shownCandidate.data.attributes.lastName;
      },
    );
    return w;
  }

  Widget _buildEmail(BuildContext c) {
    log.fine("[_buildEmail] builder");
    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(c);
    boond.CandidateGet shownCandidate = b.editedCandidate;

    String v = shownCandidate?.data?.attributes?.email1;
    log.fine("[_buildEmail] calling formfield $v");

    return TextFormField(
      controller: TextEditingController(text: v),
      decoration: const InputDecoration(labelText: 'Email'),
      maxLines: 1,
      validator: (String value) {
        if (value == null || value.isEmpty) return null;
        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Not a valid email';
        }
        return null;
      },
      onChanged: (String v) {
        shownCandidate.data.attributes.email1 = v.trim();
        _notifyChange();
      },
    );
  }

  Widget _buildPhone(BuildContext c) {
    BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(c);
    boond.CandidateGet shownCandidate = b.editedCandidate;

    String v = shownCandidate?.data?.attributes?.phone1;
    log.fine("[_buildPhone] builder $v");

    return TextFormField(
      controller: TextEditingController(text: v),
      decoration: const InputDecoration(labelText: 'Phone'),
      validator: (String value) {
        if (value == null || value.isEmpty) return null;

        //     if (!RegExp(r"[0-9.-+]+").hasMatch(value)) {
        //     return 'This is not a valid phone number';
        // }
        return null;
      },
      onChanged: (String v) {
        shownCandidate.data.attributes.phone1 = v.trim();
        _notifyChange();
      },
    );
  }

  Widget _buildStatus(BuildContext c) {
    List<boond.AppDictAvailability> avail;

    log.fine("[_buildStatus] builder");

    BoondCandidateBloc candidateBloc = BlocProvider.of<BoondCandidateBloc>(c);
    boond.AppDictionnaryGet d = candidateBloc?.model?.application_dict;
    boond.CandidateGet shownCandidate = candidateBloc.editedCandidate;

    log.fine("[_buildStatus] builder app dict a $d ");

    avail = d?.data?.setting?.state?.candidate ?? _emptyAvailabilityList;

    int v = shownCandidate?.data?.attributes?.state ?? 0;

    log.fine("[_buildStatus] default is a ${v} ");

    Widget w = BoondDropdownFormField<boond.AppDictAvailability>(
      entries: avail,
      selectedId: v,
      hint: const Text("Status"),
      onChanged: (boond.AppDictAvailability v) {
        log.fine("[_buildStatus] changing to ${v.value} ");
        shownCandidate.data.attributes.state = v.id;
      },
      onTap: _notifyChange,
      idOf: (dynamic e) => e.id,
      labelOf: (dynamic e) => e.value,
    );

    return w;
  }

  @override
  Widget build(BuildContext _context) {
    log.fine("[build] begin");
    return BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
        //bloc: BlocProvider.of<BoondCandidateBloc>(context),
        buildWhen:
            (BoondCandidateUIState previousState, BoondCandidateUIState state) {
      final List<Type> criteria = [
        BoondCandidateUIStateLookupDone(candidateFound: null).runtimeType,
        BoondCandidateUIStateLoaded(candidate: null).runtimeType,
        BoondCandidateUIStateDisconnected().runtimeType,
        BoondCandidateUIStateMergeSender(
                senderFullName: null, senderEmail: null)
            .runtimeType
      ];
      log.fine("[build] condition <${state}>");

      if (state is BoondCandidateUIStateMergeSender)
        _handleMergeEmail(state, _context);

      return criteria.contains(state.runtimeType);
    }, //
        builder: (BuildContext c, BoondCandidateUIState s) {
      log.fine("[build] builder");
      // TODO add a form validation with mandatory fields.
      Widget w = _buildFormWrapper(c);

      return _buildDragWrapper(w, _context);
    }); //;;
  }

  Widget _buildFormWrapper(BuildContext _context) {
    return Form(
      key: _formKey,
      child: Table(
        border: TableBorder(bottom: BorderSide(), verticalInside: BorderSide()),
        columnWidths: {
          0: FractionColumnWidth(0.4),
          1: FractionColumnWidth(0.6)
        },
        children: <TableRow>[
          TableRow(children: [
            Column(children: [
              _buildStatus(_context),
              _buildCivilite(_context),
              _buildPhone(_context),
            ]),
            Column(children: [
              _buildFirstName(_context),
              _buildLastName(_context),
              _buildEmail(_context),
            ])
          ]),
        ],
      ),
    );
  }

  Widget _buildDragWrapper(Widget parentW, BuildContext _context) {
    return DragTarget<MailNavigatorMessage>(
      builder: (BuildContext _context, List<MailNavigatorMessage> candidateData,
          List<dynamic> rejectedData) {
        return parentW;
      },
      onAccept: (MailNavigatorMessage data) {
        //String senderName = data.fromFullName;
        log.fine(" [_buildDragWrapper.onAccept] dragdrop accept ${data.from}");
        String senderMail = data.fromEmail;
        log.fine(" [_buildDragWrapper.onAccept] dragdrop accept $senderMail");
        BoondCandidateBloc boondBloc =
            BlocProvider.of<BoondCandidateBloc>(_context);
        if (!boondBloc.isConnected()) {
          boondBloc.add(BoondCandidateUIEventWarning(
              warningMessage: "please connect first"));
          return;
        }
        boondBloc.add(BoondCandidateUIEventLookupRequest(
            criteria: ["keywordsType=emails", "keywords=$senderMail"]));
      },
    );
  }

  void _handleMergeEmail(
      BoondCandidateUIStateMergeSender state, BuildContext c) {
    BoondCandidateBloc boondBloc = BlocProvider.of<BoondCandidateBloc>(c);
    boond.CandidateGet can = boondBloc.editedCandidate;

    assert(can != null);
    can.data.attributes.lastName = state.senderFullName;
    can.data.attributes.email1 = state.senderEmail;
  }
}
