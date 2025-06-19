import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart' hide kRichBlack, kTextTheme;
import '../../core/styles.dart';
import '../../domain/entities/tv_series.dart';

class TvSeriesCard extends StatelessWidget {
  final TvSeries tvSeries;

  const TvSeriesCard(this.tvSeries, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail-tv',
            arguments: tvSeries.id,
          );
        },
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Card(
              color: kRichBlack,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16 + 80 + 16,
                  bottom: 8,
                  right: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tvSeries.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kTextTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tvSeries.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: kTextTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 16,
                bottom: 16,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: '${Urls.baseImageUrl}${tvSeries.posterPath}',
                  width: 80,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
