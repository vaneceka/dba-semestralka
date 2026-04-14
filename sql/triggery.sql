-- 1. Hlídání parametrů nové hry 
CREATE OR REPLACE TRIGGER trg_hra_kontrola_start
BEFORE INSERT ON HRA
FOR EACH ROW
BEGIN
  ZABRAN_HRE(:NEW.sirka, :NEW.vyska, :NEW.delka_rady, :NEW.hrac_x_id, :NEW.hrac_o_id);
END;
/

-- 2. Hlídání platnosti tahu 
CREATE OR REPLACE TRIGGER trg_tah_pred_vlozenim
BEFORE INSERT ON TAH
FOR EACH ROW
BEGIN
  ZABRAN_TAHU(:NEW.hra_id, :NEW.hrac_id, :NEW.radek, :NEW.sloupec);
END;
/

-- 3. Automatické vyhodnocení konce hry po tahu (vyřešený Mutating Table)
CREATE OR REPLACE TRIGGER trg_tah_po_vlozeni
FOR INSERT ON TAH
COMPOUND TRIGGER
  v_hra_id NUMBER;
  AFTER EACH ROW IS
  BEGIN
    v_hra_id := :NEW.hra_id;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
    v_stav_vyhra_id NUMBER;
    v_stav_remiza_id NUMBER;
  BEGIN
    IF v_hra_id IS NOT NULL THEN
      IF VYHRA(v_hra_id) THEN 
        SELECT id INTO v_stav_vyhra_id FROM STAV WHERE kod = 'VYHRA_ZAC';
        UPDATE HRA SET stav_id = v_stav_vyhra_id WHERE id = v_hra_id;
      ELSIF REMIZA(v_hra_id) THEN
        SELECT id INTO v_stav_remiza_id FROM STAV WHERE kod = 'REMIZA';
        UPDATE HRA SET stav_id = v_stav_remiza_id WHERE id = v_hra_id;
      END IF;
    END IF;
  END AFTER STATEMENT;
END trg_tah_po_vlozeni;
/

-- 4. Aktualizace statistik a času po skončení hry (vyřešený Mutating Table)
CREATE OR REPLACE TRIGGER trg_hra_po_skonceni
FOR UPDATE OF stav_id ON HRA
COMPOUND TRIGGER
  v_hra_id NUMBER;
  AFTER EACH ROW IS
  BEGIN
    IF :OLD.stav_id <> :NEW.stav_id THEN
      v_hra_id := :NEW.id;
    END IF;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF v_hra_id IS NOT NULL THEN
      KONEC_HRY(v_hra_id);
      STATISTIKY(v_hra_id);
    END IF;
  END AFTER STATEMENT;
END trg_hra_po_skonceni;
/