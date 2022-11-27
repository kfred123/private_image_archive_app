import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:private_image_archive_app/logging.dart';


enum UploadResult {
  Added,
  AlreadyArchived,
  Failed
}

class ServerAccess {
  final String ENDPOINT_REST = "/rest";
  final String ENDPOINT_ADD_IMAGE = "/rest/images";
  final String ENDPOINT_GET_IMAGES = "/rest/images";
  final String ENDPOINT_CHECK_IMAGE_EXISTANCE = "/rest/checkImageExistanceByHash";
  final String ENDPOINT_DELETE_ALL_IMAGES = "/rest/images/deleteAllDebug";
  final String ENDPOINT_DELETE_ALL_VIDEOS = "/rest/videos/deleteAllDebug";

  final String ENDPOINT_ADD_VIDEO = "/rest/videos";
  final String ENDPOINT_CHECK_VIDEO_EXISTANCE = "/rest/checkVideoExistanceByHash";
  String _baseUrl;

  ServerAccess(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<bool> isServerAvailable() async {
    bool isAvailable = false;
    var request = http.Request("GET", Uri.http(_baseUrl, ENDPOINT_REST));
    try {
      var result = await request.send().timeout(Duration(seconds: 10));
      isAvailable = HttpStatus.ok == result.statusCode;
    } on TimeoutException catch(e) {
      Logging.logException(e.message, e);
    } on SocketException catch(e) {
      Logging.logException(e.message, e);
    }
    return isAvailable;
  }

  void getAllImages() async {
    var request = http.Request("GET", Uri.http(_baseUrl, ENDPOINT_GET_IMAGES));
    var result = await request.send();
    int x = 0;
  }

  Future<bool> checkImageExistanceByHash(String sha256Hash) async {
    Uri uri = Uri.http(_baseUrl, ENDPOINT_CHECK_IMAGE_EXISTANCE,
        {"hash" : sha256Hash});
    var request = http.Request("GET", uri);
    http.StreamedResponse response = await request.send();

    return response.statusCode == HttpStatus.ok;
  }

  Future<UploadResult> uploadImage(List<int> imageData, String fileName) async {
    UploadResult result = UploadResult.Failed;
    var request = http.MultipartRequest("POST", Uri.http(_baseUrl, ENDPOINT_ADD_IMAGE));
    request.fields["fileName"] = fileName;
    request.files.add(http.MultipartFile.fromBytes("image", imageData));
    try {
      var response = await request.send();
      if(response.statusCode == HttpStatus.created) {
        result = UploadResult.Added;
      } else if(response.statusCode == HttpStatus.found) {
        result = UploadResult.AlreadyArchived;
      } else {
        Logging.logError(response.statusCode.toString());
      }
    } catch(exc) {
        Logging.logError(exc.toString());
    }
    return result;
  }

  Future<bool> checkVideoExistanceByHash(String sha256Hash) async {
    Uri uri = Uri.http(_baseUrl, ENDPOINT_CHECK_VIDEO_EXISTANCE,
        {"hash" : sha256Hash});
    var request = http.Request("GET", uri);
    http.StreamedResponse response = await request.send();

    return response.statusCode == HttpStatus.ok;
  }

  Future<UploadResult> uploadVideo(List<int> videoData, String fileName) async {
    UploadResult result = UploadResult.Failed;
    var request = http.MultipartRequest("POST", Uri.http(_baseUrl, ENDPOINT_ADD_VIDEO));
    request.fields["fileName"] = fileName;
    request.files.add(http.MultipartFile.fromBytes("video", videoData));
    try {
      var response = await request.send();
      if(response.statusCode == HttpStatus.created) {
        result = UploadResult.Added;
      } else if(response.statusCode == HttpStatus.found) {
        result = UploadResult.AlreadyArchived;
      } else {
        Logging.logError(response.statusCode.toString());
      }
    } catch(exc) {
      Logging.logError(exc.toString());
    }
    return result;
  }
  
  Future<void> deleteAllImagesAndVideos() async {
    await deleteAllImages();
    await deleteAllVideos();
  }

  Future<void> deleteAllImages() async {
    var response = await http.delete(Uri.http(_baseUrl, ENDPOINT_DELETE_ALL_IMAGES));
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
          "Delete all images returned ${response.statusCode} : ${response.body}");
    }
  }

  Future<void> deleteAllVideos() async {
    var response = await http.delete(Uri.http(_baseUrl, ENDPOINT_DELETE_ALL_VIDEOS));
    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Delete all videos returned ${response.statusCode} : ${response.body}");
    }
  }
}