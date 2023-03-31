import 'dart:io';

class ImageFile {
  final size;
  File? file;
  final fileExtension;
  String? filename;
  bool? isMy;
  String? path;

  ImageFile(
      {required this.size, this.file, required this.fileExtension, this.filename, this.path});

  Map<String, dynamic> toMap(filename, path) {
    return {
      "filename": this.filename ?? filename,
      "size": size,
      "fileExtension": fileExtension,
      "path": this.path ?? path
    };
  }
  static ImageFile? fromJson(Map<String, dynamic> data, String uid) {
    if(_getUidFromFileName(data["filename"]) != uid) {
      return null;
    }
    return ImageFile(size: data["size"], fileExtension: data["fileExtension"], filename: data["filename"], path: data["path"]);
  } 

  static String _getUidFromFileName(String filename) {
    return filename.split("_")[0];
  }
}
