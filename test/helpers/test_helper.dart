import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:expert_flutter_dicoding/domain/repositories/tv_series_repository.dart';

@GenerateMocks([
  TvSeriesRepository,
  http.Client,
], customMocks: [])
void main() {}
