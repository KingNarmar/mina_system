class LookupsCubitInitialData {
  static const List<String> initialDepartments = [
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

  static const Map<String, List<String>> initialJobTitlesByDepartment = {
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

  static const List<String> initialToolUnits = ['Each', 'KG', 'MTR'];

  static const List<String> initialToolCategories = [
    'Power Tools',
    'Welding Tools',
    'Consumables',
    'Measuring Tools',
    'Hand Tools',
    'Safety Tools',
    'Lifting Tools',
    'Electrical Tools',
  ];
}
