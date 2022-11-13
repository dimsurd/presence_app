import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'clocking.dart';

class PresencePage extends StatefulWidget {
  File? imagefile;
  LatLng? initPosition;
  String? address;
  String? id_user;
  PresencePage(
      {Key? key,
      @required this.imagefile,
      this.initPosition,
      this.address,
      this.id_user})
      : super(key: key);
  @override
  State<PresencePage> createState() => _PresencePageState(
      imageFile: imagefile,
      initposition: initPosition,
      addr: address,
      ID: id_user);
}

class _PresencePageState extends State<PresencePage> {
  final _formKey = GlobalKey<FormState>();
  File? imageFile;
  LatLng? initposition;
  String? addr;
  String? ID;
  String? base64Image;
  _PresencePageState({this.imageFile, this.initposition, this.addr, this.ID});
  var IDUser = TextEditingController();
  var Latitude = TextEditingController();
  var Longtitude = TextEditingController();
  var Location = TextEditingController();
  var Photo = TextEditingController();
  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    _getData();
  }

  Future _getData() async {
    try {
      Uint8List imagebytes = await imageFile!.readAsBytes(); //convert to bytes
      String base64Image =
          base64.encode(imagebytes); //convert bytes to base64 string

      String fileName = imageFile!.path.split('/').last;
      if (mounted)
        setState(() {
          IDUser = TextEditingController(text: '${ID}');
          Latitude = TextEditingController(text: '${initposition!.latitude}');
          Longtitude =
              TextEditingController(text: '${initposition!.longitude}');
          Location = TextEditingController(text: '${addr}');
          Photo = TextEditingController(text: '${base64Image}');
        });
    } catch (e) {
      print(e);
    }
  }

  Future _onUpdate(context) async {
    try {
      var postUri = Uri.parse(
          "https://nscis.nsctechnology.com/index.php?r=precense/create-api");
      http.MultipartRequest request =
          new http.MultipartRequest("POST", postUri);
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('photo_precense', imageFile!.path);

      // request.fields['user_id'] = '106';
      // request.fields['latitude'] = '35.6762';
      // request.fields['longitude'] = '139.6503';
      // request.fields['location'] = 'testapp';

      request.fields['user_id'] = IDUser.text;
      request.fields['latitude'] = Latitude.text;
      request.fields['longitude'] = Longtitude.text;
      request.fields['location'] = Location.text;
      request.files.add(multipartFile);
      EasyLoading.show(status: 'Uploading Image...');
      var response = await request.send();
      // print('responnya');
      // print(response.statusCode);
      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Clocking Success!');
        // Navigator.of(context)
        // .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Clocking()),
            (Route<dynamic> route) => false);

        EasyLoading.dismiss();
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
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
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 10),
              width: 300,
              height: 400,
              color: Color(0xff25388D),
              child: (imageFile != null) ? Image.file(imageFile!) : SizedBox(),
            ),
            //Text('${imageFile}'),
            Container(
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Visibility(
                          child: TextFormField(
                            readOnly: true,
                            enabled: true,
                            controller: IDUser,
                            decoration: InputDecoration(
                                hintText: "Type Note Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                fillColor: Colors.white,
                                filled: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Note Title is Required!';
                              }
                              return null;
                            },
                          ),
                          visible: false,
                        ),
                        SizedBox(height: 5),
                        Visibility(
                          child: TextFormField(
                            controller: Latitude,
                            decoration: InputDecoration(
                                hintText: "Type Note Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                fillColor: Colors.white,
                                filled: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Note Title is Required!';
                              }
                              return null;
                            },
                          ),
                          visible: false,
                        ),
                        SizedBox(height: 5),
                        Visibility(
                          child: TextFormField(
                            controller: Longtitude,
                            decoration: InputDecoration(
                                hintText: "Type Note Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                fillColor: Colors.white,
                                filled: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Note Title is Required!';
                              }
                              return null;
                            },
                          ),
                          visible: false,
                        ),
                        Visibility(
                          child: TextFormField(
                            controller: Location,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: 'Type Note Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                fillColor: Colors.white,
                                filled: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Note Content is Required!';
                              }
                              return null;
                            },
                          ),
                          visible: false,
                        ),
                        Visibility(
                          child: TextFormField(
                            controller: Photo,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: 'Type Note Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                fillColor: Colors.white,
                                filled: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Note Content is Required!';
                              }
                              return null;
                            },
                          ),
                          visible: false,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xff30F7DF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                elevation: 10,
                                minimumSize: const Size(200, 58)),
                            onPressed: () {
                              //validate
                              if (_formKey.currentState!.validate()) {
                                //send data to database with this method
                                _onUpdate(context);
                              }
                            },
                            icon: const Icon(
                              CupertinoIcons.person_add_solid,
                              color: Colors.black,
                            ),
                            label: const Text(
                              "Absent Now",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
