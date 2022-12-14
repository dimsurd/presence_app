import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:uts_dimas/camerapage.dart';
import 'dart:io';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Clocking extends StatefulWidget {
  const Clocking({Key? key}) : super(key: key);
  @override
  _ClockingState createState() => _ClockingState();
}

class _ClockingState extends State<Clocking> {
  File? imageFile;
  LatLng _initialcameraposition = LatLng(-6.2595697, 106.994477);
  GoogleMapController? _controller;
  Location _location = Location();
  Set<Marker> _markers = {};
  LocationData? _currentPosition;
  String? _address, _dateTime;
  String photo = "";
  String id = "";
  String username = "";
  List precenseUser = [];
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PageLogin(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
        "Berhasil logout",
        style: TextStyle(fontSize: 16),
      )),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
    getPref();
    _getData();
    _getPrecence();
  }

  Future _getData() async {
    print(username);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //get detail data with id
          "https://nscis.nsctechnology.com/index.php?r=user/view-api&id=$username"));
      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          photo = data["photo"];
          id = data["id"];
          //print(photo);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getPrecence() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          // "http://nscis.nsctechnology.com/index.php?r=precense/list"
          "https://nscis.nsctechnology.com/index.php?r=precense/user-api&id='${username}'"));
      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // entry data to variabel list _get
        setState(() {
          precenseUser = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  showImage(String image) {
    if (image.length % 4 > 0) {
      image += '=' * (4 - image.length % 4); // as suggested by Albert221
    }
    return Image.memory(
      base64Decode(image),
    );
  }

  void _onMapCreated(GoogleMapController _Cntlr) {
    _controller = _Cntlr;
    _location.onLocationChanged.listen((l) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
        ),
      );
      // print(l.latitude);
      // print(l.longitude);
      _initialcameraposition = LatLng(l.latitude!, l.latitude!);
      if (mounted) {
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId('Home'),
              position: LatLng(l.latitude ?? 0.0, l.longitude ?? 0.0)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff25388D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //leading: Icon(Icons.menu),
        title: Text("BIU"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              Container(
                child: Container(
                  margin: EdgeInsets.all(5),
                  height: 300,
                  color: Color(0xff25388D),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _initialcameraposition),
                        mapType: MapType.normal,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        markers: _markers,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: Colors.transparent,
                  child: precenseUser.isEmpty
                      ? Center(
                          child: Text(
                              'No data available for today, feel free to clock'))
                      : Expanded(
                          child: ListView.builder(
                              itemCount: precenseUser.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  child: Card(
                                    elevation: 5.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 55.0,
                                                height: 55.0,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  backgroundImage: NetworkImage(
                                                      'https://nscis.nsctechnology.com/' +
                                                          precenseUser[index]
                                                              ['photo']),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Clocking'),
                                                  Text(
                                                      precenseUser[index]
                                                          ['time'],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Date'),
                                                  Text(
                                                      precenseUser[index]
                                                          ['date'],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff30F7DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          elevation: 10,
                          minimumSize: const Size(200, 58)),
                      onPressed: () async {
                        imageFile = await Navigator.push<File>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CameraPage(
                                      iniPosition: _initialcameraposition,
                                      address: _address,
                                      id_user: id,
                                    )));
                        setState(() {});
                      },
                      icon: const Icon(
                        CupertinoIcons.right_chevron,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "Clocking",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _currentPosition = await _location.getLocation();
    _initialcameraposition = LatLng(
        _currentPosition!.latitude ?? 0.0, _currentPosition!.longitude ?? 0.0);
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // print("${currentLocation.longitude} : ${currentLocation.longitude}");
      if (mounted) {
        setState(() {
          _currentPosition = currentLocation;
          _initialcameraposition = LatLng(_currentPosition!.latitude ?? 0.0,
              _currentPosition!.longitude ?? 0.0);
          DateTime now = DateTime.now();
          _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
          _getAddress(_currentPosition!.latitude ?? 0.0,
                  _currentPosition!.longitude ?? 0.0)
              .then((value) {
            setState(() {
              _address = "${value.first.addressLine}";
            });
          });
        });
      }
    });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = Coordinates(lat, lang);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }
}
