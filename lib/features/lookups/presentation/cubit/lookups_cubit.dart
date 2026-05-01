import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit()
    : super(
        const LookupsState(
          departments: _initialDepartments,
          jobTitlesByDepartment: _initialJobTitlesByDepartment,
        ),
      );

  static const List<String> _initialDepartments = [
    'Fabrication',
    'Carpentry',
    'Mechanical',
    'Safety',
    'Painting',
    'Warehouse',
    'Electrical',
    'Operation',
    'Estimation',
    'Accounts',
    'Purchase',
    'IT',
    'HR',
    'Admin',
  ];

  static const Map<String, List<String>> _initialJobTitlesByDepartment = {
    'Fabrication': [
      'HOD Fabrication',
      'Fabrication Supervisor',
      'Welder',
      'Fabricator',
      'Fitter',
      'Helper',
    ],
    'Carpentry': [
      'HOD Carpentry',
      'Carpentry Supervisor',
      'Carpenter',
      'Helper',
    ],
    'Mechanical': [
      'HOD Mechanical',
      'Mechanical Supervisor',
      'Mechanic',
      'Pipe Fitter',
      'Helper',
    ],
    'Safety': ['HOD Safety', 'Safety Officer', 'Safety Assistant'],
    'Painting': ['HOD Painting', 'Painting Supervisor', 'Painter', 'Helper'],
    'Warehouse': [
      'Warehouse Manager',
      'Storekeeper',
      'Warehouse Assistant',
      'Helper',
    ],
    'Electrical': [
      'HOD Electrical',
      'Electrical Supervisor',
      'Electrician',
      'Helper',
    ],
    'Operation': ['HOD Operation', 'Operation Supervisor', 'Foreman', 'Helper'],
    'Estimation': ['HOD Estimation', 'Estimator', 'Estimation Engineer'],
    'Accounts': ['Chief Accountant', 'Accountant', 'Accounts Assistant'],
    'Purchase': ['Purchase Manager', 'Purchaser', 'Purchase Assistant'],
    'IT': ['IT Manager', 'IT Support', 'System Administrator'],
    'HR': ['HR Manager', 'HR Officer', 'HR Assistant'],
    'Admin': ['Admin Manager', 'Admin Assistant', 'Document Controller'],
  };

  void addDepartment(String department) {
    final cleanDepartment = department.trim();

    if (cleanDepartment.isEmpty) {
      return;
    }

    if (_containsValue(state.departments, cleanDepartment)) {
      return;
    }

    final updatedDepartments = List<String>.from(state.departments)
      ..add(cleanDepartment);

    final updatedJobTitlesByDepartment = Map<String, List<String>>.from(
      state.jobTitlesByDepartment,
    )..putIfAbsent(cleanDepartment, () => []);

    emit(
      state.copyWith(
        departments: updatedDepartments,
        jobTitlesByDepartment: updatedJobTitlesByDepartment,
      ),
    );
  }

  void deleteDepartment(String department) {
    final updatedDepartments = state.departments.where((item) {
      return !_isSameValue(item, department);
    }).toList();

    final updatedJobTitlesByDepartment = Map<String, List<String>>.from(
      state.jobTitlesByDepartment,
    )..remove(department);

    emit(
      state.copyWith(
        departments: updatedDepartments,
        jobTitlesByDepartment: updatedJobTitlesByDepartment,
      ),
    );
  }

  void addJobTitle({required String department, required String jobTitle}) {
    final cleanDepartment = department.trim();
    final cleanJobTitle = jobTitle.trim();

    if (cleanDepartment.isEmpty || cleanJobTitle.isEmpty) {
      return;
    }

    final currentJobTitles = state.jobTitlesByDepartment[cleanDepartment] ?? [];

    if (_containsValue(currentJobTitles, cleanJobTitle)) {
      return;
    }

    final updatedJobTitlesByDepartment = Map<String, List<String>>.from(
      state.jobTitlesByDepartment,
    );

    updatedJobTitlesByDepartment[cleanDepartment] = [
      ...currentJobTitles,
      cleanJobTitle,
    ];

    emit(state.copyWith(jobTitlesByDepartment: updatedJobTitlesByDepartment));
  }

  void deleteJobTitle({required String department, required String jobTitle}) {
    final currentJobTitles = state.jobTitlesByDepartment[department] ?? [];

    final updatedJobTitles = currentJobTitles.where((item) {
      return !_isSameValue(item, jobTitle);
    }).toList();

    final updatedJobTitlesByDepartment = Map<String, List<String>>.from(
      state.jobTitlesByDepartment,
    );

    updatedJobTitlesByDepartment[department] = updatedJobTitles;

    emit(state.copyWith(jobTitlesByDepartment: updatedJobTitlesByDepartment));
  }

  bool _containsValue(List<String> values, String value) {
    return values.any((item) => _isSameValue(item, value));
  }

  bool _isSameValue(String firstValue, String secondValue) {
    return _normalizeText(firstValue) == _normalizeText(secondValue);
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }
}
