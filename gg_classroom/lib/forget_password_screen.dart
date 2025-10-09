import 'package:flutter/material.dart';
import 'dart:ui'; // Để dùng BackdropFilter
import 'signin.dart'; // Để quay lại LoginScreen
import 'package:firebase_auth/firebase_auth.dart'; // Để sử dụng sendPasswordResetEmail

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    // Kiểm tra định dạng email cơ bản, chấp nhận @gmail.com, @yahoo.com
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email) && 
           (email.endsWith('@gmail.com') || email.endsWith('@yahoo.com'));
  }

  Future<void> _sendResetEmail() async {
  final email = _emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Vui lòng nhập email!')));
    return;
  }

  if (!_isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email không hợp lệ! Vui lòng nhập đúng định dạng.')),
    );
    return;
  }

  try {
    await _auth.sendPasswordResetEmail(email: email);

    // Chỉ hiển thị thông báo thành công và chuyển hướng nếu không có lỗi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liên kết đặt lại mật khẩu đã được gửi tới $email.'),
        duration: Duration(seconds: 3),
      ),
    );

    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  } on FirebaseAuthException catch (e) {
    String message = 'Đã xảy ra lỗi.';

    if (e.code == 'user-not-found') {
      message = 'Email này chưa được đăng ký trong hệ thống.';
    } else if (e.code == 'invalid-email') {
      message = 'Email không hợp lệ.';
    } else if (e.code == 'too-many-requests') {
      message = 'Quá nhiều yêu cầu, vui lòng thử lại sau.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
  }
}


  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ảnh nền toàn màn hình
          Image.asset(
            "images/bg.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          // Nội dung form khôi phục mật khẩu
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.green, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 80,
                          color: Colors.green,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Password Recovery',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 30),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(color: Colors.green),
                            prefixIcon: Icon(Icons.email, color: Colors.green),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.green, width: 1.5),
                            ),
                            errorText: !_isValidEmail(_emailController.text.trim()) && _emailController.text.isNotEmpty
                                ? 'Vui lòng dùng @gmail.com hoặc @yahoo.com'
                                : null,
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => setState(() {}),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _sendResetEmail,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFFAFEEEE), width: 1.0),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Send Reset Link',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: Text(
                            "Back to Login",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}