import 'package:firebase/app/sign_in/email_sifre_giris_ve_kayit.dart';
import 'package:firebase/comman_widget/platform_duyarli_alert_diyalog.dart';
import 'package:firebase/comman_widget/social_login_button.dart';

import 'package:firebase/viewmodel/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';
import '../hata_exception.dart';

PlatformException myHata;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void googleIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _user = await _userModel.signInWithGoogle();
    if (_user != null)
      print("oturum açan user id" +
          _user.userID.toString() +
          _user.email.toString());
  }

  void facebookIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    try {
      User _user = await _userModel.signInWithFacebook();
      if (_user != null) {
        print("Oturum açan user id:" + _user.userID.toString());
      }
    } on PlatformException catch (e) {
      print("FACEBOOK HATA YAKALANDI :" + e.message.toString());
      myHata = e;
    }
  }

  void _emailveSifreGiris(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true, builder: (context) => EmailveSifreLoginPage()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (myHata != null)
        PlatformDuyarliAlertDialog(
          baslik: "Kullanıcı Oluşturma HATA",
          icerik: Hatalar.goster(myHata.code),
          anaButonYazisi: 'Tamam',
        ).goster(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trafik Çevirme"),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Oturum aç",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            SizedBox(
              height: 8,
            ),
            SocialLoginButton(
              butonIcon: Image.asset("images/googlelogo.png"),
              // butonIcon: Icon(Icons.email),
              butonColor: Colors.white,
              butonText: "Google ile Giriş Yap",
              textColor: Colors.black87,
              radius: 16,
              onPressed: () => googleIleGiris(context),
            ),
            SocialLoginButton(
              butonColor: Color(0xFF334D92),
              butonText: "Facebook ile Giriş Yap",
              butonIcon: Image(image: AssetImage("images/facebooklogo.png")),
              textColor: Colors.white,
              radius: 16,
              onPressed: () => facebookIleGiris(context),
            ),
            SocialLoginButton(
              butonColor: Colors.blueGrey,
              butonText: "Email ve Şifre  ile Giriş Yap",
              textColor: Colors.white,
              radius: 16,
              butonIcon: Icon(
                Icons.email,
                size: 30,
              ),
              onPressed: () => _emailveSifreGiris(context),
            ),
          ],
        ),
      ),
    );
  }
}
