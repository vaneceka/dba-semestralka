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
  v_hrac_id NUMBER; -- Přidáno pro zjištění, kdo právě táhl

  AFTER EACH ROW IS
  BEGIN
    v_hra_id := :NEW.hra_id;
    v_hrac_id := :NEW.hrac_id;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
    v_hx NUMBER;
    v_ho NUMBER;
    v_zac CHAR(1);
  BEGIN
    IF v_hra_id IS NOT NULL THEN
      IF VYHRA(v_hra_id) THEN 
        -- Zjistíme, kdo hrál s jakým symbolem
        SELECT hrac_x_id, hrac_o_id, zacina_symbol INTO v_hx, v_ho, v_zac FROM HRA WHERE id = v_hra_id;
        
        -- Pokud vyhrál ten, kdo začínal
        IF (v_hrac_id = v_hx AND v_zac = 'X') OR (v_hrac_id = v_ho AND v_zac = 'O') THEN
          UPDATE HRA SET stav_id = (SELECT id FROM STAV WHERE kod = 'VYHRA_ZAC') WHERE id = v_hra_id;
        -- Pokud vyhrál ten druhý
        ELSE
          UPDATE HRA SET stav_id = (SELECT id FROM STAV WHERE kod = 'PROHRA_ZAC') WHERE id = v_hra_id;
        END IF;

      ELSIF REMIZA(v_hra_id) THEN
        UPDATE HRA SET stav_id = (SELECT id FROM STAV WHERE kod = 'REMIZA') WHERE id = v_hra_id;
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