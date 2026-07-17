#define MyAppName "M.I.N.A System"
#define MyAppExeName "mina_system.exe"

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

#ifndef MyAppVersionQuad
  #define MyAppVersionQuad "1.0.0.0"
#endif

#ifndef MyAppPublisher
  #define MyAppPublisher "King Narmar"
#endif

#ifndef BuildOutputDir
  #define BuildOutputDir "..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "..\dist\windows"
#endif

[Setup]
AppId={{CDA3A0D2-7C8C-4D5E-A997-95724F2D1881}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\M.I.N.A System
DefaultGroupName=M.I.N.A System
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=MINA-System-Windows-x64-Setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes
UsePreviousAppDir=yes
UsePreviousGroup=yes
UsePreviousTasks=yes
CloseApplications=yes
RestartApplications=no
VersionInfoVersion={#MyAppVersionQuad}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Windows Installer
VersionInfoProductName={#MyAppName}
VersionInfoOriginalFileName=MINA-System-Windows-x64-Setup.exe
VersionInfoCopyright=Copyright (C) 2026 {#MyAppPublisher}. All rights reserved.

#ifdef EnableSigning
SignTool=mina_sign
SignedUninstaller=yes
#endif

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildOutputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\M.I.N.A System"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall M.I.N.A System"; Filename: "{uninstallexe}"
Name: "{autodesktop}\M.I.N.A System"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,M.I.N.A System}"; Flags: nowait postinstall skipifsilent
