import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorageUtils {
  static Reference get imagesRef =>
      FirebaseStorage.instance.ref().child("images");

  static Future<void> saveFile(File file, filename) async {
    await imagesRef.child(filename).putFile(file);
  }

  static String getFileName(String uid, File file) {
    var uuid = Uuid();
    return "${uid}_${uuid.v4()}_${basename(file.path)}";
  }

  static String getFileNameByName(String uid, String name) {
    var uuid = Uuid();
    return "${uid}_${uuid.v4()}_${name}";
  }

  static Future<String> getDonwloadLink(filename) async {
    return await imagesRef.child(filename).getDownloadURL();
  }

  static Future<void> deleteFile(filename) async {
    await imagesRef.child(filename).delete();
  }

  // static Future<File> getFile(filename) async {
  //   final tempDir = await getTemporaryDirectory();
  //   File file = await File('${tempDir.path}/image.png').create();
  //   file.writeAsBytesSync(imagesRef.child(filename).getData() as List<int>);
  //   return file;
  // }
}
