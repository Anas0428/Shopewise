import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/data.dart';
import '../screens/registration.dart';
import '../screens/search_screen.dart';
import 'package:quickalert/quickalert.dart';

import 'package:form_field_validator/form_field_validator.dart';
// import 'package:rounded_loading_button/rounded_loading_button.dart'; // Disabled due to compatibility

import '../services/firebase_database.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool _isObscure = true;
  var email = TextEditingController();
  var password = TextEditingController();
  // final RoundedLoadingButtonController _btnController =
  //     RoundedLoadingButtonController(); // Disabled due to compatibility
  double height = 0, width = 0;

  // void onClickFun(RoundedLoadingButtonController btnController) async {
  //   Timer(Duration(seconds: 3), () {
  //     _btnController.success();
  //   });
  // }

  // void onClickFun2(RoundedLoadingButtonController btnController) async {
  //   Timer(Duration(seconds: 2), () {
  //     _btnController.error();
  //     Future.delayed(Duration(seconds: 1));
  //     _btnController.reset();
  //   });
  // }

  void myalert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Login Faild',
      text: 'Wrong Email or Password',
    );
  }

  void myalert1() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Login Successful',
      text: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: appData.isLoggedIn
            ? Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                        padding: EdgeInsets.only(top: 60.0, right: 260),
                        child: Icon(Icons.arrow_back_ios_new_sharp,
                            size: 25, color: Colors.black)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 300.0, left: 30),
                    child: Text(
                      'You are Already Logged In! Please Logout to Continue',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 70),
                    child: ElevatedButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        // _signOut();
                        // setState(() {
                        //   appData.isLoggedIn = false;
                        // });
                        setState(() {
                          appData.isLoggedIn = false;
                          appData.email = "You are not logged in";
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                    key: formkey,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: height * .3,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                image: DecorationImage(
                                  image: AssetImage('images/plants2.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 27),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: Icon(
                                                Icons.arrow_back_ios_new_sharp,
                                                size: 25,
                                                color: Colors.white)),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.more_horiz,
                                              size: 25, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                              ),
                              child: Container(
                                  height: height * .7,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50)))),
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 100.0, left: 140),
                        //   //ignore: avoid_unnecessary_containers
                        //   child: Container(
                        //       child: const Text(
                        //     "Sign In",
                        //     style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.normal,
                        //         fontSize: 40),
                        //   )),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 300.0, left: 40),
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.027,
                            ),
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              //elevation: 7.0,
                              //shadowColor: Colors.grey,
                              child: TextFormField(
                                controller: email,
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(
                                        errorText: 'Email Required'),
                                    EmailValidator(
                                        errorText: 'Please enter a valid Email')
                                  ],
                                ).call,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    size: 20,
                                  ),
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[450],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        width: 0.15, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 390.0, left: 40),
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.015,
                            ),
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              // elevation: 7.0,
                              //shadowColor: Colors.grey,
                              child: TextFormField(
                                obscureText: _isObscure,

                                // validation
                                controller: password,
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(
                                        errorText: 'Password Required'),
                                  ],
                                ).call,

                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      }),
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[450],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    //borderSide: const BorderSide(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 470.0, left: 170),
                        //   child: Container(
                        //     // Setting the Alignment to Right
                        //     width: MediaQuery.of(context).size.width * 0.4,
                        //     alignment: Alignment.centerRight,
                        //     // Clickable Text
                        //     child: RichText(
                        //         text: const TextSpan(
                        //       text: "Forget?",
                        //       style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w300,
                        //           color: Color.fromRGBO(53, 108, 254, 1)),
                        //       // recognizer: TapGestureRecognizer()
                        //       //   ..onTap = () {
                        //       //     Navigator.push(
                        //       //       context,
                        //       //       MaterialPageRoute(
                        //       //         builder: (context) => Forget(),
                        //       //       ),
                        //       //     );
                        //       //   },
                        //     )),
                        //   ),
                        // ),
                        // 5. Login Button
                        Padding(
                          padding: const EdgeInsets.only(top: 500.0, left: 85),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.55,
                              height: 50,
                              child: PhysicalModel(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                                //elevation: 8.0,
                                // shadowColor: Colors.blue,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Tempo
                                    formkey.currentState?.validate();
                                    var objectFlutterApi = FlutterApi();
                                    var object = LoginCheck(email, password);

                                    if (object.validator() == "emptyEmail" ||
                                        object.validator() == "emptyPassword") {
                                      // If Invalid then Show the Error Message
                                      setState(() {
                                        // Please enter email and password
                                        // onClickFun2(_btnController);
                                      });
                                    } else if (await objectFlutterApi
                                            .check_login(
                                                email.text, password.text) ==
                                        true) {
                                      // If Valid then Navigate to the Home Screen
                                      setState(() {
                                        // Valid login
                                        appData.isLoggedIn = true;
                                        appData.email = email.text;
                                        // onClickFun(_btnController);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Search()),
                                        );
                                        myalert1();
                                      });
                                    } else if (await objectFlutterApi
                                            .check_login(
                                                email.text, password.text) ==
                                        false) {
                                      setState(() {
                                        myalert();
                                        // onClickFun2(_btnController);
                                      });
                                    }

                                    // End of Set State , // End of Set State
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )),
                        ),

                        //dont have account
                        Padding(
                          padding: const EdgeInsets.only(top: 580.0, left: 20),
                          child: Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: "Don't have an account?",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: " SignUp!",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              Color.fromRGBO(53, 108, 254, 1)),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate to SignUp
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Registration(),
                                            ),
                                          );
                                        },
                                    )
                                  ]),
                            ),
                          ),
                        ),
                        //logo of shopWise
                        const Padding(
                          padding: EdgeInsets.only(top: 230.0, left: 04),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    image: AssetImage("images/logo4.png"),
                                    width: 170),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom))
                      ],
                    )),
              ));
  }
}

class LoginCheck {
  // Variables
  var email = TextEditingController();
  var password = TextEditingController();
  var context = BuildContext;
  // Constructor
  LoginCheck(this.email, this.password);

  // Validating Email and Password
  String validator() {
    // If Email is Empty
    if (email.text == "") {
      return "emptyEmail"; // Error Message
    }
    // If Password is Empty
    else if (password.text == "") {
      return "emptyPassword"; // Error Message
    }

    // If Email is not Valid
    //else if (!EmailValidator.validate(email.text)) {
    //return "invalidEmail"; // Error Message
    //}
    // If Email and Password is Valid
    else {
      return "valid"; // Error Message
    }
  }
}
