import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/url.dart';
import '../models/note.dart';
import '../cubit/notes_cubit.dart';
import '../interceptors/custom_interceptor.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerText = TextEditingController();
  TextEditingController controllerCategory = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  SharedPreferences? sharedPreferences;
  Dio DIO = Dio();
  List<Note> notes = [];
  String filter = '';
  String search = '';

  Future<void> initSharedPreferences() async => sharedPreferences = await SharedPreferences.getInstance();

  void clearSharedPreferences() async => await sharedPreferences!.clear();

  String getTokenSharedPreferences() => sharedPreferences!.getString('token')!;

  Future<void> getNotes(String filter, String search) async {
    // try {
      Response response = await DIO.get(URL.note.value, queryParameters: {'filter': filter, 'search': search});
      if (response.data['message'] == 'Заметки не найдены') {
        context.read<NotesCubit>().clearNotes();
        return;
      }

      notes = (response.data['data'] as List).map((x) => Note.fromJson(x)).toList();

      context.read<NotesCubit>().setNotes(notes);
    // } on DioError {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    // }
  }

  Future<void> createNote() async {
    try {
      String name = controllerName.text;
      String text = controllerText.text;
      String category = controllerCategory.text;

      await DIO.put(URL.note.value, data: Note(name: name, text: text, category: category));
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> updateNote(int number) async {
    try {
      String name = controllerName.text;
      String text = controllerText.text;
      String category = controllerCategory.text;

      await DIO.post('${URL.note.value}/$number', data: Note(name: name, text: text, category: category));
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> deleteNote(int number) async {
    try {
      await DIO.delete('${URL.note.value}/$number');
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  Future<void> restoreNote(int number) async {
    try {
      await DIO.get('${URL.note.value}/$number', queryParameters: {'restore': true});
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка', textAlign: TextAlign.center)));
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((value) async {
      String token = getTokenSharedPreferences();
      DIO.options.headers['Authorization'] = "Bearer $token";
      DIO.interceptors.add(CustomInterceptor());
      getNotes(filter, search);
    });
  }

  void showNoteDialog(Note? note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromARGB(255, 8, 96, 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Form(
                    key: key,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controllerName,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Наименование не должно быть пустым";
                            }
                            return null;
                          }),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            labelStyle: TextStyle(color: Colors.white),
                            labelText: "Наименование",
                          ),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
                        TextFormField(
                          controller: controllerText,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Текст не должен быть пустым";
                            }
                            return null;
                          }),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            labelStyle: TextStyle(color: Colors.white),
                            labelText: "Текст",
                          ),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(25, 5, 25, 5)),
                        TextFormField(
                          controller: controllerCategory,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "Категория не должна быть пустой";
                            }
                            return null;
                          }),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            labelStyle: TextStyle(color: Colors.white),
                            labelText: "Категория",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromARGB(255, 133, 215, 125),
                          ),
                          onPressed: () async {
                            if (!key.currentState!.validate()) return;
                            if (note == null) {
                              await createNote();
                            } else {
                              await updateNote(note.number!);
                            }
                            getNotes(filter, search);
                            controllerName.text = '';
                            controllerText.text = '';
                            controllerCategory.text = '';
                            Navigator.of(context).pop();
                          },
                          child: const Text("Сохранить"),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromARGB(255, 133, 215, 125),
                          ),
                          onPressed: () {
                            controllerName.text = '';
                            controllerText.text = '';
                            controllerCategory.text = '';
                            Navigator.of(context).pop();
                          },
                          child: const Text("Отмена"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 10, 146, 22),
        foregroundColor: Colors.black,
        title: SizedBox(
          width: double.infinity,
          height: 40,
          child: Center(
            child: TextField(
              onChanged: (value) {
                search = value;
                getNotes(filter, search);
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: PopupMenuButton(
                  tooltip: "Сортировка",
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text("Добавленные"),
                      onTap: () {
                        filter = 'created';
                        getNotes(filter, search);
                      },
                    ),
                    PopupMenuItem(
                      child: const Text("Измененные"),
                      onTap: () {
                        filter = 'updated';
                        getNotes(filter, search);
                      },
                    ),
                    PopupMenuItem(
                      child: const Text("Удаленные"),
                      onTap: () {
                        filter = 'deleted';
                        getNotes(filter, search);
                      },
                    ),
                    PopupMenuItem(
                      child: const Text("По умолчанию"),
                      onTap: () {
                        filter = '';
                        getNotes(filter, search);
                      },
                    ),
                  ],
                  icon: const Icon(Icons.filter_alt, color: Colors.black),
                ),
                hintText: 'Поиск',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 37, 55, 35),
      body: Center(
        child: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is UpdateNotes) {
              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) => Card(
                  color: Color.fromARGB(255, 122, 221, 97),
                  child: ListTile(
                    textColor: Colors.white,
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 36, 123, 52),
                      child: Text((state.notes.elementAt(index).number).toString()),
                    ),
                    title: Text(state.notes.elementAt(index).text),
                    subtitle: Text(state.notes.elementAt(index).name),
                    trailing: PopupMenuButton(
                      tooltip: "Действия",
                      itemBuilder: (context) => [
                        if (state.notes.elementAt(index).status != 'deleted')
                          PopupMenuItem(
                            child: const Text("Изменить"),
                            onTap: () {
                              Note note = state.notes.elementAt(index);
                              controllerName.text = note.name;
                              controllerText.text = note.text;
                              controllerCategory.text = note.category;
                              Future.delayed(const Duration(seconds: 0), () => showNoteDialog(note));
                            },
                          ),
                        if (state.notes.elementAt(index).status != 'deleted')
                          PopupMenuItem(
                            child: const Text("Удалить"),
                            onTap: () async {
                              deleteNote(state.notes.elementAt(index).number!);
                              context.read<NotesCubit>().deleteNote(index);
                            },
                          ),
                        if (state.notes.elementAt(index).status == 'deleted')
                          PopupMenuItem(
                            child: const Text("Восстановить"),
                            onTap: () async {
                              restoreNote(state.notes.elementAt(index).number!);
                              context.read<NotesCubit>().deleteNote(index);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const CircularProgressIndicator(color: Color.fromARGB(255, 53, 124, 14));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
