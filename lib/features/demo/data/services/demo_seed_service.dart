import 'demo_local_storage_service.dart';
import 'demo_storage_keys.dart';

class DemoSeedService {
  const DemoSeedService({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  static const String demoCompanyId = 'demo-company-001';
  static const String demoProfileId = 'demo-profile-001';

  Future<void> initializeIfNeeded() async {
    final isInitialized = await _storage.isInitialized;

    if (isInitialized) {
      return;
    }

    await resetAndSeed();
  }

  Future<void> resetAndSeed() async {
    await _storage.clearDemoData();

    final now = DateTime.now();

    await _storage.writeJsonObject(
      key: DemoStorageKeys.companyProfile,
      value: _companyProfile,
    );

    await _storage.writeJsonObject(
      key: DemoStorageKeys.reportSettings,
      value: _reportSettings,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.departments,
      value: _buildDepartments(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.jobTitles,
      value: _buildJobTitles(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.toolCategories,
      value: _buildToolCategories(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.toolUnits,
      value: _buildToolUnits(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.workers,
      value: _buildWorkers(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.tools,
      value: _buildTools(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.transactions,
      value: _buildTransactions(now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.signedReportsMetadata,
      value: const [],
    );

    await _storage.markInitialized();
  }

  static const Map<String, dynamic> _companyProfile = {
    'id': demoCompanyId,
    'name': 'Demo Marine Services LLC',
    'timezone': 'Asia/Dubai',
    'role': 'owner',
  };

  static const Map<String, dynamic> _reportSettings = {
    'company_name': 'Demo Marine Services LLC',
    'report_footer':
        'Demo report — sample data only. Not a legally binding custody record.',
    'show_demo_watermark': true,
  };

  List<Map<String, dynamic>> _buildDepartments(DateTime now) {
    final createdAt = _daysAgo(now, 30);

    return [
      _lookupItem(
        id: 'demo-dept-fabrication',
        name: 'Fabrication',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-dept-mechanical',
        name: 'Mechanical',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-dept-warehouse',
        name: 'Warehouse',
        createdAt: createdAt,
      ),
      _lookupItem(id: 'demo-dept-safety', name: 'Safety', createdAt: createdAt),
    ];
  }

  List<Map<String, dynamic>> _buildJobTitles(DateTime now) {
    final createdAt = _daysAgo(now, 30);

    return [
      _jobTitle(
        id: 'demo-job-welder',
        name: 'Welder',
        departmentId: 'demo-dept-fabrication',
        departmentName: 'Fabrication',
        createdAt: createdAt,
      ),
      _jobTitle(
        id: 'demo-job-fabricator',
        name: 'Fabricator',
        departmentId: 'demo-dept-fabrication',
        departmentName: 'Fabrication',
        createdAt: createdAt,
      ),
      _jobTitle(
        id: 'demo-job-mechanic',
        name: 'Mechanic',
        departmentId: 'demo-dept-mechanical',
        departmentName: 'Mechanical',
        createdAt: createdAt,
      ),
      _jobTitle(
        id: 'demo-job-rigger',
        name: 'Rigger',
        departmentId: 'demo-dept-mechanical',
        departmentName: 'Mechanical',
        createdAt: createdAt,
      ),
      _jobTitle(
        id: 'demo-job-storekeeper',
        name: 'Storekeeper',
        departmentId: 'demo-dept-warehouse',
        departmentName: 'Warehouse',
        createdAt: createdAt,
      ),
      _jobTitle(
        id: 'demo-job-safety-officer',
        name: 'Safety Officer',
        departmentId: 'demo-dept-safety',
        departmentName: 'Safety',
        createdAt: createdAt,
      ),
    ];
  }

  List<Map<String, dynamic>> _buildToolCategories(DateTime now) {
    final createdAt = _daysAgo(now, 30);

    return [
      _lookupItem(
        id: 'demo-category-power-tools',
        name: 'Power Tools',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-category-lifting',
        name: 'Lifting Gear',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-category-safety',
        name: 'Safety Equipment',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-category-hand-tools',
        name: 'Hand Tools',
        createdAt: createdAt,
      ),
      _lookupItem(
        id: 'demo-category-consumables',
        name: 'Consumables',
        createdAt: createdAt,
      ),
    ];
  }

  List<Map<String, dynamic>> _buildToolUnits(DateTime now) {
    final createdAt = _daysAgo(now, 30);

    return [
      _lookupItem(id: 'demo-unit-each', name: 'Each', createdAt: createdAt),
      _lookupItem(id: 'demo-unit-kg', name: 'KG', createdAt: createdAt),
      _lookupItem(id: 'demo-unit-mtr', name: 'MTR', createdAt: createdAt),
    ];
  }

  List<Map<String, dynamic>> _buildWorkers(DateTime now) {
    final createdAt = _daysAgo(now, 20);

    return [
      _worker(
        id: 'demo-worker-001',
        workerCode: 'WRK-001',
        hrCode: 'HR-1001',
        fullName: 'Ahmed Hassan',
        departmentId: 'demo-dept-fabrication',
        departmentName: 'Fabrication',
        jobTitleId: 'demo-job-welder',
        jobTitleName: 'Welder',
        phone: '+971500000001',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-002',
        workerCode: 'WRK-002',
        hrCode: 'HR-1002',
        fullName: 'Mohammed Ali',
        departmentId: 'demo-dept-fabrication',
        departmentName: 'Fabrication',
        jobTitleId: 'demo-job-fabricator',
        jobTitleName: 'Fabricator',
        phone: '+971500000002',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-003',
        workerCode: 'WRK-003',
        hrCode: 'HR-1003',
        fullName: 'Sunil Kumar',
        departmentId: 'demo-dept-safety',
        departmentName: 'Safety',
        jobTitleId: 'demo-job-safety-officer',
        jobTitleName: 'Safety Officer',
        phone: '+971500000003',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-004',
        workerCode: 'WRK-004',
        hrCode: 'HR-1004',
        fullName: 'Joseph Dsouza',
        departmentId: 'demo-dept-mechanical',
        departmentName: 'Mechanical',
        jobTitleId: 'demo-job-rigger',
        jobTitleName: 'Rigger',
        phone: '+971500000004',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-005',
        workerCode: 'WRK-005',
        hrCode: 'HR-1005',
        fullName: 'Ravi Nair',
        departmentId: 'demo-dept-mechanical',
        departmentName: 'Mechanical',
        jobTitleId: 'demo-job-mechanic',
        jobTitleName: 'Mechanic',
        phone: '+971500000005',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-006',
        workerCode: 'WRK-006',
        hrCode: 'HR-1006',
        fullName: 'Omar Farouk',
        departmentId: 'demo-dept-warehouse',
        departmentName: 'Warehouse',
        jobTitleId: 'demo-job-storekeeper',
        jobTitleName: 'Storekeeper',
        phone: '+971500000006',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-007',
        workerCode: 'WRK-007',
        hrCode: 'HR-1007',
        fullName: 'Victor Santos',
        departmentId: 'demo-dept-mechanical',
        departmentName: 'Mechanical',
        jobTitleId: 'demo-job-mechanic',
        jobTitleName: 'Mechanic',
        phone: '+971500000007',
        createdAt: createdAt,
      ),
      _worker(
        id: 'demo-worker-008',
        workerCode: 'WRK-008',
        hrCode: 'HR-1008',
        fullName: 'Peter Nabil',
        departmentId: 'demo-dept-fabrication',
        departmentName: 'Fabrication',
        jobTitleId: 'demo-job-fabricator',
        jobTitleName: 'Fabricator',
        phone: '+971500000008',
        createdAt: createdAt,
      ),
    ];
  }

  List<Map<String, dynamic>> _buildTools(DateTime now) {
    final createdAt = _daysAgo(now, 18);

    return [
      _tool(
        id: 'demo-tool-001',
        toolCode: 'TOOL-001',
        toolName: 'Welding Machine',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-power-tools',
        categoryName: 'Power Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-002',
        toolCode: 'TOOL-002',
        toolName: 'Angle Grinder 7 Inch',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-power-tools',
        categoryName: 'Power Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-003',
        toolCode: 'TOOL-003',
        toolName: 'Hammer Drill',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-power-tools',
        categoryName: 'Power Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-004',
        toolCode: 'TOOL-004',
        toolName: 'Chain Block 2 Ton',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-lifting',
        categoryName: 'Lifting Gear',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-005',
        toolCode: 'TOOL-005',
        toolName: 'Safety Harness',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-safety',
        categoryName: 'Safety Equipment',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-006',
        toolCode: 'TOOL-006',
        toolName: 'Gas Cutting Torch',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-power-tools',
        categoryName: 'Power Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-007',
        toolCode: 'TOOL-007',
        toolName: 'Spanner Set',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-hand-tools',
        categoryName: 'Hand Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-008',
        toolCode: 'TOOL-008',
        toolName: 'Cutting Disc',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-consumables',
        categoryName: 'Consumables',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-009',
        toolCode: 'TOOL-009',
        toolName: 'Measuring Tape 5 MTR',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-hand-tools',
        categoryName: 'Hand Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-010',
        toolCode: 'TOOL-010',
        toolName: 'Torque Wrench',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-hand-tools',
        categoryName: 'Hand Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-011',
        toolCode: 'TOOL-011',
        toolName: 'Lifting Belt 3 Ton',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-lifting',
        categoryName: 'Lifting Gear',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-012',
        toolCode: 'TOOL-012',
        toolName: 'Extension Cable',
        unitId: 'demo-unit-mtr',
        unitName: 'MTR',
        categoryId: 'demo-category-power-tools',
        categoryName: 'Power Tools',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-013',
        toolCode: 'TOOL-013',
        toolName: 'Face Shield',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-safety',
        categoryName: 'Safety Equipment',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-014',
        toolCode: 'TOOL-014',
        toolName: 'Drill Bit Set',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-consumables',
        categoryName: 'Consumables',
        createdAt: createdAt,
      ),
      _tool(
        id: 'demo-tool-015',
        toolCode: 'TOOL-015',
        toolName: 'Hydraulic Jack',
        unitId: 'demo-unit-each',
        unitName: 'Each',
        categoryId: 'demo-category-lifting',
        categoryName: 'Lifting Gear',
        createdAt: createdAt,
      ),
    ];
  }

  List<Map<String, dynamic>> _buildTransactions(DateTime now) {
    return [
      _transaction(
        id: 'demo-trx-001',
        transactionCode: 'TRX-001',
        type: 'issue',
        workerId: 'demo-worker-001',
        workerHrCode: 'HR-1001',
        workerName: 'Ahmed Hassan',
        workerDepartment: 'Fabrication',
        workerJobTitle: 'Welder',
        toolId: 'demo-tool-001',
        toolCode: 'TOOL-001',
        toolName: 'Welding Machine',
        unit: 'Each',
        toolCategory: 'Power Tools',
        quantity: 1,
        createdAt: _daysAgo(now, 2),
        note: 'Issued for vessel repair job.',
      ),
      _transaction(
        id: 'demo-trx-002',
        transactionCode: 'TRX-002',
        type: 'issue',
        workerId: 'demo-worker-001',
        workerHrCode: 'HR-1001',
        workerName: 'Ahmed Hassan',
        workerDepartment: 'Fabrication',
        workerJobTitle: 'Welder',
        toolId: 'demo-tool-002',
        toolCode: 'TOOL-002',
        toolName: 'Angle Grinder 7 Inch',
        unit: 'Each',
        toolCategory: 'Power Tools',
        quantity: 1,
        createdAt: _daysAgo(now, 1),
        note: 'Grinding work in workshop area.',
      ),
      _transaction(
        id: 'demo-trx-003',
        transactionCode: 'TRX-003',
        type: 'return',
        workerId: 'demo-worker-001',
        workerHrCode: 'HR-1001',
        workerName: 'Ahmed Hassan',
        workerDepartment: 'Fabrication',
        workerJobTitle: 'Welder',
        toolId: 'demo-tool-002',
        toolCode: 'TOOL-002',
        toolName: 'Angle Grinder 7 Inch',
        unit: 'Each',
        toolCategory: 'Power Tools',
        quantity: 1,
        createdAt: _hoursAgo(now, 5),
        note: 'Returned in good condition.',
      ),
      _transaction(
        id: 'demo-trx-004',
        transactionCode: 'TRX-004',
        type: 'issue',
        workerId: 'demo-worker-003',
        workerHrCode: 'HR-1003',
        workerName: 'Sunil Kumar',
        workerDepartment: 'Safety',
        workerJobTitle: 'Safety Officer',
        toolId: 'demo-tool-005',
        toolCode: 'TOOL-005',
        toolName: 'Safety Harness',
        unit: 'Each',
        toolCategory: 'Safety Equipment',
        quantity: 1,
        createdAt: _daysAgo(now, 2),
        note: 'Issued for height work inspection.',
      ),
      _transaction(
        id: 'demo-trx-005',
        transactionCode: 'TRX-005',
        type: 'issue',
        workerId: 'demo-worker-004',
        workerHrCode: 'HR-1004',
        workerName: 'Joseph Dsouza',
        workerDepartment: 'Mechanical',
        workerJobTitle: 'Rigger',
        toolId: 'demo-tool-004',
        toolCode: 'TOOL-004',
        toolName: 'Chain Block 2 Ton',
        unit: 'Each',
        toolCategory: 'Lifting Gear',
        quantity: 1,
        createdAt: _daysAgo(now, 3),
        note: 'Issued for lifting operation.',
      ),
      _transaction(
        id: 'demo-trx-006',
        transactionCode: 'TRX-006',
        type: 'return',
        workerId: 'demo-worker-004',
        workerHrCode: 'HR-1004',
        workerName: 'Joseph Dsouza',
        workerDepartment: 'Mechanical',
        workerJobTitle: 'Rigger',
        toolId: 'demo-tool-004',
        toolCode: 'TOOL-004',
        toolName: 'Chain Block 2 Ton',
        unit: 'Each',
        toolCategory: 'Lifting Gear',
        quantity: 1,
        createdAt: _hoursAgo(now, 3),
        note: 'Returned after operation completion.',
      ),
      _transaction(
        id: 'demo-trx-007',
        transactionCode: 'TRX-007',
        type: 'issue',
        workerId: 'demo-worker-005',
        workerHrCode: 'HR-1005',
        workerName: 'Ravi Nair',
        workerDepartment: 'Mechanical',
        workerJobTitle: 'Mechanic',
        toolId: 'demo-tool-009',
        toolCode: 'TOOL-009',
        toolName: 'Measuring Tape 5 MTR',
        unit: 'Each',
        toolCategory: 'Hand Tools',
        quantity: 1,
        createdAt: _hoursAgo(now, 2),
        note: 'Issued for engine room measurement.',
      ),
      _transaction(
        id: 'demo-trx-008',
        transactionCode: 'TRX-008',
        type: 'issue',
        workerId: 'demo-worker-006',
        workerHrCode: 'HR-1006',
        workerName: 'Omar Farouk',
        workerDepartment: 'Warehouse',
        workerJobTitle: 'Storekeeper',
        toolId: 'demo-tool-010',
        toolCode: 'TOOL-010',
        toolName: 'Torque Wrench',
        unit: 'Each',
        toolCategory: 'Hand Tools',
        quantity: 1,
        createdAt: _hoursAgo(now, 8),
        note: 'Issued for urgent maintenance request.',
      ),
      _transaction(
        id: 'demo-trx-009',
        transactionCode: 'TRX-009',
        type: 'return',
        workerId: 'demo-worker-006',
        workerHrCode: 'HR-1006',
        workerName: 'Omar Farouk',
        workerDepartment: 'Warehouse',
        workerJobTitle: 'Storekeeper',
        toolId: 'demo-tool-010',
        toolCode: 'TOOL-010',
        toolName: 'Torque Wrench',
        unit: 'Each',
        toolCategory: 'Hand Tools',
        quantity: 1,
        createdAt: _hoursAgo(now, 1),
        note: 'Returned after inspection.',
      ),
      _transaction(
        id: 'demo-trx-010',
        transactionCode: 'TRX-010',
        type: 'issue',
        workerId: 'demo-worker-007',
        workerHrCode: 'HR-1007',
        workerName: 'Victor Santos',
        workerDepartment: 'Mechanical',
        workerJobTitle: 'Mechanic',
        toolId: 'demo-tool-012',
        toolCode: 'TOOL-012',
        toolName: 'Extension Cable',
        unit: 'MTR',
        toolCategory: 'Power Tools',
        quantity: 15,
        createdAt: _hoursAgo(now, 4),
        note: 'Issued for temporary power connection.',
      ),
    ];
  }

  Map<String, dynamic> _lookupItem({
    required String id,
    required String name,
    required String createdAt,
  }) {
    return {
      'id': id,
      'company_id': demoCompanyId,
      'name': name,
      'status': 'active',
      'created_at': createdAt,
      'updated_at': createdAt,
    };
  }

  Map<String, dynamic> _jobTitle({
    required String id,
    required String name,
    required String departmentId,
    required String departmentName,
    required String createdAt,
  }) {
    return {
      'id': id,
      'company_id': demoCompanyId,
      'name': name,
      'department_id': departmentId,
      'department_name': departmentName,
      'status': 'active',
      'created_at': createdAt,
      'updated_at': createdAt,
    };
  }

  Map<String, dynamic> _worker({
    required String id,
    required String workerCode,
    required String hrCode,
    required String fullName,
    required String departmentId,
    required String departmentName,
    required String jobTitleId,
    required String jobTitleName,
    required String phone,
    required String createdAt,
  }) {
    return {
      'id': id,
      'company_id': demoCompanyId,
      'worker_code': workerCode,
      'hr_code': hrCode,
      'full_name': fullName,
      'department_id': departmentId,
      'department_name': departmentName,
      'job_title_id': jobTitleId,
      'job_title_name': jobTitleName,
      'phone': phone,
      'email': null,
      'status': 'active',
      'notes': 'Demo worker record.',
      'created_by_profile_id': demoProfileId,
      'created_by_profile_name': 'Demo User',
      'created_by_profile_email': 'demo@mina-system.local',
      'updated_by_profile_id': demoProfileId,
      'updated_by_profile_name': 'Demo User',
      'updated_by_profile_email': 'demo@mina-system.local',
      'created_at': createdAt,
      'updated_at': createdAt,
    };
  }

  Map<String, dynamic> _tool({
    required String id,
    required String toolCode,
    required String toolName,
    required String unitId,
    required String unitName,
    required String categoryId,
    required String categoryName,
    required String createdAt,
  }) {
    return {
      'id': id,
      'company_id': demoCompanyId,
      'tool_code': toolCode,
      'tool_name': toolName,
      'unit_id': unitId,
      'unit_name': unitName,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': 'Demo tool record.',
      'status': 'active',
      'created_by_profile_id': demoProfileId,
      'created_by_profile_name': 'Demo User',
      'created_by_profile_email': 'demo@mina-system.local',
      'updated_by_profile_id': demoProfileId,
      'updated_by_profile_name': 'Demo User',
      'updated_by_profile_email': 'demo@mina-system.local',
      'created_at': createdAt,
      'updated_at': createdAt,
    };
  }

  Map<String, dynamic> _transaction({
    required String id,
    required String transactionCode,
    required String type,
    required String workerId,
    required String workerHrCode,
    required String workerName,
    required String workerDepartment,
    required String workerJobTitle,
    required String toolId,
    required String toolCode,
    required String toolName,
    required String unit,
    required String toolCategory,
    required num quantity,
    required String createdAt,
    required String note,
  }) {
    return {
      'id': id,
      'company_id': demoCompanyId,
      'transaction_code': transactionCode,
      'transaction_type': type,
      'worker_id': workerId,
      'worker_hr_code_snapshot': workerHrCode,
      'worker_name_snapshot': workerName,
      'worker_department_snapshot': workerDepartment,
      'worker_job_title_snapshot': workerJobTitle,
      'tool_id': toolId,
      'tool_code_snapshot': toolCode,
      'tool_name_snapshot': toolName,
      'tool_unit_snapshot': unit,
      'tool_category_snapshot': toolCategory,
      'quantity': quantity,
      'created_at': createdAt,
      'proof_image_path': null,
      'note': note,
      'approval_required': false,
      'approval_status': 'not_required',
      'approval_document_path': null,
      'settlement_status': 'not_required',
      'settlement_note': null,
      'created_by_profile_id': demoProfileId,
      'created_by_name_snapshot': 'Demo User',
      'created_by_email_snapshot': 'demo@mina-system.local',
      'proof_image_uploaded_by_profile_id': null,
      'proof_image_uploaded_by_name_snapshot': null,
      'proof_image_uploaded_by_email_snapshot': null,
      'proof_image_uploaded_at': null,
      'updated_by_profile_id': null,
      'updated_by_name_snapshot': null,
      'updated_by_email_snapshot': null,
      'updated_at': createdAt,
      'is_voided': false,
      'voided_at': null,
      'voided_by_profile_id': null,
      'voided_by_name_snapshot': null,
      'voided_by_email_snapshot': null,
      'void_reason': null,
    };
  }

  String _daysAgo(DateTime now, int days) {
    return now.subtract(Duration(days: days)).toIso8601String();
  }

  String _hoursAgo(DateTime now, int hours) {
    return now.subtract(Duration(hours: hours)).toIso8601String();
  }
}
