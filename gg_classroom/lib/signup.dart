import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gg_classroom/signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  bool isLoading = false;

  Future<void> _signUp() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirm = confirmController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage("Vui lòng nhập đầy đủ thông tin!");
      return;
    }
    if (password != confirm) {
      _showMessage("Mật khẩu không khớp!");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Tạo tài khoản Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Lưu thông tin vào Realtime Database
      await _dbRef.child(uid).set({
        "username": username,
        "email": email,
      });

      _showMessage("Đăng ký thành công!");
    } on FirebaseAuthException catch (e) {
      String msg = "Lỗi không xác định!";
      if (e.code == 'email-already-in-use') msg = "Email này đã được sử dụng!";
      if (e.code == 'weak-password') msg = "Mật khẩu quá yếu!";
      if (e.code == 'invalid-email') msg = "Email không hợp lệ!";
      _showMessage(msg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "images/bg.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Create Account!",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold)),
                  Text("Start your study today!",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: MediaQuery.of(context).size.height / 8),

                  // Username
                  _inputField(usernameController, "Enter your username..."),
                  SizedBox(height: 20.0),

                  // Email
                  _inputField(emailController, "Enter your email..."),
                  SizedBox(height: 20.0),

                  // Password
                  _inputField(passwordController, "Enter your password...",
                      obscure: true),
                  SizedBox(height: 20.0),

                  // Confirm Password
                  _inputField(confirmController, "Confirm password",
                      obscure: true),
                  SizedBox(height: 20.0),

                  // Sign Up Button
                  GestureDetector(
                    onTap: isLoading ? null : _signUp,
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.only(right: 30.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Sign Up",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // Social login icons
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Image.asset("images/google.png",
                  //         height: 50, width: 50, fit: BoxFit.cover),
                  //     SizedBox(width: 50.0),
                  //     Image.asset("images/fb.png",
                  //         height: 50, width: 50, fit: BoxFit.cover),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                        child: Text(
                          "Sign in now",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Container(
      padding: EdgeInsets.only(left: 15.0),
      margin: EdgeInsets.only(right: 30.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(115, 0, 0, 0), width: 2.0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }
}
