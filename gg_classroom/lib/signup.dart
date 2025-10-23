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
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String message = ""; // Thông báo lỗi hoặc thành công

  Future<void> _signUp() async {
    String fullname = fullnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirm = confirmController.text.trim();

    if (fullname.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => message = "Vui lòng nhập đầy đủ thông tin!");
      return;
    }
    if (password != confirm) {
      setState(() => message = "Mật khẩu không khớp!");
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      // Tạo tài khoản Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      String uid = user!.uid;

      // Lưu thông tin vào Realtime Database
      await _dbRef.child(uid).set({
        "uid": uid,
        "loginMethod": "email",
        "name": fullname,
        "email": email,
        "photoURL": "",
        "createdAt": DateTime.now().toIso8601String(),
      });

      setState(() => message = "Đăng ký thành công!");

      // Chuyển sang SignIn sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String msg = "Lỗi không xác định!";
      if (e.code == 'email-already-in-use') msg = "Email này đã được sử dụng!";
      if (e.code == 'weak-password') msg = "Mật khẩu quá yếu!";
      if (e.code == 'invalid-email') msg = "Email không hợp lệ!";
      setState(() => message = msg);
    } finally {
      setState(() => isLoading = false);
    }
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
                  const Text(
                    "Create Account!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Start your study today!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 8),

                  // Fullname
                  _inputField(
                    controller: fullnameController,
                    hint: "Enter your full name...",
                    icon: Icons.person,
                    isName: true,
                  ),
                  const SizedBox(height: 20.0),

                  // Email
                  _inputField(
                    controller: emailController,
                    hint: "Enter your email...",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20.0),

                  // Password
                  _inputField(
                    controller: passwordController,
                    hint: "Enter your password...",
                    icon: Icons.lock,
                    obscure: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20.0),

                  // Confirm Password
                  _inputField(
                    controller: confirmController,
                    hint: "Confirm password",
                    icon: Icons.lock_outline,
                    obscure: true,
                    isPassword: true,
                    isConfirm: true,
                  ),
                  const SizedBox(height: 20.0),

                  // =========================
                  // Message UI
                  // =========================
                  if (message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.contains("thành công") ? Colors.green[200] : Colors.red[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            message.contains("thành công") ? Icons.check_circle : Icons.error,
                            color: message.contains("thành công") ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Sign Up Button
                  GestureDetector(
                    onTap: isLoading ? null : _signUp,
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(right: 30.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignIn()),
                          );
                        },
                        child: const Text(
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
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    bool isName = false,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 30.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(115, 0, 0, 0),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure
            ? (isConfirm ? _obscureConfirm : _obscurePassword)
            : false,
        onEditingComplete: () {
          if (isName) {
            String value = controller.text;
            String formatted = value
                .trim()
                .split(RegExp(r'\s+'))
                .map((word) => word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                    : '')
                .join(' ');
            controller.value = controller.value.copyWith(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        },
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(
                    isConfirm
                        ? (_obscureConfirm ? Icons.visibility_off : Icons.visibility)
                        : (_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirm) {
                        _obscureConfirm = !_obscureConfirm;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
