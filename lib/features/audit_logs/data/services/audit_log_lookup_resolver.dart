import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';

class AuditLogLookupResolver {
  const AuditLogLookupResolver({
    this.departmentNamesById = const {},
    this.jobTitleNamesById = const {},
    this.toolUnitNamesById = const {},
    this.toolCategoryNamesById = const {},
  });

  final Map<String, String> departmentNamesById;
  final Map<String, String> jobTitleNamesById;
  final Map<String, String> toolUnitNamesById;
  final Map<String, String> toolCategoryNamesById;

  static const empty = AuditLogLookupResolver();

  bool get hasData {
    return departmentNamesById.isNotEmpty ||
        jobTitleNamesById.isNotEmpty ||
        toolUnitNamesById.isNotEmpty ||
        toolCategoryNamesById.isNotEmpty;
  }

  String? resolveFieldLabel(String fieldKey) {
    switch (fieldKey.trim().toLowerCase()) {
      case 'department_id':
        return 'Department';
      case 'job_title_id':
        return 'Job Title';
      case 'unit_id':
        return 'Unit';
      case 'category_id':
        return 'Category';
      default:
        return null;
    }
  }

  String? resolveFieldValue({
    required String fieldKey,
    required dynamic value,
  }) {
    final cleanValue = value?.toString().trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    switch (fieldKey.trim().toLowerCase()) {
      case 'department_id':
        return departmentNamesById[cleanValue];
      case 'job_title_id':
        return jobTitleNamesById[cleanValue];
      case 'unit_id':
        return toolUnitNamesById[cleanValue];
      case 'category_id':
        return toolCategoryNamesById[cleanValue];
      default:
        return null;
    }
  }

  static Future<AuditLogLookupResolver> load({
    required String companyId,
    LookupsRepo? lookupsRepo,
  }) async {
    final repo = lookupsRepo ?? LookupsRepo();

    final departments = await repo.getDepartments(companyId: companyId);
    final jobTitles = await repo.getJobTitles(companyId: companyId);
    final toolUnits = await repo.getToolUnits(companyId: companyId);
    final toolCategories = await repo.getToolCategories(companyId: companyId);

    return AuditLogLookupResolver(
      departmentNamesById: {
        for (final department in departments) department.id: department.name,
      },
      jobTitleNamesById: {
        for (final jobTitle in jobTitles) jobTitle.id: jobTitle.name,
      },
      toolUnitNamesById: {
        for (final toolUnit in toolUnits) toolUnit.id: toolUnit.name,
      },
      toolCategoryNamesById: {
        for (final toolCategory in toolCategories)
          toolCategory.id: toolCategory.name,
      },
    );
  }
}
