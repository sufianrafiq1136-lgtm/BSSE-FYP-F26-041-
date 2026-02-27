import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/back_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOTP() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate OTP sending
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        // Navigate to OTP screen
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: _phoneController.text,
        );
      });
    }
  }

  void _handleSocialLogin(String provider) {
    // TODO: Implement social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Back button
                const BackButtonWidget(),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Hello! Register to get\nstarted',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Username field
                CustomTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Phone number field
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Send OTP button
                PrimaryButton(
                  text: 'Send OTP',
                  isLoading: _isLoading,
                  onPressed: _handleSendOTP,
                ),
                
                const SizedBox(height: 32),
                
                // Or Register with divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or Register with',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: Icons.facebook,
                      color: AppColors.facebook,
                      onPressed: () => _handleSocialLogin('Facebook'),
                    ),
                    const SizedBox(width: 12),
                    SocialIconButton(
                      icon: Icons.g_mobiledata,
                      color: AppColors.google,
                      onPressed: () => _handleSocialLogin('Google'),
                    ),
                    const SizedBox(width: 12),
                    SocialIconButton(
                      icon: Icons.apple,
                      color: AppColors.apple,
                      onPressed: () => _handleSocialLogin('Apple'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login Now',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
