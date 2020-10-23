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

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class EmailFormField extends TextFormField {
  /// Default Constructor
  EmailFormField({
    Key key,
    TextEditingController controller,
    String initialValue,
    FocusNode focusNode,
    InputDecoration decoration,
    TextInputType keyboardType,
    TextCapitalization textCapitalization,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical,
    bool autofocus,
    bool readOnly,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool autocorrect,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    bool autovalidate = false,
    bool maxLengthEnforced = true,
    int maxLines,
    int minLines,
    bool expands,
    int maxLength,
    ValueChanged<String> onChanged,
    GestureTapCallback onTap,
    VoidCallback onEditingComplete,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatters,
    bool enabled,
    double cursorWidth,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding,
    bool enableInteractiveSelection,
    InputCounterWidgetBuilder buildCounter,
    ScrollPhysics scrollPhysics,
    Iterable<String> autofillHints,
  }) : super(
          key: key,
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          decoration: decoration = InputDecoration(labelText: 'Email'),
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          style: style,
          strutStyle: strutStyle,
          textDirection: textDirection,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          autofocus: autofocus,
          readOnly: readOnly,
          toolbarOptions: toolbarOptions,
          showCursor: showCursor,
          autocorrect: autocorrect,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          enableSuggestions: enableSuggestions,
          maxLengthEnforced: maxLengthEnforced,
          maxLines: maxLines = 1,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          validator: (String value) {
            if (!RegExp(
                    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
              return 'This is not a valid email';
            }
            return null;
          },
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorColor: cursorColor,
          keyboardAppearance: keyboardAppearance,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          buildCounter: buildCounter,
          scrollPhysics: scrollPhysics,
          autofillHints: autofillHints,
        );
}
