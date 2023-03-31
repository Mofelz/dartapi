import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/image_file.dart';

import 'package:fstore/models/image_file.dart';
import 'package:fstore/utils/firestorage_utils.dart';
import 'package:fstore/utils/firestore_utils.dart';
import 'package:fstore/utils/image_file_utils.dart';
import 'package:io/io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> fileFromImageUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, 'imagetest.png'));

    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }

  static Future<void> uploadImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, dialogTitle: 'Выбор файла');

    if (result != null) {
      final size = result.files.first.size;
      final file = File(result.files.single.path!);
      final fileExtension = result.files.first.extension;
      final imagefile =
          ImageFile(size: size, file: file, fileExtension: fileExtension);
      String filename = FireStorageUtils.getFileName(
          FirebaseAuth.instance.currentUser!.uid, file);
      await FireStorageUtils.saveFile(file, filename);
      String path = await FireStorageUtils.getDonwloadLink(filename);
      await ImageFileUtils.instanse.create(imagefile, filename, path);
    }
  }

  static void deleteImage(String filename) async {
    await FireStorageUtils.deleteFile(filename);
    await ImageFileUtils.instanse.delete(filename);
  }

  static String restructFileName(String filename) {
    List<String> words = filename.split("_");
    String ids = words[0] + words[1];
    filename = filename.substring(ids.length + 2);
    return filename;
  }

  static String restructFileNameWithOutExtension(String filename) {
    List<String> words = filename.split("_");
    String ids = words[0] + words[1];
    filename = filename.substring(ids.length + 2);
    List<String> words2 = filename.split(".");
    filename = filename.substring(0, filename.length - words2.last.length - 1);
    return filename;
  }

  static Future<void> updateFile(oldFilename, newFilename, ImageFile imageFile) async {
    await FireStorageUtils.deleteFile(oldFilename);
    await ImageFileUtils.instanse.delete(oldFilename);

    await FireStorageUtils.saveFile(imageFile.file!, newFilename);
    String path = await FireStorageUtils.getDonwloadLink(newFilename);
    await ImageFileUtils.instanse.create(imageFile, newFilename, path);
  }

  static String restructSize(int size) {
    int floorSize = 0;
    if (size < 1024) {
      floorSize = size.floor();
      return "$floorSize байт";
    }
    if (size / 1024 < 1024) {
      floorSize = (size / 1024).floor();
      return "$floorSize Кб";
    }
    if (size / 1024 / 1024 < 1024) {
      floorSize = (size / 1024 / 1024).floor();
      return "$floorSize Мб";
    }
    if (size / 1024 / 1024 / 1024 < 1024) {
      floorSize = (size / 1024 / 1024 / 1024).floor();
      return "$floorSize Гб";
    }
    if (size / 1024 / 1024 / 1024 < 1024) {
      floorSize = (size / 1024 / 1024 / 1024 / 1024).floor();
      return "$floorSize Тб";
    }
    return "error";
  }
}
