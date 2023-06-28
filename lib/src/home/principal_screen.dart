import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';
import 'package:where_are_my_friends/widgets/user_link_widget.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  PrincipalScreenState createState() => PrincipalScreenState();
}

class PrincipalScreenState extends State<PrincipalScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final geo = GeoFlutterFire();

  bool light = false;
  LatLng currentPosition = LatLng(0, 0);

  Stream<Position> determinePositionTeste() async* {
    bool serviceEnabled;
    LocationPermission permission;
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Stream<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);

    await for (var position in positionStream) {
      yield position;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high, // Defina o nível de precisão desejado aqui
    );

    GeoFirePoint myLocation =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'position': myLocation.data});

    return position;
  }

  Stream<List<DocumentSnapshot>> getUserLocations(Position position) async* {
    GeoFirePoint center =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    double radius = 4.0;
    String field = 'position';

    var collectionReference = firestore.collection('users');

    yield* geo.collection(collectionRef: collectionReference).within(
        center: center, radius: radius, field: field, strictMode: false);
  }

  void delete() {
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'position': FieldValue.delete()});
  }

  void saveMessage() {
    String messageText = message.text;
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'message': messageText});
  }

  TextEditingController message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(tDefaultSize),
                child: Column(
                  children: [
                    TextFormField(
                      controller: message,
                      maxLength: 50,
                      style: const TextStyle(color: primaryColor),
                      decoration: const InputDecoration(
                        labelText: 'Mensagem',
                        labelStyle: TextStyle(color: primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        prefixIcon: Icon(
                          FontAwesomeIcons.comment,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        saveMessage();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                      ),
                      child: const Text('Salvar Mensagem'),
                    ),
                  ],
                ),
              ),
              Switch(
                value: light,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  if (!value) {
                    delete();
                  }
                  setState(() {
                    light = value;
                  });
                },
              ),
              if (light)
                FutureBuilder<Position>(
                  future: _determinePosition(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao obter a localização');
                    } else {
                      final position = snapshot.data;

                      final currentPosition =
                          LatLng(position!.latitude, position.longitude);
                      return Column(
                        children: [
                          Text(
                            'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          StreamBuilder<List<DocumentSnapshot>>(
                            stream: getUserLocations(position),
                            builder: (context, snapshotUsers) {
                              if (snapshotUsers.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshotUsers.hasError) {
                                return const Text(
                                    'Erro ao obter a localização dos usuários');
                              } else {
                                final userLocations = snapshotUsers.data;
                                List<Marker> markers = [];
                                List<Container> user = [];

                                if (userLocations != null) {
                                  markers = [];
                                  user = userLocations
                                      .where(
                                          (users) => users['position'] != null)
                                      .map((users) {
                                    final hasAvatarUrl =
                                        (users.data() as Map<String, dynamic>)
                                            .containsKey('avatarUrl');
                                    final geopoint =
                                        users['position']['geopoint'];
                                    final latitude =
                                        geopoint.latitude as double;
                                    final longitude =
                                        geopoint.longitude as double;
                                    final userLocation = geo.point(
                                      latitude: latitude,
                                      longitude: longitude,
                                    );

                                    final distance = userLocation.distance(
                                      lat: position.latitude,
                                      lng: position.longitude,
                                    );

                                    final bool hasMessage =
                                        (users.data() as Map<String, dynamic>)
                                            .containsKey('message');

                                    markers.add(
                                      Marker(
                                        point: LatLng(latitude, longitude),
                                        width: 200,
                                        height: 200,
                                        builder: (context) => Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (hasMessage &&
                                                users['message'] != '')
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.blue,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    users['message'] ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            hasAvatarUrl
                                                ? CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    foregroundImage:
                                                        NetworkImage(
                                                      users[
                                                          'avatarUrl'], // URL da imagem do Firebase Storage
                                                    ),
                                                  )
                                                : const Icon(Icons.person,
                                                    size: 20),
                                            Text(users['username']),
                                          ],
                                        ),
                                      ),
                                    );

                                    return Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 400),
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: UserLinkWidget(
                                        avatarUrl: hasAvatarUrl
                                            ? users['avatarUrl']
                                            : null,
                                        username: users['username'],
                                        fullname: users['fullname'],
                                        distance: distance,
                                      ),
                                    );
                                  }).toList();
                                }

                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 400,
                                      child: FlutterMap(
                                        options: MapOptions(
                                          center: currentPosition,
                                          maxZoom: 18,
                                          zoom: 16,
                                        ),
                                        nonRotatedChildren: [
                                          RichAttributionWidget(
                                            attributions: [
                                              TextSourceAttribution(
                                                'OpenStreetMap contributors',
                                                onTap: () => launchUrl(Uri.parse(
                                                    'https://openstreetmap.org/copyright')),
                                              ),
                                            ],
                                          ),
                                        ],
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName:
                                                'me.vitorsokubo.aonde',
                                          ),
                                          MarkerLayer(
                                            markers: markers,
                                          ),
                                          CircleLayer(
                                            circles: [
                                              CircleMarker(
                                                color: Colors.transparent,
                                                borderColor: Colors.black,
                                                borderStrokeWidth: 2.0,
                                                point: currentPosition,
                                                radius: 6000,
                                                useRadiusInMeter: true,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: user,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
