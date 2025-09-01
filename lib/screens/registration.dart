import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../services/firebase_database.dart';
import 'login_screen.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  var email = TextEditingController();
  var name = TextEditingController();

  var phoneNumber = TextEditingController();
  var password = TextEditingController();
  var otp = TextEditingController();
  bool _isObscure = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  double height = 0, width = 0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formkey,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: height * .15,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100))),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Container(
                      height: height * .7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      )),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 190.0, left: 40),
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.027,
                ),
                width: MediaQuery.of(context).size.width * 0.82,
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  // elevation: 7.0,
                  // shadowColor: Colors.grey,
                  child: TextFormField(
                    controller: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email Required';
                      } else {
                        RegExp regExp = RegExp(
                          r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          caseSensitive: false,
                          multiLine: false,
                        );

                        if (!regExp.hasMatch(value)) {
                          // Make input field red
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
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
                        borderSide:
                            const BorderSide(width: 0.15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 280.0, left: 40),
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.015,
                ),
                width: MediaQuery.of(context).size.width * 0.82,
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  // elevation: 7.0,
                  // shadowColor: Colors.grey,
                  child: TextFormField(
                    obscureText: _isObscure,

                    // validation
                    controller: password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password required';
                      } else {
                        RegExp regExp = RegExp(
                          r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                          caseSensitive: false,
                          multiLine: false,
                        );
                        if (!regExp.hasMatch(value)) {
                          // Make input field red
                          return 'Please enter a valid password';
                        }
                      }
                      return null;
                    },

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

            Padding(
              padding: const EdgeInsets.only(top: 352.0, left: 40),
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.027,
                ),
                width: MediaQuery.of(context).size.width * 0.82,
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  // elevation: 7.0,
                  // shadowColor: Colors.grey,
                  child: TextFormField(
                    controller: name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name required';
                      } else {
                        RegExp regExp = RegExp(
                          r"^[A-Za-z\s]*$",
                          caseSensitive: false,
                          multiLine: false,
                        );
                        if (!regExp.hasMatch(value)) {
                          // Make input field red
                          return 'Please enter a valid name';
                        }
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        size: 20,
                      ),
                      hintText: "Name",
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[450],
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(width: 0.15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 430.0, left: 40),
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.027,
                ),
                width: MediaQuery.of(context).size.width * 0.82,
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  // elevation: 7.0,
                  // shadowColor: Colors.grey,
                  child: TextFormField(
                    controller: phoneNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number required';
                      } else {
                        RegExp regExp = RegExp(
                          r"^[0-9]{11}$",
                          caseSensitive: false,
                          multiLine: false,
                        );
                        if (!regExp.hasMatch(value)) {
                          // Make input field red
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                    //allow only numbers

                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone_iphone_rounded,
                        size: 20,
                      ),
                      hintText: "Phone Number",
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[450],
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(width: 0.15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Submit Button
            Padding(
              padding: const EdgeInsets.only(top: 530.0, left: 85),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: 50,
                  child: PhysicalModel(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    // elevation: 8.0,
                    // shadowColor: Colors.blue,
                    child: ElevatedButton(
                      onPressed: () async {
                        var object1 = FlutterApi();
                        if (formkey.currentState!.validate()) {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Registering..."),
                                  ],
                                ),
                              );
                            },
                          );

                          try {
                            bool registrationResult = await object1.register(
                                email.text,
                                name.text,
                                phoneNumber.text,
                                password.text);

                            // Hide loading dialog
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            if (registrationResult == true) {
                              // Successfully added data
                              if (context.mounted) {
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Registration successful! Please login.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              }
                            } else {
                              // Registration failed - user already exists
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Registration Failed'),
                                      content: const Text(
                                          'Email already exists. Please use a different email or try logging in.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          } catch (e) {
                            // Hide loading dialog if still showing
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              // Show error message
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Connection Error'),
                                    content: const Text(
                                        'Unable to connect to the server. Please check your internet connection and try again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Submit",
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
              padding: const EdgeInsets.only(top: 600.0, left: 20),
              child: Container(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                      text: "Already have an account?",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: " SignIn!",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Color.fromRGBO(53, 108, 254, 1)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              })
                      ]),
                ),
              ),
            ),
            //logo of shopWise
            const Padding(
              padding: EdgeInsets.only(top: 110.0, left: 02),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: AssetImage("images/logo4.png"), width: 170),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom))
          ],
        ),
      ),
    ));
  }
}
