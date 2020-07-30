import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:private_image_archive_app/logging.dart';


enum UploadImageResult {
  Added,
  AlreadyPresent,
  Failed
}

class ServerAccess {
  final String ENDPOINT_REST = "/rest";
  final String ENDPOINT_ADD_IMAGE = "/rest/images";
  final String ENDPOINT_GET_IMAGES = "/rest/images";
  final String ENDPOINT_CHECK_IMAGE_EXISTANCE = "/rest/checkImageExistanceByHash";
  String _baseUrl;

  ServerAccess(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<bool> isServerAvailable() async {
    var request = http.Request("GET", Uri.http(_baseUrl, ENDPOINT_REST));
    var result = await request.send().timeout(Duration(seconds: 10));
    return HttpStatus.ok == result.statusCode;
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

  Future<UploadImageResult> uploadImage(List<int> imageData, String fileName) async {
    UploadImageResult result = UploadImageResult.Failed;
    var request = http.MultipartRequest("POST", Uri.http(_baseUrl, ENDPOINT_ADD_IMAGE));
    request.fields["fileName"] = fileName;
    request.files.add(http.MultipartFile.fromBytes("image", imageData));
    try {
      var response = await request.send();
      if(response.statusCode == HttpStatus.created) {
        result = UploadImageResult.Added;
      } else if(response.statusCode == HttpStatus.found) {
        result = UploadImageResult.AlreadyPresent;
      } else {
        Logging.logError(response.statusCode.toString());
      }
    } catch(exc) {
        Logging.logError(exc.toString());
    }
    return result;
  }
}