
-- konfigurace.sql
-- Naplneni konfiguracnich tabulek: OMEZENI, STAV, HRAC
-- Spoustet az po model.sql

SET DEFINE OFF;

------------------------------------------------------------
-- OMEZENI (min/max hodnoty)
------------------------------------------------------------
MERGE INTO OMEZENI o
USING (SELECT 'SIRKA' AS kod, 5 AS min_hod, 20 AS max_hod FROM dual) src
ON (o.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET o.min_hod = src.min_hod, o.max_hod = src.max_hod
WHEN NOT MATCHED THEN
  INSERT (kod, min_hod, max_hod) VALUES (src.kod, src.min_hod, src.max_hod);

MERGE INTO OMEZENI o
USING (SELECT 'VYSKA' AS kod, 5 AS min_hod, 20 AS max_hod FROM dual) src
ON (o.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET o.min_hod = src.min_hod, o.max_hod = src.max_hod
WHEN NOT MATCHED THEN
  INSERT (kod, min_hod, max_hod) VALUES (src.kod, src.min_hod, src.max_hod);

MERGE INTO OMEZENI o
USING (SELECT 'DELKA_RADY' AS kod, 5 AS min_hod, 15 AS max_hod FROM dual) src
ON (o.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET o.min_hod = src.min_hod, o.max_hod = src.max_hod
WHEN NOT MATCHED THEN
  INSERT (kod, min_hod, max_hod) VALUES (src.kod, src.min_hod, src.max_hod);

------------------------------------------------------------
-- STAV (stavy hry)
------------------------------------------------------------
MERGE INTO STAV s
USING (SELECT 'ROZEHRANA' AS kod, 'Hra probíhá' AS popis FROM dual) src
ON (s.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET s.popis = src.popis
WHEN NOT MATCHED THEN
  INSERT (kod, popis) VALUES (src.kod, src.popis);

MERGE INTO STAV s
USING (SELECT 'VYHRA_ZAC' AS kod, 'Výhra začínajícího hráče' AS popis FROM dual) src
ON (s.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET s.popis = src.popis
WHEN NOT MATCHED THEN
  INSERT (kod, popis) VALUES (src.kod, src.popis);

MERGE INTO STAV s
USING (SELECT 'PROHRA_ZAC' AS kod, 'Prohra začínajícího hráče' AS popis FROM dual) src
ON (s.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET s.popis = src.popis
WHEN NOT MATCHED THEN
  INSERT (kod, popis) VALUES (src.kod, src.popis);

MERGE INTO STAV s
USING (SELECT 'REMIZA' AS kod, 'Remíza' AS popis FROM dual) src
ON (s.kod = src.kod)
WHEN MATCHED THEN
  UPDATE SET s.popis = src.popis
WHEN NOT MATCHED THEN
  INSERT (kod, popis) VALUES (src.kod, src.popis);

------------------------------------------------------------
-- HRAC (aspon 3 hraci pro scenare)
------------------------------------------------------------
MERGE INTO HRAC h
USING (SELECT 'Alice' AS jmeno FROM dual) src
ON (h.jmeno = src.jmeno)
WHEN NOT MATCHED THEN
  INSERT (jmeno) VALUES (src.jmeno);

MERGE INTO HRAC h
USING (SELECT 'Bob' AS jmeno FROM dual) src
ON (h.jmeno = src.jmeno)
WHEN NOT MATCHED THEN
  INSERT (jmeno) VALUES (src.jmeno);

MERGE INTO HRAC h
USING (SELECT 'Cyril' AS jmeno FROM dual) src
ON (h.jmeno = src.jmeno)
WHEN NOT MATCHED THEN
  INSERT (jmeno) VALUES (src.jmeno);

COMMIT;

-- (Volitelne) rychla kontrola:
-- SELECT * FROM OMEZENI ORDER BY kod;
-- SELECT * FROM STAV ORDER BY kod;
-- SELECT * FROM HRAC ORDER BY id;