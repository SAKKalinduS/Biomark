import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class UpdateEmailScreen extends StatefulWidget {
  @override
  _UpdateEmailScreenState createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(_emailController.text);
      _emailError = !_isEmailValid && _emailController.text.isNotEmpty
          ? 'Please enter a valid email address'
          : null;
      _isFormValid = _isEmailValid &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Widget _buildErrorText(String? error) {
    if (error == null || error.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 12, top: 6),
      child: Text(
        error,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? icon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: errorText != null
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon ?? Icons.person_outline,
                color: errorText != null ? Colors.red.shade300 : null,
              ),
              labelStyle: TextStyle(
                color: errorText != null ? Colors.red.shade300 : null,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
        _buildErrorText(errorText),
        SizedBox(height: 16),
      ],
    );
  }

  void _handleEmailChange() async {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _isLoading = true;
        _passwordError = null;
      });

      try {
        final result = await Provider.of<AuthService>(context, listen: false)
            .changeEmail(_emailController.text, _passwordController.text);

        if (result['success']) {
          Navigator.pop(context);
        } else {
          setState(() {
            _passwordError = result['error'];
          });
        }
      } catch (error) {
        setState(() {
          _passwordError = error.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Email Address',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'New Email',
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email_outlined,
                      errorText: _emailError,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Current Password',
                      isPassword: true,
                      icon: Icons.lock_outline,
                      errorText: _passwordError,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          disabledBackgroundColor: Colors.grey[400],
                          disabledForegroundColor: Colors.grey[300],
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: (_isLoading || !_isFormValid)
                            ? null
                            : _handleEmailChange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}