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

  Future<void> _signIn() async {
    setState(() => isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

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
          errorMessage = 'Đã xảy ra lỗi ${e.code}: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi không xác định. Vui lòng thử lại.")),
      );
    } finally {
      setState(() => isLoading = false);
    }

  }

  

  Future<UserCredential?> loginWithGoogle() async {
    try {
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Người dùng đã hủy đăng nhập Google.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // Ghi thông tin user vào Realtime Database
        final dbRef = FirebaseDatabase.instance.ref("users/${user.uid}");

        await dbRef.set({
          "uid": user.uid,
          "name": user.displayName ?? "No Name",
          "email": user.email ?? "No Email",
          "photoUrl": user.photoURL ?? "",
          "loginMethod": "google",
          "createdAt": DateTime.now().toIso8601String(),
        });

        print("✅ Đã lưu thông tin người dùng Google vào Database");
      }

      return userCredential;
    } catch (e) {
      print("❌ Lỗi đăng nhập Google: $e");
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
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Continue your learning journey!",
                    style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 8),

                  // Email
                  _inputField(emailController, "Enter your email..."),
                  SizedBox(height: 20.0),

                  // Password
                  _inputField(passwordController, "Enter your password...",
                      obscure: true),
                  SizedBox(height: 10.0),

                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                          );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          //decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),

                  // Sign In Button
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
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
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
                  SizedBox(height: 20.0),

                  // Create Account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account? ",
                          style: TextStyle(fontSize: 13.0)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        child: Text(
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
                  SizedBox(height: 30.0),

                  // Social login icons
                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // Nút Google
    GestureDetector(
      onTap: () async {
        try {
          await loginWithGoogle();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi đăng nhập Google: $e")),
          );
        }
      },
      child: Image.asset(
        "images/google.png",
        height: 50,
        width: 50,
        fit: BoxFit.cover,
      ),
    ),

    const SizedBox(width: 50.0),

    // Nút Facebook
    Image.asset(
      "images/fb.png",
      height: 50,
      width: 50,
      fit: BoxFit.cover,
    ),
  ],
)

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Container(
      padding: EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
