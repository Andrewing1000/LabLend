import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/widgets/user_card.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    return await SessionManager.userManager.getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Usuarios"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron usuarios',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            List<User> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserCard(user: users[index]);
              },
            );
          }
        },
      ),
    );
  }
}
