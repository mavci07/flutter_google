import 'package:firebase/app/landing_page.dart';

import 'package:firebase/locator.dart';

import 'package:firebase/viewmodel/user_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  setupLocator();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserModel(),
        ),
        /*ChangeNotifierProvider(
          create: (context) => ApplicationBloc(),
        )*/
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LandingPage(),
      ),
    );
  }
}
