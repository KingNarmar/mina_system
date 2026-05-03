import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/lookup_helpers.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit()
    : super(
        const LookupsState(
          departments: _initialDepartments,
          jobTitlesByDepartment: _initialJobTitlesByDepartment,
          toolUnits: _initialToolUnits,
          toolCategories: _initialToolCategories,
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
  static const List<String> _initialToolUnits = ['Each', 'KG', 'MTR'];

  static const List<String> _initialToolCategories = [
    'Power Tools',
    'Welding Tools',
    'Consumables',
    'Measuring Tools',
    'Hand Tools',
    'Safety Tools',
    'Lifting Tools',
    'Electrical Tools',
  ];
  void addDepartment(String department) {
    final cleanDepartment = department.trim();

    if (cleanDepartment.isEmpty) {
      return;
    }

    if (containsValue(state.departments, cleanDepartment)) {
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
      return !isSameValue(item, department);
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

    if (containsValue(currentJobTitles, cleanJobTitle)) {
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
      return !isSameValue(item, jobTitle);
    }).toList();

    final updatedJobTitlesByDepartment = Map<String, List<String>>.from(
      state.jobTitlesByDepartment,
    );

    updatedJobTitlesByDepartment[department] = updatedJobTitles;

    emit(state.copyWith(jobTitlesByDepartment: updatedJobTitlesByDepartment));
  }

  void addToolUnit(String unit) {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return;
    }

    if (containsValue(state.toolUnits, cleanUnit)) {
      return;
    }

    final updatedToolUnits = List<String>.from(state.toolUnits)..add(cleanUnit);

    emit(state.copyWith(toolUnits: updatedToolUnits));
  }

  void deleteToolUnit(String unit) {
    final updatedToolUnits = state.toolUnits.where((item) {
      return !isSameValue(item, unit);
    }).toList();

    emit(state.copyWith(toolUnits: updatedToolUnits));
  }

  void addToolCategory(String category) {
    final cleanCategory = category.trim();

    if (cleanCategory.isEmpty) {
      return;
    }

    if (containsValue(state.toolCategories, cleanCategory)) {
      return;
    }

    final updatedToolCategories = List<String>.from(state.toolCategories)
      ..add(cleanCategory);

    emit(state.copyWith(toolCategories: updatedToolCategories));
  }

  void deleteToolCategory(String category) {
    final updatedToolCategories = state.toolCategories.where((item) {
      return !isSameValue(item, category);
    }).toList();

    emit(state.copyWith(toolCategories: updatedToolCategories));
  }
}
