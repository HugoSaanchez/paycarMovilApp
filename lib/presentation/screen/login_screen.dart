import 'package:flutter/material.dart';
import 'package:paycar/presentation/screen/main_screen.dart';
import 'package:paycar/service/usuario_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final UsuarioService _usuarioService = UsuarioService();

  late String _email = '';
  late String _password = '';

  // Método para realizar el inicio de sesión
  Future<void> _login() async {
    if (_email.isEmpty || _password.isEmpty) {
      // Mostrar un SnackBar con el mensaje de error si los campos están vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese correo electrónico y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Lógica para el inicio de sesión, por ejemplo, usando el servicio de usuario
    String? loginError = await _usuarioService.login(_email, _password);
    if (loginError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // Mostrar un SnackBar con el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        color: const Color(0xFF2F3640), // Azul oscuro para el fondo
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/images/car.png',
              height: 80.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Inicio de sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Cambio de color a blanco
              ),
            ),
            const SizedBox(height: 40.0),
            TextField(
              onChanged: (value) => _email = value, // Almacena el correo electrónico ingresado
              style: const TextStyle(color: Colors.white), // Cambio de color a blanco
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: const TextStyle(color: Colors.white), // Cambio de color a blanco
                filled: true,
                fillColor: const Color(0xFF2F3640), // Mismo color que el fondo principal
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.green), // Cambio de color a verde
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.green), // Cambio de color a verde
                ),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              onChanged: (value) => _password = value, // Almacena la contraseña ingresada
              obscureText: !_passwordVisible,
              style: const TextStyle(color: Colors.white), // Cambio de color a blanco
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Colors.white), // Cambio de color a blanco
                filled: true,
                fillColor: const Color(0xFF2F3640), // Mismo color que el fondo principal
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.green), // Cambio de color a verde
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.green), // Cambio de color a verde
                ),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
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
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: _login, // Llamamos al método _login() al presionar el botón
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28B463), // Verde para el fondo del botón
                textStyle: const TextStyle(
                  color: Colors.white, // Letras blancas
                  fontSize: 24.0, // Tamaño de la letra
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.white, // Color del texto
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.push( // Navegamos a la pantalla de registro
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('¿No tienes una cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
