import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paycar/presentation/screen/alquiler_screen.dart';
import 'package:paycar/presentation/screen/chat_screen.dart';
import 'package:paycar/presentation/screen/estadisticas_screen.dart';
import 'package:paycar/presentation/screen/friends_screen.dart';
import 'package:paycar/presentation/screen/home_screen.dart';
import 'package:paycar/service/chat_service.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  const MainScreen({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  int _unreadMessagesCount = 0;
  final ChatService _chatService = ChatService(); // Instancia de ChatService

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _getUnreadMessagesCount();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getUnreadMessagesCount() async {
    try {
      int count = await _chatService.countUnreadMessages();
      setState(() {
        _unreadMessagesCount = count;
      });
    } catch (e) {
      // Manejo de errores
      print("Error al obtener el número de mensajes no leídos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedScreen;
    switch (_selectedIndex) {
      case 0:
        selectedScreen = HomeScreen(key: UniqueKey());
        break;
      case 1:
        selectedScreen = FriendsScreen(key: UniqueKey());
        break;
      case 2:
        selectedScreen = ChatScreen(key: UniqueKey());
        break;
      case 3:
        selectedScreen = EstadisticasScreen(key: UniqueKey());
        break;
      case 4:
        selectedScreen = AlquilarScreen(key: UniqueKey());
        break;
      default:
        selectedScreen = HomeScreen(key: UniqueKey());
    }

    return Scaffold(
      backgroundColor: Color(0xFF2F3640),
      body: selectedScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2F3640),
        items: <BottomNavigationBarItem>[
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
            icon: Stack(
              children: <Widget>[
                Icon(Icons.chat, color: Colors.green),
                if (_unreadMessagesCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadMessagesCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
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
