@ECHO OFF
Cscript F:\backup\MyDate.vbs
CALL F:\backup\MyDate.CMD
DEL F:\backup\MyDate.CMD
ECHO ON
REM @ECHO %MyDate%
del F:\backup\scdb01_%MyDate%.*
del F:\backup\scdb01_%Date:~0,10%.*
exp system/oracle file=F:\backup\scdb01_%DATE:~0,10%.dmp buffer=4096000 full=y log=F:\backup\scdb01_%DATE:~0,10%.log
