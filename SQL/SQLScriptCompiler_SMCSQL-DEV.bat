ECHO =========================================================== > CompileResults.txt 2>&1
ECHO 	SQL Compile >> CompileResults.txt 2>&1
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
   )
set datestr=%month%_%day%_%year%
echo Date Executed %datestr% >> CompileResults.txt 2>&1
ECHO =========================================================== >> CompileResults.txt 2>&1

cd StoredProcedures
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
ECHO StoredProcedures >> ..\CompileResults.txt 2>&1
for %%G in (*.sql) do sqlcmd /S SMCSQL-DEV /d SMC_DB_Performance -E -i "%%G" >> ..\CompileResults.txt 2>&1
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
pause
cd..

cd Functions
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
ECHO Functions >> ..\CompileResults.txt 2>&1
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
for %%G in (*.sql) do sqlcmd /S SMCSQL-DEV /d SMC_DB_Performance -E -i "%%G" >> ..\CompileResults.txt 2>&1
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
pause
cd..

cd Views
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
ECHO Views >> ..\CompileResults.txt 2>&1
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
for %%G in (*.sql) do sqlcmd /S SMCSQL-DEV /d SMC_DB_Performance -E -i "%%G" >> ..\CompileResults.txt 2>&1
ECHO =========================================================== >> ..\CompileResults.txt 2>&1
pause
cd..


