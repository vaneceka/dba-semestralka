-- aplikace.sql
-- Vytvori objekty, naplni konfiguraci, spusti vsechny scenare (se spool), nakonec znici vse.

@destrukce.sql

@model.sql
@konfigurace.sql
@funkce.sql
@procedury.sql
@pohledy.sql
@triggery.sql

-- POVINNÉ SCÉNÁŘE
SPOOL scenar-vyhra.log
@scenar-vyhra.sql
SPOOL OFF

SPOOL scenar-chybne-tahy.log
@scenar-chybne-tahy.sql
SPOOL OFF

-- VOLITELNÉ SCÉNÁŘE (pro bonusové body)
SPOOL scenar-prohra.log
@scenar-prohra.sql
SPOOL OFF

SPOOL scenar-remiza.log
@scenar-remiza.sql
SPOOL OFF

SPOOL scenar-chybne-hry.log
@scenar-chybne-hry.sql
SPOOL OFF

@destrukce.sql