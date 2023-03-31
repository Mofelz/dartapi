import 'package:flutter/material.dart';
import 'package:flutter_firebase/utils/user_utils.dart';

import '../models/user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  late Stream<List<User>> users;

  @override
  void initState() {
    users = UserUtils.instanse.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return ListView(
              children: snapshot.data!.map((user) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    textColor: Colors.white,
                    tileColor: Colors.blue,
                    title: Text(user.login),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
