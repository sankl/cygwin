@if (@X)==(@Y) @goto :dummy @end/* Line required to execute bottom of this script with WSH and pre-download setup-x86.exe

:: Wrapper script to run Cygwin command.
:: If there is no Cygwin, install it on a first run.
:: 
:: Usage: cw [cmd and args] : launch Cygwin command in mintty window (default is bash)
::
:: Proxy: set http_proxy=proxy.server.com:port
@echo off

setlocal

if not "%~2"=="" (set dest=%~2\cygwin) else (set dest=%~dp0\cygwin)

if "%~1"=="install"         goto:install
if "%~1"=="install_apt_cyg" goto:install_apt_cyg

if not exist %~dp0cygwin\bin\mintty.exe call:install

if defined http_proxy (
    set http_proxy=http://%HTTP_PROXY%
    set https_proxy=http://%HTTP_PROXY%
    set ftp_proxy=http://%HTTP_PROXY%
)

set _c=%*
if "%~1"=="" set _c=bash

%~dp0cygwin\bin\mintty.exe        ^
    -o Font=Consolas              ^
    -o CursorType=block           ^
    -o Term=xterm-256color        ^
    -o CursorBlinks=no            ^
    -o FontSmoothing=full         ^
    -o Columns=200                ^
    -o Rows=60                    ^
    -o ScrollbackLines=60000      ^
    -o Locale=C                   ^
    -o Charset=UTF-8              ^
    -o BackgroundColour=0,0,0     ^
    -o FontHeight=9               ^
    -o BoldAsFont=yes             ^
    -o BoldAsColour=yes           ^
    -o CopyAsRTF=no  %log%  %_p%  ^
    /bin/env -u _c PATH=/bin VIM=~/vim/.vim CYGWIN=wincmdln %_c%

endlocal & exit /b %errorlevel%

:install
  echo ** Installing/upgrading Cygwin in %dest% %HTTP_PROXY% >&2
  call:shortpath dest "%dest%"
  set distr=%dest%\..\cygwin-distr
  if not exist %dest%\* mkdir %dest%
  set setup_exe=%dest%\setup-x86.exe
  if not exist %setup_exe% ( call:download http://www.cygwin.com/setup-x86.exe %setup_exe% )
  if defined HTTP_PROXY set proxy_arg=--proxy %HTTP_PROXY%
  %setup_exe% --quiet-mode ^
    --root %dest% ^
    --download %proxy_arg% --site http://mirrors.kernel.org/sourceware/cygwin ^
    --local-install --local-package-dir %distr% ^
    --packages wget,openssh ^
    --upgrade-also --delete-orphans ^
    --no-shortcuts --no-startmenu --no-desktop --wait
  if errorlevel 1 goto:eof
  if not exist %dest%/bin/apt-cyg call:install_apt_cyg
goto:eof

:install_apt_cyg
  echo ** Installing apt-cyg >&2
:: apt-cyg from rawgit.com/transcode-open/apt-cyg/master/apt-cyg:
  set base64=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
  %dest%\bin\bash -c "export PATH=/bin; echo %base64% | base64 -d | gunzip -f > /bin/apt-cyg && chmod +x /bin/apt-cyg"
goto:eof

:download
  echo ** Downloading %1 to %2 .. >&2
  cscript //E:JScript //nologo %~f0 %1 %2
  if not exist %2 ( echo ** [ERROR] Download %1 to %2 has failed! >&2 & exit /b 1 )
goto:eof

:shortpath
  set %1=%~fs2
goto:eof

********************************************************************************
*** JScript to execute by WSH: 
***/

args = WScript.Arguments
url  = args.Item(0)
dest = args.Item(1)

// Fetch the file
objXMLHTTP = WScript.CreateObject("Msxml2.XMLHTTP") // if problems, read http://msdn.microsoft.com/en-us/library/ee797612(v=cs.20).aspx 

objXMLHTTP.open("GET", url, false)
objXMLHTTP.send()

if (objXMLHTTP.Status == 200) {
    objADOStream = WScript.CreateObject("ADODB.Stream")
    objADOStream.Open()
    objADOStream.Type = 1

    objADOStream.Write(objXMLHTTP.ResponseBody)
    objADOStream.Position = 0

    objFSO = WScript.CreateObject("Scripting.FileSystemObject")
    if (objFSO.Fileexists(dest)) { objFSO.DeleteFile(dest) }

    objADOStream.SaveToFile(dest)
    objADOStream.Close()
}
