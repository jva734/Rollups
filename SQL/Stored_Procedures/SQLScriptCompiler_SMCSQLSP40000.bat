ECHO =========================================================== >> CompileResults.txt 2>&1
ECHO StoredProcedures >> CompileResults.txt 2>&1
for %%G in (*.sql) do sqlcmd /S SMCSQLSP,40000 /d SMC_DB_Performance -E -i "%%G" >> CompileResults.txt 2>&1
ECHO =========================================================== >> CompileResults.txt 2>&1
pause
