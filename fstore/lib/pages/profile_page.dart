import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fstore/screens/enter_screen.dart';
import 'package:fstore/utils/firebase_utils.dart';

import '../utils/message_helper.dart';
import '../utils/user_utils.dart';
import 'package:fstore/models/user.dart' as models;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    loginController.text = FirebaseAuth.instance.currentUser!.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: loginController,
                        validator: (value) {
                          if (value == "") {
                            return "Поле не должны быть пустым";
                          }
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: "email"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "new password"),
                      ),
                    )
                  ],
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      if (passwordController.text != "") {
                        if (passwordController.text.length >= 6) {
                          UserUtils.instanse
                              .getUser(FirebaseAuth.instance.currentUser!.uid)
                              .then((user) {
                            if (user.password != passwordController.text) {
                              FireBaseUtils.instance
                                  .updatePassword(passwordController.text)
                                  .then((status) {
                                UserUtils.instanse.update(
                                    FirebaseAuth.instance.currentUser!.email!,
                                    user.password,
                                    FirebaseAuth.instance.currentUser!.uid);
                                if (status.isSuccess) {
                                  showMessage(
                                      "Пароль успешно обновлён", context);
                                } else {
                                  showMessage(status.errorMessage!, context);
                                }
                              });
                            }
                          });
                        } else {
                          showMessage("Пароль не может быть меньше 6 симовлов",
                              context);
                        }
                      }

                      if (FirebaseAuth.instance.currentUser!.email! !=
                          loginController.text) {
                        FireBaseUtils.instance
                            .updateEmail(loginController.text)
                            .then((status) {
                          if (status.isSuccess) {
                            UserUtils.instanse
                                .getUser(FirebaseAuth.instance.currentUser!.uid)
                                .then((user) {
                              UserUtils.instanse.update(
                                  FirebaseAuth.instance.currentUser!.email!,
                                  user.password,
                                  FirebaseAuth.instance.currentUser!.uid);
                            });
                            showMessage("Почта успешно обновлена", context);
                          } else {
                            showMessage(status.errorMessage!, context);
                          }
                        });
                      }
                    },
                    child: const Text("Сохранить")),
                ElevatedButton(
                    onPressed: () {
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      FireBaseUtils.instance
                          .deleteAccount()
                          .then((status) async {
                        if (status.isSuccess) {
                          await UserUtils.instanse.delete(uid);
                        } else {
                          showMessage(status.errorMessage!, context);
                        }
                      });
                      showMessage("Аккаунт успешно удалён", context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EnterScreen()));
                    },
                    child: const Text("Удалить аккаунт")),
                ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EnterScreen()));
                    },
                    child: const Text("Выйти"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
