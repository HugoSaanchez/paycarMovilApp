import 'package:flutter/material.dart';
import 'package:paycar/presentation/screen/alquiler_screen.dart';
import 'package:paycar/presentation/screen/chat_screen.dart';
import 'package:paycar/presentation/screen/estadisticas_screen.dart';
import 'package:paycar/presentation/screen/friends_screen.dart';
import 'package:paycar/presentation/screen/home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedScreen;
    switch (_selectedIndex) {
      case 0:
        selectedScreen = HomeScreen();
        break;
      case 1:
        selectedScreen = FriendsScreen();
        break;
      case 2:
        selectedScreen = ChatScreen();
        break;
      case 3:
        selectedScreen = EstadisticasScreen();
        break;
      case 4:
        selectedScreen = AlquilarScreen();
        break;
      default:
        selectedScreen = HomeScreen();
    }

    return Scaffold(
      backgroundColor: Color(0xFF2F3640),
      body: selectedScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2F3640),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.green), 
                  backgroundColor: Color(0xFF2F3640),
            label: 'Grupo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.green), 
                  backgroundColor: Color(0xFF2F3640),
            label: 'Amigos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.green), 
                  backgroundColor: Color(0xFF2F3640),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.green), 
                  backgroundColor: Color(0xFF2F3640),
            label: 'Estadisticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental, color: Colors.green), 
                  backgroundColor: Color(0xFF2F3640),
            label: 'Alquiler',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
