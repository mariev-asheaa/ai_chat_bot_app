import 'package:dio/dio.dart';

class ApiClient{
  ApiClient({String? baseUrl,Dio?dio}):
        _baseUrl=baseUrl??'',_dio=dio??Dio();
final String _baseUrl;
final Dio _dio;

Future<Response<T>> postRequest<T>(
      String path,
      Map<String, dynamic> headers,
      Map<String, dynamic> queryParameters,
      dynamic data) async {
final url= _baseUrl.isEmpty?path:"$_baseUrl$path";

    return await _dio.post<T>(
      url,
      queryParameters: queryParameters,
      data: data,
      options: Options(
        headers: headers,
      ),
    );
  }
}
