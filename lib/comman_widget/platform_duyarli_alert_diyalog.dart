import 'dart:io';

import 'package:firebase/comman_widget/platform_duyarli_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformDuyarliAlertDialog extends PlatformDuyarliWidget {
  final String baslik;
  final String icerik;
  final String anaButonYazisi;
  final String iptalButonYazisi;

  Future<bool> goster(BuildContext context) async {
    return Platform.isIOS
        ? showCupertinoDialog(context: context, builder: (context) => this)
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false);
  }

  PlatformDuyarliAlertDialog(
      {@required this.baslik,
      @required this.icerik,
      @required this.anaButonYazisi,
      this.iptalButonYazisi});

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
        title: Text(baslik),
        content: Text(icerik),
        actions: _dialogButonlariniAyarla(context));
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
        title: Text(baslik),
        content: Text(icerik),
        actions: _dialogButonlariniAyarla(context));
  }

  List<Widget> _dialogButonlariniAyarla(BuildContext context) {
    final tumButonlar = <Widget>[];
    if (Platform.isIOS) {
      if (iptalButonYazisi != null) {
        tumButonlar.add(
          CupertinoDialogAction(
            child: Text(iptalButonYazisi),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }

      tumButonlar.add(
        CupertinoDialogAction(
          child: Text(anaButonYazisi),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    } else {
      if (iptalButonYazisi != null) {
        tumButonlar.add(
          FlatButton(
            child: Text(iptalButonYazisi),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }

      tumButonlar.add(
        FlatButton(
          child: Text("Tamam"),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    }

    return tumButonlar;
  }
}
