import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase/blocs/application_blocs.dart';
import 'package:firebase/comman_widget/platform_duyarli_alert_diyalog.dart';

//import 'package:firebase/locator.dart';
import 'package:firebase/viewmodel/user_model.dart';

import 'package:flutter/services.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart' as geoCo;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Firestore _firestore = Firestore.instance;
  Position position;
  //Completer<GoogleMapController> controller = Completer();
  GoogleMapController _controller;
  String addressLocation;
  String createdAt;
  String country;
  String postalCode;
  List<Marker> _markers = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor mapMarker;
  var resim = '';
  GooglePlayServicesAvailability _playStoreAvailability =
      GooglePlayServicesAvailability.unknown;

  Future<void> checkPlayServices([bool showDialog = false]) async {
    GooglePlayServicesAvailability playStoreAvailability;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      playStoreAvailability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability(showDialog);
    } on PlatformException {
      playStoreAvailability = GooglePlayServicesAvailability.unknown;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _playStoreAvailability = playStoreAvailability;
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    setCustomMarker();
    populateClients();
  }

  String _address;

  void getCurrentLocation() async {
    Position currentPosition =
        await GeolocatorPlatform.instance.getCurrentPosition();
    setState(() {
      position = currentPosition;
    });
  }

  /*Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId("h"),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'asd', snippet: _address),
      ),
    ].toSet();
  }*/

  populateClients() {
    setState(() {
      _firestore.collection('locations').getDocuments().then((docs) {
        if (docs.documents.isNotEmpty) {
          // print(docs.documents.last.data);
          for (int i = 0; i < docs.documents.length; i++) {
            initMarker(docs.documents[i].data, docs.documents[i].documentID);

            //print(docs.documents[i].data['createdat'].toDate().toString());
            // print(docs.documents[i].documentID);
          }
        }
      });
    });
  }

  void initMarker(request, requesId) async {
    //var times = request['createdat'].toDate();

    var markerIdVal = requesId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(request['location'].latitude, request['location'].longitude),
        //LatLng(request['location'].latitude, request['location'].longitude), ÇALIŞAN HALİ
        infoWindow: InfoWindow(
            title: request['markertipi'],
            snippet: request['createdat'] != null
                ? request['createdat'].toDate().toString()
                : ""),
        icon: mapMarker);
    // print(request['createdat'].toDate().toString());
    setState(() {
      markers[markerId] = marker;
    });

    // DateTime dateTime = request['createdat'].toDate();
    //print(dateTime);
  }

  setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      resim,
    );
  }

  @override
  Widget build(BuildContext context) {
    void modal() {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 100,
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          icon: Image.asset('images/assets/vlc.png'),
                          onPressed: () async {
                            final coordinated = new geoCo.Coordinates(
                                position.latitude, position.longitude);
                            var address = await geoCo.Geocoder.local
                                .findAddressesFromCoordinates(coordinated);
                            var firstAddress = address.first;

                            await Firestore.instance
                                .collection('locations')
                                .add({
                              'location': GeoPoint(
                                  position.latitude, position.longitude),
                              //('location'): position.longitude.toDouble(),
                              'Address': firstAddress.addressLine,
                              'Country': firstAddress.countryName,
                              'PostalCode': firstAddress.postalCode,
                              'createdat': FieldValue.serverTimestamp(),
                              'markericon': 'vlcicon',
                              'markertipi': 'Radar',
                            });
                            setState(() {
                              country = firstAddress.countryName;
                              postalCode = firstAddress.postalCode;
                              addressLocation = firstAddress.addressLine;
                              createdAt =
                                  FieldValue.serverTimestamp().toString();
                              resim = 'images/assets/vlc.png';
                            });
                            print(DateTime.now());
                            setState(() {});
                            setState(() {
                              setCustomMarker().whenComplete(() {
                                _markers.add(Marker(
                                  markerId: MarkerId(LatLng(
                                          coordinated.latitude,
                                          coordinated.longitude)
                                      .toString()),
                                  position: LatLng(
                                      position.latitude, position.longitude),
                                  draggable: true,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueCyan),
                                  infoWindow: InfoWindow(
                                    title: addressLocation,
                                    snippet: createdAt,
                                  ),
                                ));
                              });
                            });
                            populateClients();

                            Navigator.pop(context);
                          }),
                      Text(
                        'Radar',
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Image.asset('images/assets/policecar1.png'),
                        tooltip: 'Increase volume by 10',
                        onPressed: () async {
                          final coordinated = new geoCo.Coordinates(
                              position.latitude, position.longitude);
                          var address = await geoCo.Geocoder.local
                              .findAddressesFromCoordinates(coordinated);
                          var firstAddress = address.first;

                          await Firestore.instance.collection('locations').add({
                            'location':
                                GeoPoint(position.latitude, position.longitude),
                            //('location'): position.longitude.toDouble(),
                            'Address': firstAddress.addressLine,
                            'Country': firstAddress.countryName,
                            'PostalCode': firstAddress.postalCode,
                            'createdat': FieldValue.serverTimestamp(),
                            'markericon': 'policecaricon',
                            'markertipi': 'Trafik Cevirme',
                          });
                          setState(() {
                            country = firstAddress.countryName;
                            postalCode = firstAddress.postalCode;
                            addressLocation = firstAddress.addressLine;
                            createdAt = FieldValue.serverTimestamp().toString();
                            resim = 'images/assets/policecar1.png';
                          });
                          print(DateTime.now());
                          setState(() {});
                          setCustomMarker().whenComplete(() {
                            setState(() {
                              _markers.add(Marker(
                                markerId: MarkerId(LatLng(coordinated.latitude,
                                        coordinated.longitude)
                                    .toString()),
                                position: LatLng(
                                    position.latitude, position.longitude),
                                draggable: true,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueCyan),
                                infoWindow: InfoWindow(
                                  title: addressLocation,
                                  snippet: createdAt,
                                ),
                              ));
                            });
                          });
                          populateClients();
                          Navigator.pop(context);
                        },
                      ),
                      Text('Kontrol Noktası')
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Image.asset('images/assets/radar5.png'),
                        tooltip: 'Increase volume by 10',
                        onPressed: () async {
                          final coordinated = new geoCo.Coordinates(
                              position.latitude, position.longitude);
                          var address = await geoCo.Geocoder.local
                              .findAddressesFromCoordinates(coordinated);
                          var firstAddress = address.first;

                          await Firestore.instance.collection('locations').add({
                            'location':
                                GeoPoint(position.latitude, position.longitude),
                            //('location'): position.longitude.toDouble(),
                            'Address': firstAddress.addressLine,
                            'Country': firstAddress.countryName,
                            'PostalCode': firstAddress.postalCode,
                            'createdat': FieldValue.serverTimestamp(),
                            'markericon': 'sabit Radar icon',
                            'markertipi': 'Sabit Radar',
                          });
                          setState(() {
                            country = firstAddress.countryName;
                            postalCode = firstAddress.postalCode;
                            addressLocation = firstAddress.addressLine;
                            createdAt = FieldValue.serverTimestamp().toString();
                          });
                          print(DateTime.now());
                          setState(() {
                            resim = 'images/assets/radar5.png';
                          });
                          setCustomMarker().whenComplete(() {
                            setState(() {
                              _markers.add(Marker(
                                markerId: MarkerId(LatLng(coordinated.latitude,
                                        coordinated.longitude)
                                    .toString()),
                                position: LatLng(
                                    position.latitude, position.longitude),
                                draggable: true,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueCyan),
                                infoWindow: InfoWindow(
                                  title: addressLocation,
                                  snippet: createdAt,
                                ),
                              ));
                            });
                          });
                          populateClients();
                          Navigator.pop(context);
                        },
                      ),
                      Text('Google')
                    ],
                  ),
                ],
              ));
        },
      );
    }

    /*void asdasd() async {
      await Firestore.instance.document('locations').delete(.where:GeoPoint(position.latitude,position.longitude));
        
                            'location':
                                GeoPoint(position.latitude, position.longitude),
                            //('location'): position.longitude.toDouble(),
                            'Address': firstAddress.addressLine,
                            'Country': firstAddress.countryName,
                            'PostalCode': firstAddress.postalCode,
                            'createdat': FieldValue.serverTimestamp(),
                            'markericon': 'sabit Radar icon',
                            'markertipi': 'Sabit Radar',
                          
    }*/

    void _onAddMarkerButtonPressed(double lat, double long) {
      MarkerId markerId = MarkerId(lat.toString() + long.toString());
      Marker _marker = Marker(
          markerId: markerId,
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(snippet: addressLocation));
      setState(() {
        markers[markerId] = _marker;
      });
    }

    /*final CameraPosition _initialPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18);*/

    void _onMapCreated(GoogleMapController controller) {
      setState(() {
        controller.setMapStyle(Utils.mapstyle);
        controller = _controller;
      });

      /* setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('id-1'),
            position: LatLng(applicationBloc.currentLocation.latitude,
                applicationBloc.currentLocation.longitude),
            icon: mapMarker,
            infoWindow: InfoWindow(title: 'AQAQ', snippet: 'ABAB'),
          ),
        );
      });*/
    }

    return Scaffold(
      body: (position == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude.toDouble(),
                      position.longitude.toDouble()),
                  zoom: 16),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              //onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              //markers: Set.from(_markers),

              myLocationEnabled: true,
              compassEnabled: true,
              //tiltGesturesEnabled: false,
              myLocationButtonEnabled: true,
            ),
      appBar: AppBar(
        leading: Image.asset("images/assets/policecar1.png"),
        actions: <Widget>[
          FlatButton(
              onPressed: () => checkPlayServices(),
              child: Text(
                "'Google Play Store status: ${_playStoreAvailability.toString().split('.').last}\n')),",
                style: TextStyle(color: Colors.white),
              )),
          FlatButton(
            onPressed: () => checkPlayServices(true),
            child: Text('asd'),
          )
        ],
        title: Text("Ana Sayfa"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.menu), onPressed: () {}),
            Spacer(),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final coordinated = new geoCo.Coordinates(
                      position.latitude, position.longitude);
                  var address = await geoCo.Geocoder.local
                      .findAddressesFromCoordinates(coordinated);
                  var firstAddress = address.first;

                  await Firestore.instance
                      .collection('locations')
                      .getDocuments()
                      .then((value) {
                    value.documents.forEach((element) {
                      Firestore.instance
                          .collection("locations")
                          .document(element.documentID)
                          .delete()
                          .then((value) {
                        print("Success!");
                        markers.clear();
                        //_markers.removeLast();
                      });
                    });
                  });
                  setState(() {
                    country = firstAddress.countryName;
                    postalCode = firstAddress.postalCode;
                    addressLocation = firstAddress.addressLine;
                    createdAt = FieldValue.serverTimestamp().toString();
                    //resim = '';

                    //_markers.removeLast();
                    markers.clear();
                  });
                }),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              modal();
            });
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Utils {
  static String mapstyle = '''
 [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  
  ''';
}

Future<bool> _cikisYap(BuildContext context) async {
  final _userModel = Provider.of<UserModel>(context, listen: false);
  bool sonuc = await _userModel.signOut();
  return sonuc;
}

Future _cikisIcinOnay(BuildContext context) async {
  final sonuc = await PlatformDuyarliAlertDialog(
    baslik: "Emin misiniz?",
    icerik: "Çıkmak İstiyor Musunuz?",
    anaButonYazisi: "evet",
    iptalButonYazisi: "Vazgeç",
  ).goster(context);
  if (sonuc == true) {
    _cikisYap(context);
  }
}

/*Center(
        child: Text("Hoşgeldiniz${widget.user.email}"),
      ),*/
