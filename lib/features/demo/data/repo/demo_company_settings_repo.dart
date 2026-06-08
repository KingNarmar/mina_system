import 'dart:typed_data';

import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/company_settings/data/repo/company_settings_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';

class DemoCompanySettingsRepo extends CompanySettingsRepo {
  DemoCompanySettingsRepo();

  static final DateTime _effectiveDate = DateTime(2026);

  @override
  Future<CompanyProfileModel> getCompanyProfile({
    required String companyId,
  }) async {
    return CompanyProfileModel(
      id: companyId,
      name: 'Demo Marine Services LLC',
      tradeName: 'Demo Marine Services LLC',
      legalName: 'Demo Marine Services LLC',
      tradeLicenseNo: 'DEMO-LICENSE-0001',
      taxRegistrationNo: 'DEMO-TRN-0001',
      addressLine1: 'Dubai Maritime Demo Yard',
      city: 'Dubai',
      country: 'United Arab Emirates',
      phone: '+971 50 000 0000',
      email: 'demo@mina-system.local',
      website: 'https://kingnarmar.com/mina-system',
      timezone: 'Asia/Dubai',
      createdByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileId: DemoSeedService.demoProfileId,
      createdByProfileName: 'Demo User',
      createdByProfileEmail: 'demo@mina-system.local',
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      createdAt: _effectiveDate,
      updatedAt: _effectiveDate,
    );
  }

  @override
  Future<CompanyReportSettingsModel> getCompanyReportSettings({
    required String companyId,
  }) async {
    return CompanyReportSettingsModel(
      id: 'demo-report-settings-001',
      companyId: companyId,
      defaultTimezone: 'Asia/Dubai',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: 'HH:mm',
      showCompanyLogo: false,
      showCompanyDetails: true,
      showDocumentControl: true,
      showGeneratedBy: true,
      reportFooterText:
          'DEMO report — sample data only. Not a legally binding custody record.',
      custodyResponsibilityStatement:
          'This demo custody report is generated from sample local data only. '
          'In live mode, the worker remains responsible for issued items until '
          'they are physically returned and recorded by the store team.',
      lossDamageResponsibilityStatement:
          'This demo loss/damage report is generated for testing only. '
          'Live approvals must follow the company policy and authorized workflow.',
      createdByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileId: DemoSeedService.demoProfileId,
      createdByProfileName: 'Demo User',
      createdByProfileEmail: 'demo@mina-system.local',
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      createdAt: _effectiveDate,
      updatedAt: _effectiveDate,
    );
  }

  @override
  Future<List<CompanyDocumentTemplateModel>> getCompanyDocumentTemplates({
    required String companyId,
  }) async {
    return [
      _template(
        companyId: companyId,
        id: 'demo-template-worker-custody',
        reportType: 'worker_custody_report',
        title: 'Worker Custody Report',
        code: 'DEMO-WCR',
      ),
      _template(
        companyId: companyId,
        id: 'demo-template-tool-history',
        reportType: 'tool_history_report',
        title: 'Tool History Report',
        code: 'DEMO-THR',
      ),
      _template(
        companyId: companyId,
        id: 'demo-template-transactions',
        reportType: 'transactions_report',
        title: 'Transactions Report',
        code: 'DEMO-TRX',
      ),
      _template(
        companyId: companyId,
        id: 'demo-template-lost-damaged',
        reportType: 'lost_damaged_report',
        title: 'Lost & Damaged Report',
        code: 'DEMO-LDR',
      ),
      _template(
        companyId: companyId,
        id: 'demo-template-loss-damage-approval',
        reportType: 'loss_damage_report',
        title: 'Lost/Damaged Approval Report',
        code: 'DEMO-LDA',
      ),
      _template(
        companyId: companyId,
        id: 'demo-template-tool-summary',
        reportType: 'tool_summary_report',
        title: 'Tool Summary Report',
        code: 'DEMO-TSR',
      ),
    ];
  }

  @override
  Future<CompanyProfileModel> updateCompanyProfile({
    required CompanyProfileModel profile,
  }) {
    throw UnsupportedError(
      'Editing demo company settings is not available yet.',
    );
  }

  @override
  Future<CompanyReportSettingsModel> updateCompanyReportSettings({
    required CompanyReportSettingsModel reportSettings,
  }) {
    throw UnsupportedError(
      'Editing demo report settings is not available yet.',
    );
  }

  @override
  Future<CompanyDocumentTemplateModel> updateCompanyDocumentTemplate({
    required CompanyDocumentTemplateModel documentTemplate,
  }) {
    throw UnsupportedError(
      'Editing demo document templates is not available yet.',
    );
  }

  @override
  Future<CompanyProfileModel> uploadCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) {
    throw UnsupportedError('Demo mode does not upload files.');
  }

  CompanyDocumentTemplateModel _template({
    required String companyId,
    required String id,
    required String reportType,
    required String title,
    required String code,
  }) {
    return CompanyDocumentTemplateModel(
      id: id,
      companyId: companyId,
      reportType: reportType,
      documentTitle: title,
      documentCode: code,
      issueNo: '01',
      revisionNo: '00',
      effectiveDate: _effectiveDate,
      preparedByTitle: 'Storekeeper',
      checkedByTitle: 'Warehouse Manager',
      approvedByTitle: 'Operations Manager',
      workerSignatureLabel: 'Worker Signature',
      managerSignatureLabel: 'Manager Signature',
      storekeeperSignatureLabel: 'Storekeeper Signature',
      isActive: true,
      createdByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileId: DemoSeedService.demoProfileId,
      createdByProfileName: 'Demo User',
      createdByProfileEmail: 'demo@mina-system.local',
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      createdAt: _effectiveDate,
      updatedAt: _effectiveDate,
    );
  }
}
