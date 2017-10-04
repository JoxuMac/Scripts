:: SCRIPT HIPER-V SELECTOR
:: Actualizado el 04/10/2017
:: @JoxuMac
@echo off
 :: Run this script with elevation
call :RequestAdminElevation "%~dpfs0" %* || goto:eof
setlocal enableextensions enabledelayedexpansion
set /a "x = 0"
chcp 1252
:menu
	echo.
	echo Hiper-V Selector
	echo (1) Consultar estado Hiper-V
	echo (2) Activar Hiper-V
	echo (3) Desactivar Hiper-V
	echo (4) Salir
	set /p option=¿Que desea hacer?:
    if %option% equ 1 (
		goto :consultar
	)
	if %option% equ 2 (
		goto :activar
	)
	if %option% equ 3 (
		goto :desactivar
	)
	if %option% equ 4 (
		goto :close
	)
	goto :menu
endlocal

:consultar
	set /p consulta=¿Deseas consultar el estado del Hiper-V [s/n]?: 
	set resultypes=none
	if %consulta% equ s ( 
		set resultypes=tr
	)
	if %consulta% equ S (  
		set resultypes=tr
	)	
	if %consulta% equ n ( 
		set resultypes=fls
	)
	if %consulta% equ N ( 
		set resultypes=fls
	)
	if %resultypes% equ tr ( 
		cmd /k "bcdedit"
		echo Hiper-V ACTIVADO
		goto :menu
	)
	if %resultypes% equ fls (
		goto :menu
	)
	echo Entrada no valida
	goto :consultar
endlocal

:activar
	set /p consulta=¿Deseas activar el Hiper-V [s/n]?: 
	set resultypes=none
	if %consulta% equ s ( 
		set resultypes=tr
	)
	if %consulta% equ S (  
		set resultypes=tr
	)	
	if %consulta% equ n ( 
		set resultypes=fls
	)
	if %consulta% equ N ( 
		set resultypes=fls
	)
	if %resultypes% equ tr ( 
		cmd /k "bcdedit /set hypervisorlaunchtype auto"
		echo Hiper-V ACTIVADO
		goto :menu
	)
	if %resultypes% equ fls (
		echo Hiper-V NO Activado
		goto :menu
	)
	echo Entrada no valida
	goto :activar
endlocal

:desactivar
	set /p consulta=¿Deseas desactivar el Hiper-V [s/n]?: 
	set resultypes=none
	if %consulta% equ s ( 
		set resultypes=tr
	)
	if %consulta% equ S (  
		set resultypes=tr
	)	
	if %consulta% equ n ( 
		set resultypes=fls
	)
	if %consulta% equ N ( 
		set resultypes=fls
	)
	if %resultypes% equ tr ( 
		cmd /k "bcdedit /set hypervisorlaunchtype off"
		echo Hiper-V DESACTIVADO
		goto :menu
	)
	if %resultypes% equ fls (
		echo Hiper-V NO Desactivado
		goto :menu
	)
	echo Entrada no valida
	goto :desactivar
endlocal

:close
endlocal

:RequestAdminElevation
setlocal ENABLEDELAYEDEXPANSION & set "_FilePath=%~1"
  if NOT EXIST "!_FilePath!" (echo/Read RequestAdminElevation usage information)
  :: UAC.ShellExecute only works with 8.3 filename, so use %~s1
  set "_FN=_%~ns1" & echo/%TEMP%| findstr /C:"(" >nul && (echo/ERROR: %%TEMP%% path can not contain parenthesis &pause &endlocal &fc;: 2>nul & goto:eof)
  :: Remove parenthesis from the temp filename
  set _FN=%_FN:(=%
  set _vbspath="%temp:~%\%_FN:)=%.vbs" & set "_batpath=%temp:~%\%_FN:)=%.bat"

  :: Test if we gave admin rights
  fltmc >nul 2>&1 || goto :_getElevation

  :: Elevation successful
  (if exist %_vbspath% ( del %_vbspath% )) & (if exist %_batpath% ( del %_batpath% )) 
  :: Set ERRORLEVEL 0, set original folder and exit
  endlocal & CD /D "%~dp1" & ver >nul & goto:eof

  :_getElevation
  echo/Requesting elevation...
  :: Try to create %_vbspath% file. If failed, exit with ERRORLEVEL 1
  echo/Set UAC = CreateObject^("Shell.Application"^) > %_vbspath% || (echo/&echo/Unable to create %_vbspath% & endlocal &md; 2>nul &goto:eof) 
  echo/UAC.ShellExecute "%_batpath%", "", "", "runas", 1 >> %_vbspath% & echo/wscript.Quit(1)>> %_vbspath%
  :: Try to create %_batpath% file. If failed, exit with ERRORLEVEL 1
  echo/@%* > "%_batpath%" || (echo/&echo/Unable to create %_batpath% & endlocal &md; 2>nul &goto:eof)
  echo/@if %%errorlevel%%==9009 (echo/^&echo/Admin user could not read the batch file. If running from a mapped drive or UNC path, check if Admin user can read it.)^&echo/^& @if %%errorlevel%% NEQ 0 pause >> "%_batpath%"

  :: Run %_vbspath%, that calls %_batpath%, that calls the original file
  %_vbspath% && (echo/&echo/Failed to run VBscript %_vbspath% &endlocal &md; 2>nul & goto:eof)

  :: Vbscript has been run, exit with ERRORLEVEL -1
  echo/&echo/Elevation was requested on a new CMD window &endlocal &fc;: 2>nul & goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::