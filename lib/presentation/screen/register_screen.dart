import 'package:flutter/material.dart';
import 'package:paycar/service/usuario_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final UsuarioService _usuarioService = UsuarioService();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'\d'));
    return hasUppercase && hasDigits;
  }

  Future<bool> _emailExists(String email) async {
    final result = await _usuarioService.buscarPorEmail(email);
    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF2F3640),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 60.0),
                Icon(
                  Icons.local_gas_station_rounded,
                  size: 80.0,
                  color: Colors.green,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Registro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40.0),
                TextField(
                  controller: _nombreController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF2F3640),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF2F3640),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF2F3640),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF2F3640),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = _nombreController.text;
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    final confirmPassword = _confirmPasswordController.text;

                    setState(() {
                      _errorMessage = '';
                    });

                    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                      setState(() {
                        _errorMessage = 'Por favor, completa todos los campos.';
                      });
                      return;
                    }

                    if (!RegExp(r'^[A-Z]').hasMatch(password)) {
                      setState(() {
                        _errorMessage = 'La contraseña debe comenzar con una letra mayúscula.';
                      });
                      return;
                    }

                    if (!_validatePassword(password)) {
                      setState(() {
                        _errorMessage = 'La contraseña debe contener al menos una letra mayúscula y un número.';
                      });
                      return;
                    }

                    if (password != confirmPassword) {
                      setState(() {
                        _errorMessage = 'Las contraseñas no coinciden.';
                      });
                      return;
                    }

                    if (await _emailExists(email)) {
                      setState(() {
                        _errorMessage = 'El correo electrónico ya está en uso.';
                      });
                      return;
                    }

                    final registrado = await _usuarioService.register(nombre, email, password);
                    if (registrado == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else {
                      setState(() {
                        _errorMessage = 'Ocurrió un error durante el registro.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF28B463),
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      color: Colors.white, // Color del texto
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text('¿Ya tienes una cuenta? Inicia sesión aquí'),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
