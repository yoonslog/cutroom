Unicode true
!include "MUI2.nsh"
!include "FileFunc.nsh"

!define APPNAME "Velo"
!define APPEXE "Velo.exe"
!ifndef APPVER
!define APPVER "0.0.0"
!endif
!define PUBLISHER "Velo"
!define SITE "https://yoonslog.github.io/cutroom/"
!define REGKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Velo"
!define OLDKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\CutRoom"

Name "${APPNAME} ${APPVER}"
OutFile "${OUTFILE}"
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\Programs\Velo"
InstallDirRegKey HKCU "Software\Velo" "InstallDir"
SetCompressor /SOLID lzma
ShowInstDetails hide
ShowUnInstDetails hide

VIProductVersion "${APPVER}.0"
VIAddVersionKey /LANG=1042 "ProductName" "Velo 영상 편집기"
VIAddVersionKey /LANG=1042 "FileDescription" "Velo 영상 편집기 설치 프로그램"
VIAddVersionKey /LANG=1042 "FileVersion" "${APPVER}"
VIAddVersionKey /LANG=1042 "ProductVersion" "${APPVER}"
VIAddVersionKey /LANG=1042 "CompanyName" "${PUBLISHER}"
VIAddVersionKey /LANG=1042 "LegalCopyright" "© Velo"

!define MUI_ICON "${ICONFILE}"
!define MUI_UNICON "${ICONFILE}"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Velo 영상 편집기를 설치합니다"
!define MUI_WELCOMEPAGE_TEXT "Velo는 브라우저 기술로 돌아가는 가벼운 영상 편집기입니다.$\r$\n$\r$\n관리자 권한 없이 내 계정 폴더에 설치되고, 새 버전이 나오면 앱을 켤 때 자동으로 받습니다.$\r$\n$\r$\n계속하려면 [다음]을 누르세요."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APPEXE}"
!define MUI_FINISHPAGE_RUN_TEXT "Velo 지금 실행"
!define MUI_FINISHPAGE_LINK "Velo 홈페이지 열기"
!define MUI_FINISHPAGE_LINK_LOCATION "${SITE}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Korean"

Function .onInit
  ; 이미 실행 중이면 안내
  FindWindow $0 "" "Velo"
  StrCmp $0 0 0 ask
  FindWindow $0 "" "컷룸 영상 편집기"
  StrCmp $0 0 ok
  ask:
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "Velo가 실행 중입니다. 먼저 닫은 뒤 [확인]을 누르세요." IDOK ok
    Abort
  ok:
FunctionEnd

Section "설치"
  SetOutPath "$INSTDIR"
  File "${SRCDIR}\Velo.exe"
  File "${SRCDIR}\resources.neu"
  File /oname=읽어주세요.txt "${SRCDIR}\README-first.txt"
  File "${SRCDIR}\Velo.ico"


  ; ---- 예전 '컷룸'(CutRoom) 설치본 옮기기: 작품 데이터를 그대로 가져오고 예전 아이콘을 지운다
  StrCpy $1 "$LOCALAPPDATA\Programs\CutRoom"
  StrCmp $1 $INSTDIR mig_done
  IfFileExists "$1\*.*" 0 mig_done
    IfFileExists "$1\.storage\*.*" 0 +3
      CreateDirectory "$INSTDIR\.storage"
      CopyFiles /SILENT "$1\.storage\*.*" "$INSTDIR\.storage"
    IfFileExists "$1\CutRoom.exe.WebView2\*.*" 0 +2
      Rename "$1\CutRoom.exe.WebView2" "$INSTDIR\Velo.exe.WebView2"
    RMDir /r "$1"
  mig_done:
  Delete "$DESKTOP\컷룸.lnk"
  Delete "$SMPROGRAMS\컷룸\*.lnk"
  RMDir "$SMPROGRAMS\컷룸"
  DeleteRegKey HKCU "${OLDKEY}"
  DeleteRegKey HKCU "Software\CutRoom"
  CreateDirectory "$SMPROGRAMS\Velo"
  CreateShortCut "$SMPROGRAMS\Velo\Velo.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\Velo.ico" 0
  CreateShortCut "$SMPROGRAMS\Velo\Velo 제거.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut "$DESKTOP\Velo.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\Velo.ico" 0

  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Velo" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${REGKEY}" "DisplayName" "Velo 영상 편집기"
  WriteRegStr HKCU "${REGKEY}" "DisplayVersion" "${APPVER}"
  WriteRegStr HKCU "${REGKEY}" "DisplayIcon" "$INSTDIR\Velo.ico"
  WriteRegStr HKCU "${REGKEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKCU "${REGKEY}" "URLInfoAbout" "${SITE}"
  WriteRegStr HKCU "${REGKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${REGKEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKCU "${REGKEY}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegDWORD HKCU "${REGKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${REGKEY}" "NoRepair" 1
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "${REGKEY}" "EstimatedSize" "$0"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\${APPEXE}"
  Delete "$INSTDIR\resources.neu"
  Delete "$INSTDIR\읽어주세요.txt"
  Delete "$INSTDIR\Velo.ico"
  Delete "$INSTDIR\uninstall.exe"
  Delete "$INSTDIR\.storage\*.*"
  RMDir "$INSTDIR\.storage"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\Velo\Velo.lnk"
  Delete "$SMPROGRAMS\Velo\Velo 제거.lnk"
  RMDir "$SMPROGRAMS\Velo"
  Delete "$DESKTOP\Velo.lnk"
  DeleteRegKey HKCU "${REGKEY}"
  DeleteRegKey HKCU "Software\Velo"
SectionEnd
