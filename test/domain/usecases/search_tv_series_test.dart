import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/search_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late SearchTvSeries usecase;
  late MockTvSeriesRepository mockTvSeriesRepository;

  setUp(() {
    mockTvSeriesRepository = MockTvSeriesRepository();
    usecase = SearchTvSeries(mockTvSeriesRepository);
  });

  final tTvSeries = <TvSeries>[
    const TvSeries(
      id: 1,
      name: 'Test Series',
      posterPath: '/path.jpg',
      overview: 'Overview',
      voteAverage: 8.0,
    ),
  ];

  const tQuery = 'test';

  test('should get list of tv series from the repository', () async {
    // arrange
    when(mockTvSeriesRepository.searchTvSeries(tQuery))
        .thenAnswer((_) async => Right(tTvSeries));

    // act
    final result = await usecase.execute(tQuery);

    // assert
    expect(result, Right(tTvSeries));
    verify(mockTvSeriesRepository.searchTvSeries(tQuery));
    verifyNoMoreInteractions(mockTvSeriesRepository);
  });
}
