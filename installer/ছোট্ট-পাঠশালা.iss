#define AppName "ছোট্ট পাঠশালা"
#define AppVersion "1.0.0"
#define AppExeName "ছোট্ট পাঠশালা.exe"

[Setup]
AppId={{D8BDBA64-30BC-4E6D-A1C9-0D8F5B7D1A20}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=ছোট্ট পাঠশালা
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
OutputDir=..\build\windows\installer
OutputBaseFilename=ছোট্ট-পাঠশালা-ইনস্টলার
SetupIconFile=..\windows\runner\resources\app_icon.ico
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
DisableProgramGroupPage=yes
WizardStyle=modern
Compression=lzma2/ultra64
SolidCompression=yes
CloseApplications=yes
RestartApplications=no

[Tasks]
Name: "desktopicon"; Description: "ডেস্কটপে শর্টকাট তৈরি করুন"; GroupDescription: "অতিরিক্ত সুবিধা:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "ছোট্ট পাঠশালা চালু করুন"; Flags: postinstall nowait skipifsilent
