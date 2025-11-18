import 'package:expenses/common/theme.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SixJarsSection extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<JarData> jars;

  const SixJarsSection({
    super.key,
    this.onViewAll,
    this.jars = const [],
  });

  @override
  Widget build(BuildContext context) {
    final jarData = jars.isEmpty ? SampleData.jars : jars;
    final jarPairs = <List<JarData>>[];
    for (var i = 0; i < jarData.length; i += 2) {
      final pair = <JarData>[jarData[i]];
      if (i + 1 < jarData.length) {
        pair.add(jarData[i + 1]);
      }
      jarPairs.add(pair);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '6 Hũ Tài Chính',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    size: AppIconSizes.xs,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        JarDistributionChart(jars: jarData),
        // const SizedBox(height: AppSpacing.lg),
        // Column(
        //   children: [
        //     for (var i = 0; i < jarPairs.length; i++) ...[
        //       Row(
        //         children: [
        //           Expanded(child: JarCard(data: jarPairs[i][0])),
        //           if (jarPairs[i].length == 2) ...[
        //             const SizedBox(width: AppSpacing.md),
        //             Expanded(child: JarCard(data: jarPairs[i][1])),
        //           ],
        //         ],
        //       ),
        //       if (i != jarPairs.length - 1)
        //         const SizedBox(height: AppSpacing.md),
        //     ],
        //   ],
        // ),
      ],
    );
  }
}

// class JarCard extends StatelessWidget {
//   final JarData data;

//   const JarCard({
//     super.key,
//     required this.data,
//   });

  // @override
  // Widget build(BuildContext context) {
  //   final isWarning = data.progress < 0.5;

  //   return Container(
  //     padding: const EdgeInsets.all(AppSpacing.lg),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: AppRadius.radiusLG,
  //       border: Border.all(
  //         color: isWarning ? AppColors.warning : AppColors.gray200,
  //         width: isWarning ? 2 : 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(AppSpacing.sm),
  //               decoration: BoxDecoration(
  //                 color: data.color.withValues(alpha: 0.1),
  //                 borderRadius: AppRadius.radiusSM,
  //               ),
  //               child: Icon(
  //                 data.icon,
  //                 color: data.color,
  //                 size: AppIconSizes.sm,
  //               ),
  //             ),
  //             if (isWarning)
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 6,
  //                   vertical: AppSpacing.xs / 2,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.warning.withValues(alpha: 0.1),
  //                   borderRadius: AppRadius.radiusXS,
  //                 ),
  //                 child: Text(
  //                   '⚠️',
  //                   style: Theme.of(context).textTheme.bodySmall,
  //                 ),
  //               ),
  //           ],
  //         ),
  //         const SizedBox(height: AppSpacing.md),
  //         Text(
  //           data.name,
  //           style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColors.gray900,
  //               ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const SizedBox(height: AppSpacing.sm),
  //         Text(
  //           data.amount,
  //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColors.gray900,
  //               ),
  //         ),
  //         const SizedBox(height: AppSpacing.xs),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               data.percentage,
  //               style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                     color: AppColors.gray500,
  //                   ),
  //             ),
  //             Text(
  //               '${(data.progress * 100).toInt()}%',
  //               style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                     color: data.color,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: AppSpacing.sm),
  //         Container(
  //           height: 6,
  //           decoration: BoxDecoration(
  //             color: AppColors.gray100,
  //             borderRadius: BorderRadius.circular(AppRadius.progressBar),
  //           ),
  //           child: FractionallySizedBox(
  //             alignment: Alignment.centerLeft,
  //             widthFactor: data.progress,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: data.color,
  //                 borderRadius: BorderRadius.circular(AppRadius.progressBar),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
// }

class JarDistributionChart extends StatelessWidget {
  final List<JarData> jars;

  const JarDistributionChart({
    super.key,
    required this.jars,
  });

  double _parsePercentage(String percentage) {
    final cleaned = percentage.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final totalPercent = jars.fold<double>(
      0,
      (previousValue, element) => previousValue + _parsePercentage(element.percentage),
    );

    final chart = AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 70,
          sections: jars
              .map(
                (jar) {
                  final percentageValue = _parsePercentage(jar.percentage);
                  return PieChartSectionData(
                    color: jar.color,
                    value: percentageValue,
                    title: '${percentageValue.toStringAsFixed(0)}%',
                    titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  );
                },
              )
              .toList(),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ phân bổ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: constraints.maxWidth,
                      child: chart,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LegendList(jars: jars),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: chart),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _LegendList(jars: jars)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendList extends StatelessWidget {
  final List<JarData> jars;

  const _LegendList({required this.jars});

  double _parsePercentage(String percentage) {
    final cleaned = percentage.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: jars
          .map(
            (jar) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: jar.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jar.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${jar.amount} • ${_parsePercentage(jar.percentage).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.gray500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

