import 'package:flutter/services.dart';

class CnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var d = n.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 14) d = d.substring(0, 14);
    var r = '';
    for (int i = 0; i < d.length; i++) {
      if (i == 2 || i == 5) r += '.';
      if (i == 8) r += '/';
      if (i == 12) r += '-';
      r += d[i];
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var d = n.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 11) d = d.substring(0, 11);
    var r = '';
    if (d.isNotEmpty) {
      r += '(';
      for (int i = 0; i < d.length; i++) {
        if (i == 2) r += ') ';
        if (d.length <= 10 && i == 6) r += '-';
        if (d.length == 11 && i == 7) r += '-';
        r += d[i];
      }
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}