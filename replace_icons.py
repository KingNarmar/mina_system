import os
import re

# Base mapping with predefined names
icon_mapping = {
    'fact_check_outlined': 'auditHistory',
    'edit_outlined': 'edit',
    'delete_outline': 'deactivate',
    'restore_outlined': 'restore',
    'visibility_outlined': 'view',
    'info_outline': 'details',
    'add_rounded': 'add',
    'close_rounded': 'close',
    'search_rounded': 'search',
    'filter_list_rounded': 'filter',
    'upload_file_outlined': 'upload',
    'download_rounded': 'download',
    'refresh_rounded': 'retry',
    'keyboard_arrow_down_rounded': 'dropdown',
    'swap_horiz': 'switchCompany',
    'logout': 'logout',
    'check_circle_outline': 'approve',
    'cancel_outlined': 'reject',
    'price_check_outlined': 'settle',
    'task_alt_outlined': 'done',
    'apartment_rounded': 'company',
    'person_outline': 'worker',
    'people_outline': 'workers',
    'build_outlined': 'tool',
    'dashboard_outlined': 'dashboard',
    'swap_horiz_outlined': 'transactions',
    'analytics_outlined': 'reports',
    'tune_outlined': 'lookups',
    'groups_outlined': 'team',
    'settings_outlined': 'settings',
    'visibility': 'passwordVisible',
    'visibility_off': 'passwordHidden',
    'description_outlined': 'reportDocument',
    'article_outlined': 'documentTemplate',
    'picture_as_pdf_outlined': 'pdf',
    'tune_rounded': 'settingsTune',
    'assignment_turned_in_outlined': 'responsibility',
    'tag_outlined': 'tag',
    'history_edu_outlined': 'revision',
    'verified_outlined': 'verified',
    'verified_user_outlined': 'verifiedUser',
    'schedule_rounded': 'schedule',
    'image_outlined': 'image',
    'broken_image_outlined': 'brokenImage',
    'check_circle_outline_rounded': 'success',
    'error_outline_rounded': 'error',
    'warning_amber_rounded': 'warning',
    'info_outline_rounded': 'info',
    'wifi_off_rounded': 'offline'
}

def to_camel_case(snake_str):
    components = snake_str.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])

# First pass: find all Icons used
all_icons_used = set()
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(r'(?<!App)Icons\.([a-zA-Z0-9_]+)', content)
                for m in matches:
                    all_icons_used.add(m)

# Add missing to mapping with camelCase
for icon in all_icons_used:
    if icon not in icon_mapping:
        if icon == 'search':
            icon_mapping[icon] = 'search'
        elif icon == 'close':
            icon_mapping[icon] = 'close'
        elif icon == 'add':
            icon_mapping[icon] = 'add'
        elif icon == 'edit':
            icon_mapping[icon] = 'edit'
        else:
            icon_mapping[icon] = to_camel_case(icon)

# We need to collect new icons that must be added to app_icons.dart
# Wait, let's load what's currently in app_icons.dart
app_icons_path = os.path.join('lib', 'core', 'theme', 'app_icons.dart')
with open(app_icons_path, 'r', encoding='utf-8') as f:
    app_icons_content = f.read()

existing_app_icons = re.findall(r'static const IconData ([a-zA-Z0-9_]+)', app_icons_content)

new_icons_to_add = []
for icon, mapped in icon_mapping.items():
    if mapped not in existing_app_icons and icon in all_icons_used:
        new_icons_to_add.append((mapped, icon))

# Append new icons to app_icons.dart
if new_icons_to_add:
    # Find the last closing brace
    last_brace_idx = app_icons_content.rfind('}')
    new_content = app_icons_content[:last_brace_idx]
    new_content += '\n  // Automatically added semantic icons\n'
    # Avoid duplicates in new_icons_to_add
    added_mapped = set(existing_app_icons)
    for mapped, icon in sorted(new_icons_to_add, key=lambda x: x[0]):
        if mapped not in added_mapped:
            new_content += f'  static const IconData {mapped} = Icons.{icon};\n'
            added_mapped.add(mapped)
    new_content += '}\n'
    with open(app_icons_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

import_statement = "import 'package:mina_system/core/theme/app_icons.dart';"

def add_import(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # check if import already exists
    if any('app_icons.dart' in line for line in lines):
        return

    # find where to insert
    # insert after the last import
    last_import = -1
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    
    if last_import != -1:
        lines.insert(last_import + 1, import_statement + '\n')
    else:
        # no imports, insert at top
        lines.insert(0, import_statement + '\n\n')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

# Second pass: replace in all files and handle imports
# track which files are modified
files_needing_import = set()

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            # do not modify app_icons.dart itself during this pass
            if os.path.abspath(file_path) == os.path.abspath(app_icons_path):
                continue
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            modified = False
            # Find all Icons.xxx
            def repl(m):
                icon_name = m.group(1)
                if icon_name in icon_mapping:
                    return f'AppIcons.{icon_mapping[icon_name]}'
                return m.group(0) # fallback
            
            new_content, count = re.subn(r'(?<!App)Icons\.([a-zA-Z0-9_]+)', repl, content)
            
            if count > 0:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                # Check if it's a part file
                part_of_match = re.search(r"^part of '([^']+)';", new_content, re.MULTILINE)
                if part_of_match:
                    parent_file_rel = part_of_match.group(1)
                    parent_file_path = os.path.normpath(os.path.join(os.path.dirname(file_path), parent_file_rel))
                    files_needing_import.add(parent_file_path)
                else:
                    files_needing_import.add(file_path)

# Apply imports
for fp in files_needing_import:
    if os.path.exists(fp):
        add_import(fp)

print("Icons replaced and imports added.")
