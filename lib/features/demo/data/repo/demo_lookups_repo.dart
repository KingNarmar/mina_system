import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/lookups/data/models/department_model.dart';
import 'package:mina_system/features/lookups/data/models/job_title_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_category_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_unit_model.dart';
import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';

class DemoLookupsRepo extends LookupsRepo {
  DemoLookupsRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<List<DepartmentModel>> getDepartments({
    required String companyId,
    bool isActive = true,
  }) async {
    final items = await _storage.readJsonList(DemoStorageKeys.departments);

    final departments = items
        .where((item) => _isCompanyRecord(item, companyId))
        .where((item) => _isActiveRecord(item) == isActive)
        .map((item) => DepartmentModel.fromJson(_normalizeLookupJson(item)))
        .toList();

    departments.sort((first, second) => first.name.compareTo(second.name));

    return departments;
  }

  @override
  Future<List<DepartmentModel>> getInactiveDepartments({
    required String companyId,
  }) {
    return getDepartments(companyId: companyId, isActive: false);
  }

  @override
  Future<List<JobTitleModel>> getJobTitles({
    required String companyId,
    bool isActive = true,
  }) async {
    final items = await _storage.readJsonList(DemoStorageKeys.jobTitles);

    final jobTitles = items
        .where((item) => _isCompanyRecord(item, companyId))
        .where((item) => _isActiveRecord(item) == isActive)
        .map((item) => JobTitleModel.fromJson(_normalizeLookupJson(item)))
        .toList();

    jobTitles.sort((first, second) => first.name.compareTo(second.name));

    return jobTitles;
  }

  @override
  Future<List<JobTitleModel>> getInactiveJobTitles({
    required String companyId,
  }) {
    return getJobTitles(companyId: companyId, isActive: false);
  }

  @override
  Future<List<ToolUnitModel>> getToolUnits({
    required String companyId,
    bool isActive = true,
  }) async {
    final items = await _storage.readJsonList(DemoStorageKeys.toolUnits);

    final toolUnits = items
        .where((item) => _isCompanyRecord(item, companyId))
        .where((item) => _isActiveRecord(item) == isActive)
        .map((item) => ToolUnitModel.fromJson(_normalizeLookupJson(item)))
        .toList();

    toolUnits.sort((first, second) => first.name.compareTo(second.name));

    return toolUnits;
  }

  @override
  Future<List<ToolUnitModel>> getInactiveToolUnits({
    required String companyId,
  }) {
    return getToolUnits(companyId: companyId, isActive: false);
  }

  @override
  Future<List<ToolCategoryModel>> getToolCategories({
    required String companyId,
    bool isActive = true,
  }) async {
    final items = await _storage.readJsonList(DemoStorageKeys.toolCategories);

    final toolCategories = items
        .where((item) => _isCompanyRecord(item, companyId))
        .where((item) => _isActiveRecord(item) == isActive)
        .map((item) => ToolCategoryModel.fromJson(_normalizeLookupJson(item)))
        .toList();

    toolCategories.sort((first, second) => first.name.compareTo(second.name));

    return toolCategories;
  }

  @override
  Future<List<ToolCategoryModel>> getInactiveToolCategories({
    required String companyId,
  }) {
    return getToolCategories(companyId: companyId, isActive: false);
  }

  @override
  Future<DepartmentModel> addDepartment({
    required String companyId,
    required String name,
    String? code,
  }) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<void> deleteDepartment({required String departmentId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<DepartmentModel> reactivateDepartment({required String departmentId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<JobTitleModel> addJobTitle({
    required String companyId,
    required String departmentId,
    required String name,
  }) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<void> deleteJobTitle({required String jobTitleId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<JobTitleModel> reactivateJobTitle({required String jobTitleId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<ToolUnitModel> addToolUnit({
    required String companyId,
    required String name,
    String? symbol,
  }) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<void> deleteToolUnit({required String toolUnitId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<ToolUnitModel> reactivateToolUnit({required String toolUnitId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<ToolCategoryModel> addToolCategory({
    required String companyId,
    required String name,
    String? code,
  }) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<void> deleteToolCategory({required String toolCategoryId}) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<ToolCategoryModel> reactivateToolCategory({
    required String toolCategoryId,
  }) {
    throw UnsupportedError('Editing demo lookups is not available yet.');
  }

  @override
  Future<bool> departmentNameExists({
    required String companyId,
    required String name,
  }) async {
    final departments = await getDepartments(companyId: companyId);

    return departments.any((department) {
      return _isSameLookupName(department.name, name);
    });
  }

  @override
  Future<bool> inactiveDepartmentNameExists({
    required String companyId,
    required String name,
  }) async {
    final departments = await getInactiveDepartments(companyId: companyId);

    return departments.any((department) {
      return _isSameLookupName(department.name, name);
    });
  }

  @override
  Future<bool> jobTitleNameExists({
    required String companyId,
    required String departmentId,
    required String name,
  }) async {
    final jobTitles = await getJobTitles(companyId: companyId);

    return jobTitles.any((jobTitle) {
      return jobTitle.departmentId == departmentId &&
          _isSameLookupName(jobTitle.name, name);
    });
  }

  @override
  Future<bool> toolUnitNameExists({
    required String companyId,
    required String name,
  }) async {
    final toolUnits = await getToolUnits(companyId: companyId);

    return toolUnits.any((unit) {
      return _isSameLookupName(unit.name, name);
    });
  }

  @override
  Future<bool> toolCategoryNameExists({
    required String companyId,
    required String name,
  }) async {
    final toolCategories = await getToolCategories(companyId: companyId);

    return toolCategories.any((category) {
      return _isSameLookupName(category.name, name);
    });
  }

  bool _isCompanyRecord(Map<String, dynamic> item, String companyId) {
    return item['company_id'] == companyId;
  }

  bool _isActiveRecord(Map<String, dynamic> item) {
    final isActive = item['is_active'];

    if (isActive is bool) {
      return isActive;
    }

    final status = item['status'] as String? ?? 'active';

    return status.trim().toLowerCase() == 'active';
  }

  Map<String, dynamic> _normalizeLookupJson(Map<String, dynamic> item) {
    return {...item, 'is_active': _isActiveRecord(item)};
  }

  bool _isSameLookupName(String firstValue, String secondValue) {
    return _normalizeLookupName(firstValue) ==
        _normalizeLookupName(secondValue);
  }

  String _normalizeLookupName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
