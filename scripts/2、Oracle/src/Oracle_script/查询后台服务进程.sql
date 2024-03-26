col ksbddidn for a15
col ksmfsnam for a20
col ksbdddsc for a60
set lines 150 pages 5000
SELECT ksbdd.ksbddidn, ksmfsv.ksmfsnam, ksbdd.ksbdddsc
FROM x$ksbdd ksbdd, x$ksbdp ksbdp, x$ksmfsv ksmfsv
WHERE ksbdd.indx = ksbdp.indx
AND ksbdp.addr = ksmfsv.ksmfsadr
ORDER BY ksbdd.ksbddidn;