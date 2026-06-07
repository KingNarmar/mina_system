import 'package:mina_system/features/current_context/data/models/company_model.dart';
import 'package:mina_system/features/current_context/data/models/profile_model.dart';

abstract class DemoCurrentContextData {
  static const ProfileModel profile = ProfileModel(
    id: 'demo-profile-001',
    fullName: 'Demo User',
    email: 'demo@mina-system.local',
  );

  static const CompanyModel company = CompanyModel(
    id: 'demo-company-001',
    name: 'Demo Marine Services LLC',
    role: 'owner',
    timezone: 'Asia/Dubai',
  );

  static const List<CompanyModel> companies = [company];
}
