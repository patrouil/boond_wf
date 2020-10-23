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
import 'package:flutter/material.dart';

import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class NotificationWrapper extends StyledToast {
  static final Logger log = Logger("NotificationWrapper");

  /// Default Constructor
  NotificationWrapper({@required Widget child})
      : super(
            textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
            backgroundColor: Color(0x99000000),
            borderRadius: BorderRadius.circular(5.0),
            textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
            toastAnimation: StyledToastAnimation.size,
            reverseAnimation: StyledToastAnimation.size,
            startOffset: Offset(0.0, -1.0),
            reverseEndOffset: Offset(0.0, -1.0),
            duration: Duration(seconds: 20),
            animDuration: Duration(seconds: 2), // la vitesse apparition
            alignment: Alignment.bottomCenter,
            toastPositions: StyledToastPosition.bottom,
            curve: Curves.fastOutSlowIn,
            reverseCurve: Curves.fastOutSlowIn,
            dismissOtherOnShow: true,
            movingOnWindowChange: true,
            locale: null,
            child: child) {
    //log.level = Level.FINE;
  }

  static _notificationShow(
      Widget w, Color bgcolor, Duration duration, String debugMsg) {
    log.fine("display message $debugMsg");

    if (duration == null) duration = Duration(seconds: 10);
    try {
      // EdgeInsets s;
      Widget toDisplay = Container(
          alignment: Alignment.center,
          width: 300,
          height: 50,
          decoration: BoxDecoration(
              color: bgcolor,
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: w);
      WidgetsFlutterBinding.ensureInitialized()
          .addPostFrameCallback((timeStamp) {
        try {
          log.fine("callback launch  $debugMsg");

          showToastWidget(
            toDisplay,
            duration: duration,
            // Duration animDuration,
            dismissOtherToast: false,
            movingOnWindowChange: false,
            // TextDirection textDirection,
            // Axis axis,
            // Offset startOffset,
            // Offset endOffset,
            // Offset reverseStartOffset,
            // Offset reverseEndOffset,
            // position : StyledToastAnimation.slideFromBottom,
            animation: StyledToastAnimation.slideFromBottom,
            //EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            //borderRadius: BorderRadius.vertical(
            //   top: Radius.elliptical(10.0, 20.0),
            //   bottom: Radius.elliptical(10.0, 20.0)),
            // textAlign: TextAlign.justify,
            // StyledToastAnimation reverseAnimation,
            // Curve curve,
            //Curve reverseCurve,
          );
        } catch (e, s) {
          log.shout("callback  error $debugMsg", e, s);
          return null;
        }
      });
    } catch (e, s) {
      log.shout("display error $debugMsg", e, s);
    }
  }

  static void showInfoNotification(String message) {
    NotificationWrapper._notificationShow(
        Text(message), Colors.greenAccent, null, "info");
  }

  static void showWarningNotification(String message) {
    NotificationWrapper._notificationShow(
        Row(children: [Icon(Icons.warning), Text(message)]),
        Colors.amberAccent,
        null,
        "warning");
  }

  static void showErrorNotification(String message) {
    NotificationWrapper._notificationShow(
        Row(children: [Icon(Icons.error), Text(message)]),
        Colors.redAccent,
        null,
        "warning");
  }
}
