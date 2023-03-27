import 'package:flutter/material.dart';

import '../pages/notes_page.dart';
import '../pages/profile_page.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  final List<Widget> pages = [const HistoryPage(), const ProfilePage()];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 23, 107, 17),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Записи'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль')],
        backgroundColor: Color.fromARGB(255, 19, 67, 6),
        selectedItemColor: Color.fromARGB(255, 72, 243, 33),
        unselectedItemColor: Color.fromARGB(255, 3, 3, 3),
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() => currentIndex = value);
        },
      ),
    );
  }
}
