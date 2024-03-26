Create a directory pointing to asm diskgroup( for dumpfiles)

SQL> create directory SOURCE_DUMP as '+NEWTST/TESTDB2/TEMPFILE';
Directory created

Create a directory pointing to a normal filesystem ( required for logfiles)

SQL> create directory EXPLOG as '/export/home/oracle';
Directory created.
export parfile

dumpfile=test.dmp
logfile=EXPLOG:test.log
directory=SOURCE_DUMP
tables=dbatest.EMPTAB
exclude=statistics