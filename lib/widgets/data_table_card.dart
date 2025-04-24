import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A data table widget designed for enterprise applications
class DataTableCard extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final String? title;
  final IconData? icon;
  final Function(int)? onRowTap;
  final bool isLoading;
  final bool hasPagination;
  final int? totalItems;
  final int? currentPage;
  final int? itemsPerPage;
  final Function(int)? onPageChanged;

  const DataTableCard({
    super.key,
    required this.columns,
    required this.rows,
    this.title,
    this.icon,
    this.onRowTap,
    this.isLoading = false,
    this.hasPagination = false,
    this.totalItems,
    this.currentPage,
    this.itemsPerPage,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade100,
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return isDark
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.05);
                    }
                    return null;
                  },
                ),
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                columnSpacing: 24,
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                showCheckboxColumn: false,
                columns: columns.map((column) =>
                  DataColumn(
                    label: Text(
                      column,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ).toList(),
                rows: rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;

                  return DataRow(
                    onSelectChanged: onRowTap != null
                        ? (_) => onRowTap!(index)
                        : null,
                    cells: row.map((cell) =>
                      DataCell(
                        Text(
                          cell,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    ).toList(),
                  );
                }).toList(),
              ),
            ),
          if (hasPagination && totalItems != null && currentPage != null && itemsPerPage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${(currentPage! - 1) * itemsPerPage! + 1} to ${currentPage! * itemsPerPage! > totalItems! ? totalItems! : currentPage! * itemsPerPage!} of $totalItems entries',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage! > 1
                            ? () => onPageChanged!(currentPage! - 1)
                            : null,
                        color: currentPage! > 1
                            ? AppTheme.primaryColor
                            : isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$currentPage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage! * itemsPerPage! < totalItems!
                            ? () => onPageChanged!(currentPage! + 1)
                            : null,
                        color: currentPage! * itemsPerPage! < totalItems!
                            ? AppTheme.primaryColor
                            : isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
