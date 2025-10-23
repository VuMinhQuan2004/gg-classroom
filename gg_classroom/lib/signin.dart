import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gg_classroom/signup.dart';
import 'home_screen.dart';
import 'forget_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  String message = ""; // Biến thông báo lỗi hoặc thành công

  // =========================
  // Đăng nhập Email/Password
  // =========================
  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = "Vui lòng nhập đầy đủ thông tin!";
        isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      // setState(() {
      //   message = "Đăng nhập thành công!";
      // });

      // Chuyển màn hình sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'Tài khoản hoặc mật khẩu sai.';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
          break;
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này.';
          break;
        case 'wrong-password':
          errorMessage = 'Mật khẩu không chính xác. Vui lòng thử lại.';
          break;
        case 'too-many-requests':
          errorMessage = 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
          break;
        default:
          errorMessage = '${e.message}';
      }
      setState(() => message = errorMessage);
    } catch (e) {
      setState(() => message = "Lỗi không xác định. Vui lòng thử lại.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =========================
  // Đăng nhập Google
  // =========================
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => message = "Người dùng đã hủy đăng nhập Google.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final dbRef = FirebaseDatabase.instance.ref("users/${user.uid}");
        await dbRef.set({
          "uid": user.uid,
          "name": user.displayName ?? "No Name",
          "email": user.email ?? "No Email",
          "photoUrl": user.photoURL ?? "",
          "loginMethod": "google",
          "createdAt": DateTime.now().toIso8601String(),
        });
        setState(() => message = "Đăng nhập Google thành công!");
      }

      return userCredential;
    } catch (e) {
      setState(() => message = "Lỗi đăng nhập Google: $e");
      return null;
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
            padding: const EdgeInsets.only(top: 80.0, left: 30.0, right: 30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back 👋",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Continue your learning journey!",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 8),

                  // =========================
                  // Email
                  // =========================
                  _inputField(emailController, "Enter your email...", icon: Icons.email),
                  const SizedBox(height: 20.0),

                  // =========================
                  // Password
                  // =========================
                  _inputField(
                    passwordController,
                    "Enter your password...",
                    icon: Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 10.0),

                  // =========================
                  // Forgot Password
                  // =========================
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // =========================
                  // Message hiển thị trực tiếp trên UI
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

                  // =========================
                  // Sign In Button
                  // =========================
                  GestureDetector(
                    onTap: isLoading ? null : _signIn,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // =========================
                  // Create Account link
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? ", style: TextStyle(fontSize: 13.0)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),

                  // =========================
                  // Social login Google (button)
                  // =========================
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        await loginWithGoogle();
                        if (message.contains("thành công")) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "images/google.png",
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Đăng nhập bằng Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Input field có icon + mật khẩu show/hide
  // =========================
  Widget _inputField(TextEditingController controller, String hint,
      {bool obscure = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure ? _obscurePassword : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
