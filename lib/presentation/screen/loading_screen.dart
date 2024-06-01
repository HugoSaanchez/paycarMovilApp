import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paycar/presentation/screen/login_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 2),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        color: Color(0xFF2F3640), // Azul oscuro para el fondo
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono de gasolinera
              Icon(
                Icons.local_gas_station_rounded,
                size: 120.0,
                color: Color(0xFF28B463), // Verde definido en LoginScreen
              ),
              SizedBox(height: 20.0),
              Text(
                'Cargando...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Blanco definido en LoginScreen
                ),
              ),
              SizedBox(height: 40.0),
              // Icono animado de coche en carga
              SizedBox(
                height: 80.0,
                width: 120.0,
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF28B463)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
