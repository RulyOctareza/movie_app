import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_top_rated_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetTopRatedTvSeries usecase;
  late MockTvSeriesRepository mockTvSeriesRepository;

  setUp(() {
    mockTvSeriesRepository = MockTvSeriesRepository();
    usecase = GetTopRatedTvSeries(mockTvSeriesRepository);
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

  test('should get list of top rated tv series from the repository', () async {
    // arrange
    when(mockTvSeriesRepository.getTopRatedTvSeries())
        .thenAnswer((_) async => Right(tTvSeries));

    // act
    final result = await usecase.execute();

    // assert
    expect(result, Right(tTvSeries));
    verify(mockTvSeriesRepository.getTopRatedTvSeries());
    verifyNoMoreInteractions(mockTvSeriesRepository);
  });
}
