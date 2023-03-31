import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fstore/models/image_file.dart' as models;

import '../models/status.dart';
import 'firestore_utils.dart';

class ImageFileUtils {
  static ImageFileUtils get instanse => ImageFileUtils();

  CollectionReference<Map<String, dynamic>> get imageCollection =>
      FireStoreUtils.firestoreUtils.collection("images");

  Future<Status> create(
      models.ImageFile imagefile, String filename, String path) async {
    return imageCollection
        .doc(filename)
        .set(imagefile.toMap(filename, path))
        .then((value) => Status())
        .catchError((error) => Status(errorMessage: error));
  }

  Stream<List<models.ImageFile?>> get(String uid) {
    return imageCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => models.ImageFile.fromJson(doc.data(), uid))
        .toList());
  }

  Future<models.ImageFile> getImageFile(String filename) async {
    final data = await imageCollection.doc(filename).get().then(
        (DocumentSnapshot documentSnapshot) =>
            {documentSnapshot.data() as Map<String, dynamic>});
    Map<String, dynamic> firstImageFile = data.first;
    models.ImageFile imagefile = models.ImageFile(
        size: firstImageFile["size"],
        fileExtension: firstImageFile["fileExtension"],
        filename: firstImageFile["filename"]);
    return imagefile;
  }

  Future<void> update(
      models.ImageFile iamgefile, String filename, String path) async {
    delete(filename);
    return create(iamgefile, filename, path).then((value) => value);
  }

  Future<Status> delete(String filename) async {
    return imageCollection
        .doc(filename)
        .delete()
        .then((value) => Status())
        .catchError((error) => Status(errorMessage: error));
  }
}
