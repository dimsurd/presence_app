import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_dimas/home_page.dart';
import 'package:uts_dimas/widgets/dialogs.dart';
import 'navigation.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);
  @override
  _PageLoginState createState() => _PageLoginState();
}

class HeadClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PageLoginState extends State<PageLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var txtEditUsername = TextEditingController();
  var txtEditPwd = TextEditingController();
  Widget inputUsername() {
    return TextFormField(
        cursorColor: Colors.black,
        keyboardType: TextInputType.text,
        autofocus: false,
        // validator: (email) => email != null && !EmailValidator.validate(email)
        // ? 'Masukkan email yang valid'
        // : null,
        validator: (String? arg) {
          if (arg == null || arg.isEmpty) {
            return 'Username can not blank';
          } else {
            return null;
          }
        },
        controller: txtEditUsername,
        onSaved: (String? val) {
          txtEditUsername.text = val!;
        },
        decoration: InputDecoration(
          hintText: 'Username',
          hintStyle: const TextStyle(color: Colors.grey),
          labelText: "Enter an Username",
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 16.0, color: Colors.grey));
  }

  Widget inputPassword() {
    return TextFormField(
      cursorColor: Colors.black,
      keyboardType: TextInputType.text,
      autofocus: false,
      obscureText: true, //make decript inputan
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Password can not blank';
        } else {
          return null;
        }
      },
      controller: txtEditPwd,
      onSaved: (String? val) {
        txtEditPwd.text = val!;
      },
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: "Enter a Password",
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Colors.grey,
        ),
        fillColor: Colors.grey,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2.0,
          ),
        ),
      ),
      style: const TextStyle(fontSize: 16.0, color: Colors.grey),
    );
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState!.save();
      doLogin(txtEditUsername.text, txtEditPwd.text);
    }
  }

  doLogin(username, password) async {
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "Processing ...");

    try {
      final response = await http.post(
          Uri.parse("https://nscis.nsctechnology.com/index.php?r=auth/login"),
          body: {
            "username": username,
            "password": password,
          }).then((value) {
        var data = jsonDecode(value.body);
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            data['message'],
            style: const TextStyle(fontSize: 16),
          )),
        );
        if (data['success'] == true) {
          saveSession(username);
        }
      });
    } catch (e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
      debugPrint('$e');
    }
  }

  saveSession(String username) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("username", username);
    await pref.setBool("is_login", true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(),
      ),
      (route) => false,
    );
  }

  // void ceckLogin() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   var islogin = pref.getBool("is_login");
  //   if (islogin != null && islogin) {
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         builder: (BuildContext context) => HomePage(),
  //       ),
  //       (route) => false,
  //     );
  //   }
  // }

  @override
  void initState() {
    // ceckLogin();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: Colors.blueAccent,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white24,
              image: DecorationImage(
                image: AssetImage('assets/images/circle_login.png'),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ClipPath(
                    clipper: HeadClipper(),
                    child: Container(
                      margin: const EdgeInsets.all(0),
                      width: double.infinity,
                      height: 363,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/login_ilustration.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                      padding: EdgeInsets.only(left: 20),
                      child: RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Stay connected\neach ',
                                style: TextStyle(fontSize: 32)),
                            TextSpan(
                                text: 'others',
                                style: const TextStyle(
                                    color: Color(0xff25388D),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                  // Container(
                  //   padding: const EdgeInsets.all(8.0),
                  //   alignment: Alignment.center,
                  //   child: const Text(
                  //     "LOGIN APP BIU-HRIS",
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 22,
                  //         fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  Container(
                      padding: const EdgeInsets.only(
                          top: 35.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: <Widget>[
                          inputUsername(),
                          const SizedBox(height: 20.0),
                          inputPassword(),
                          const SizedBox(height: 5.0),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 35.0, left: 20.0, right: 20.0),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xff25388D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: const BorderSide(color: Colors.transparent),
                            ),
                            elevation: 10,
                            minimumSize: const Size(200, 58)),
                        onPressed: () => _validateInputs(),
                        icon: const Icon(Icons.arrow_right_alt),
                        label: const Text(
                          "LOG IN",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  ),
                  SizedBox(
                    height: 250,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
