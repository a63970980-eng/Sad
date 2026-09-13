import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/admin_providers.dart';

class GovernmentEmployeeDirectory extends ConsumerWidget {
  const GovernmentEmployeeDirectory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(governmentEmployeesProvider);
    final theme = Theme.of(context);

    return employees.when(
      loading: () => const ShimmerBox(height: 150, radius: 16),
      error: (error, _) => AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تعذر تحميل دليل الموظفين الحكوميين.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'إعادة المحاولة',
              onPressed: () => ref.invalidate(governmentEmployeesProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return AppCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'لا يوجد موظفون حكوميون نشطون مسجلون بعد.\nسيظهر الموظفون هنا بعد ربط حساباتهم بالجهات والأقسام الحكومية.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final employee in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: .12),
                        child: Text(
                          employee.name.isEmpty ? 'م' : employee.name.characters.first,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(employee.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(
                              employee.jobTitle.isEmpty ? 'موظف حكومي' : employee.jobTitle,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              employee.departmentName == null || employee.departmentName!.isEmpty
                                  ? employee.entityName
                                  : '${employee.entityName} • ${employee.departmentName}',
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
