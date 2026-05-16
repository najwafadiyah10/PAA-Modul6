import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:car_rental_app/services/auth_services.dart';
import 'package:car_rental_app/widgets/custom_text_field.dart';
import 'package:car_rental_app/widgets/loading_indicator.dart';
import 'package:car_rental_app/screens/auth/register_screen.dart';
import 'package:car_rental_app/screens/car/car_list_screen_admin.dart';
import 'package:car_rental_app/screens/car/car_list_screen_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color primaryColor =
      Color(0xFF111827);

  static const Color secondaryColor =
      Color(0xFF7C3AED);

  static const Color accentColor =
      Color(0xFF38BDF8);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        final user = result['user'];
        final role =
            user.role.toString().toLowerCase();

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CarListScreenAdmin(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CarListScreenUser(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Widget _buildBackground({
    required Widget child,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF4EEFF),
                  Color(0xFFEFF6FF),
                  Color(0xFFFFFAEA),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: _LoginLinePainter(),
          ),
        ),

        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondaryColor.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -90,
          left: -70,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                Color(0xFF312E81),
                secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: secondaryColor.withOpacity(0.32),
                blurRadius: 28,
                offset: const Offset(
                  0,
                  14,
                ),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        const Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryColor,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          'Masuk untuk mulai sewa mobil dengan mudah.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.86),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.08),
                blurRadius: 26,
                offset: const Offset(
                  0,
                  14,
                ),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: secondaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Text(
                        'Login Akun',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 22,
                ),

                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }

                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 2,
                ),

                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                _buildLoginButton(),

                const SizedBox(
                  height: 18,
                ),

                _buildRegisterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor:
              Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun?',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const RegisterScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: secondaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Daftar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNote() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Text(
        'Sewa mobil lebih praktis, pantau booking, dan lakukan pembayaran dalam satu aplikasi.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _buildBackground(
        child: SafeArea(
          child: _isLoading
              ? const LoadingIndicator(
                  message: 'Sedang masuk...',
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildLogoSection(),

                        const SizedBox(
                          height: 34,
                        ),

                        _buildFormCard(),

                        _buildBottomNote(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _LoginLinePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFF7C3AED)
          .withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = const Color(0xFF38BDF8)
          .withOpacity(0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height;
        i < size.width;
        i += 62) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    for (double i = 0;
        i < size.width + size.height;
        i += 92) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        accentPaint,
      );
    }

    final wavePaint = Paint()
      ..color = const Color(0xFF111827)
          .withOpacity(0.035)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.20,
    );

    path.cubicTo(
      size.width * 0.28,
      size.height * 0.14,
      size.width * 0.62,
      size.height * 0.28,
      size.width,
      size.height * 0.18,
    );

    canvas.drawPath(
      path,
      wavePaint,
    );

    final secondPath = Path();

    secondPath.moveTo(
      0,
      size.height * 0.82,
    );

    secondPath.cubicTo(
      size.width * 0.30,
      size.height * 0.74,
      size.width * 0.62,
      size.height * 0.92,
      size.width,
      size.height * 0.80,
    );

    canvas.drawPath(
      secondPath,
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}