import 'package:firebase/app/hata_exception.dart';
import 'package:firebase/comman_widget/platform_duyarli_alert_diyalog.dart';
import 'package:firebase/model/user_model.dart';
import 'package:firebase/viewmodel/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum FormType { Register, LogIn }

class EmailveSifreLoginPage extends StatefulWidget {
  @override
  _EmailveSifreLoginPageState createState() => _EmailveSifreLoginPageState();
}

class _EmailveSifreLoginPageState extends State<EmailveSifreLoginPage> {
  String _email, _sifre;
  String _butonText, _linkText;
  var _formType = FormType.LogIn;
  final _formKey = GlobalKey<FormState>();
  void _formSubmit() async {
    _formKey.currentState.save();
    debugPrint("email" + _email + "sifre" + _sifre);
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_formType == FormType.LogIn) {
      try {
        User _girisYapanUser =
            await _userModel.signInWithEmailandPassword(_email.trim(), _sifre);
        if (_girisYapanUser != null)
          print("oturum açan " + _girisYapanUser.userID.toString());
      } on PlatformException catch (e) {
        PlatformDuyarliAlertDialog(
                baslik: "Oturum Açma Hata",
                icerik: Hatalar.goster(e.code),
                anaButonYazisi: 'Tamam')
            .goster(context);
      }
    } else {
      try {
        User _olusturulanUser = await _userModel.createUserWithEmailandPassword(
            _email.trim(), _sifre);
        if (_olusturulanUser != null)
          print("oturum açan " + _olusturulanUser.userID.toString());
      } on PlatformException catch (e) {
        PlatformDuyarliAlertDialog(
                baslik: "Kullanıcı Oluşturma Hata",
                icerik: Hatalar.goster(e.code),
                anaButonYazisi: 'Tamam')
            .goster(context);
      }
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.LogIn ? FormType.Register : FormType.LogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    _butonText = _formType == FormType.LogIn ? "Giriş Yap" : "Kayıt Ol";
    _linkText = _formType == FormType.LogIn
        ? "Hesabınız Yok Mu? Kayıt Olun."
        : "Hesabınız var Giriş Yapın";

    final _userModel = Provider.of<UserModel>(context, listen: true);
    /* if (_userModel.state == ViewState.Idle) {
      if (_userModel.user == null) {
        return HomePage();
      }
    } else {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }*/
    if (_userModel.user != null) {
      Future.delayed(Duration(milliseconds: 10), () {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
          title: Text("Giriş / Kayıt"),
        ),
        body: _userModel.state == ViewState.Idle
            ? SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          errorText: _userModel.emailHataMesaji != null
                              ? _userModel.emailHataMesaji
                              : null,
                          hintText: 'Email',
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (String girilenEmail) {
                          _email = girilenEmail;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          errorText: _userModel.sifreHataMesaji != null
                              ? _userModel.sifreHataMesaji
                              : null,
                          hintText: 'Sifre',
                          labelText: 'Sifre',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (String girilenSifre) {
                          _sifre = girilenSifre;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      RaisedButton(
                        child: Text(_butonText),
                        onPressed: () => _formSubmit(),
                        elevation: 0,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      FlatButton(
                          onPressed: () => _degistir(), child: Text(_linkText))
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
