BEGIN
FOR r IN (select sid,serial# from v$session where username = 'TEST_ANB')
LOOP
EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid
|| ',' || r.serial# || '''';
END LOOP;
END;
/