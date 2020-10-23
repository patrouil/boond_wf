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

import '../../widget/notification.dart';
import '../../widget/gadget_decoration.dart';
import 'BasicCandidateForm.dart';
import 'BoondCandidateActions.dart';
//import '../../business/BoondCandidateBloc.dart';
import 'CandidateActionForm.dart';

//const int MAX_CROSS_AXIS = 5;

class BoondCandidatePanel extends StatefulWidget {
  BoondCandidatePanel() : super();

  @override
  State<StatefulWidget> createState() => _BoondCandidatePanelState();
}

class _BoondCandidatePanelState extends State<BoondCandidatePanel> {
  //final BoondCandidateBloc _boondBloc = BoondCandidateBloc();

  @override
  void dispose() {
    super.dispose();
    //_boondBloc.close();
  }

  Widget _buildWrapper(BuildContext _context) {
    Color cb = GadgetDecoration.gadgetColor(_context);

    return NotificationWrapper(
        child: Column(
      children: [
        Expanded(
            flex: 30,
            child: GadgetDecoration(color: cb, child: BasicCandidateForm())),
        Expanded(
            flex: 60,
            child: GadgetDecoration(color: cb, child: CandidateActionForm())),
        Flexible(
            flex: 15,
            child: GadgetDecoration(color: cb, child: BoondCandidateActions()))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildWrapper(context);
  }
}
