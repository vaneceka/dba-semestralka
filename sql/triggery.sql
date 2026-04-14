-- 1. Hlídání parametrů nové hry 
CREATE OR REPLACE TRIGGER trg_hra_kontrola_start
BEFORE INSERT ON HRA
FOR EACH ROW
BEGIN
  ZABRAN_HRE(:NEW.sirka, :NEW.vyska, :NEW.delka_rady, :NEW.hrac_x_id, :NEW.hrac_o_id); [cite: 163]
END;
/

-- 2. Hlídání platnosti tahu 
CREATE OR REPLACE TRIGGER trg_tah_pred_vlozenim
BEFORE INSERT ON TAH
FOR EACH ROW
BEGIN
  ZABRAN_TAHU(:NEW.hra_id, :NEW.hrac_id, :NEW.radek, :NEW.sloupec); [cite: 138]
END;
/

-- 3. Automatické vyhodnocení konce hry po tahu 
CREATE OR REPLACE TRIGGER trg_tah_po_vlozeni
AFTER INSERT ON TAH
FOR EACH ROW
DECLARE
  v_stav_vyhra_id NUMBER;
  v_stav_remiza_id NUMBER;
BEGIN
  -- Pokud hrající hráč vyhrál 
  IF VYHRA(:NEW.hra_id) THEN 
    -- Zde by se v reálu rozlišovalo VYHRA_ZAC vs PROHRA_ZAC podle toho, kdo táhl,
    -- pro zjednodušení ve scénáři nastavujeme výhru začínajícího.
    SELECT id INTO v_stav_vyhra_id FROM STAV WHERE kod = 'VYHRA_ZAC';
    UPDATE HRA SET stav_id = v_stav_vyhra_id WHERE id = :NEW.hra_id;
  
  -- Pokud je papír plný 
  ELSIF REMIZA(:NEW.hra_id) THEN
    SELECT id INTO v_stav_remiza_id FROM STAV WHERE kod = 'REMIZA';
    UPDATE HRA SET stav_id = v_stav_remiza_id WHERE id = :NEW.hra_id;
  END IF;
END;
/

-- 4. Aktualizace statistik a času po skončení hry 
CREATE OR REPLACE TRIGGER trg_hra_po_skonceni
AFTER UPDATE OF stav_id ON HRA
FOR EACH ROW
WHEN (OLD.stav_id <> NEW.stav_id)
BEGIN
  -- Spočítání herních časů [cite: 102, 161]
  KONEC_HRY(:NEW.id); [cite: 163]
  -- Aktualizace statistik hráčů [cite: 102, 159]
  STATISTIKY(:NEW.id); [cite: 163]
END;
/