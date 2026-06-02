import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';

class AuditLogLookupResolver {
  const AuditLogLookupResolver({
    this.departmentNamesById = const {},
    this.jobTitleNamesById = const {},
    this.toolUnitNamesById = const {},
    this.toolCategoryNamesById = const {},
    this.workerNamesById = const {},
    this.toolNamesById = const {},
  });

  final Map<String, String> departmentNamesById;
  final Map<String, String> jobTitleNamesById;
  final Map<String, String> toolUnitNamesById;
  final Map<String, String> toolCategoryNamesById;
  final Map<String, String> workerNamesById;
  final Map<String, String> toolNamesById;

  static const empty = AuditLogLookupResolver();

  bool get hasData {
    return departmentNamesById.isNotEmpty ||
        jobTitleNamesById.isNotEmpty ||
        toolUnitNamesById.isNotEmpty ||
        toolCategoryNamesById.isNotEmpty ||
        workerNamesById.isNotEmpty ||
        toolNamesById.isNotEmpty;
  }

  bool isResolvableField(String fieldKey) {
    switch (fieldKey.trim().toLowerCase()) {
      case 'department_id':
      case 'job_title_id':
      case 'unit_id':
      case 'category_id':
      case 'worker_id':
      case 'tool_id':
        return true;
      default:
        return false;
    }
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
      case 'worker_id':
        return 'Worker';
      case 'tool_id':
        return 'Tool';
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
      case 'worker_id':
        return workerNamesById[cleanValue];
      case 'tool_id':
        return toolNamesById[cleanValue];
      default:
        return null;
    }
  }

  static Future<AuditLogLookupResolver> load({
    required String companyId,
    LookupsRepo? lookupsRepo,
    WorkersRepo? workersRepo,
    ToolsRepo? toolsRepo,
  }) async {
    final lookups = lookupsRepo ?? LookupsRepo();
    final workers = workersRepo ?? WorkersRepo();
    final tools = toolsRepo ?? ToolsRepo();

    final activeDepartments = await lookups.getDepartments(
      companyId: companyId,
    );
    final inactiveDepartments = await lookups.getInactiveDepartments(
      companyId: companyId,
    );

    final activeJobTitles = await lookups.getJobTitles(companyId: companyId);
    final inactiveJobTitles = await lookups.getInactiveJobTitles(
      companyId: companyId,
    );

    final activeToolUnits = await lookups.getToolUnits(companyId: companyId);
    final inactiveToolUnits = await lookups.getInactiveToolUnits(
      companyId: companyId,
    );

    final activeToolCategories = await lookups.getToolCategories(
      companyId: companyId,
    );
    final inactiveToolCategories = await lookups.getInactiveToolCategories(
      companyId: companyId,
    );

    final allWorkers = await workers.getWorkers(
      companyId: companyId,
      status: null,
    );

    final allTools = await tools.getTools(companyId: companyId, status: null);

    final departments = [...activeDepartments, ...inactiveDepartments];
    final jobTitles = [...activeJobTitles, ...inactiveJobTitles];
    final toolUnits = [...activeToolUnits, ...inactiveToolUnits];
    final toolCategories = [...activeToolCategories, ...inactiveToolCategories];

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
      workerNamesById: {
        for (final worker in allWorkers)
          if (worker.id != null && worker.id!.trim().isNotEmpty)
            worker.id!: worker.name,
      },
      toolNamesById: {
        for (final tool in allTools)
          if (tool.id != null && tool.id!.trim().isNotEmpty)
            tool.id!: tool.toolName,
      },
    );
  }
}
