CREATE OR REPLACE PROCEDURE ZABRAN_TAHU(
  p_hra_id   IN NUMBER, p_hrac_id  IN NUMBER, p_radek    IN NUMBER, p_sloupec  IN NUMBER
) IS
  v_sirka NUMBER; v_vyska NUMBER; v_zacina_symbol CHAR(1); v_hrac_x_id NUMBER; v_hrac_o_id NUMBER;
  v_stav_kod VARCHAR2(30); v_pocet_tahu NUMBER; v_ocek_symbol CHAR(1); v_ocek_hrac_id NUMBER; v_obsazeno NUMBER;
BEGIN
  SELECT h.sirka, h.vyska, h.zacina_symbol, h.hrac_x_id, h.hrac_o_id, s.kod
  INTO v_sirka, v_vyska, v_zacina_symbol, v_hrac_x_id, v_hrac_o_id, v_stav_kod
  FROM HRA h JOIN STAV s ON s.id = h.stav_id WHERE h.id = p_hra_id;

  IF v_stav_kod <> 'ROZEHRANA' THEN RAISE_APPLICATION_ERROR(-20001, 'Hra uz skoncila.'); END IF;
  IF p_hrac_id NOT IN (v_hrac_x_id, v_hrac_o_id) THEN RAISE_APPLICATION_ERROR(-20002, 'Hrac v teto hre nehraje.'); END IF;
  IF p_radek < 1 OR p_radek > v_vyska OR p_sloupec < 1 OR p_sloupec > v_sirka THEN RAISE_APPLICATION_ERROR(-20003, 'Tah mimo papir.'); END IF;
  
  SELECT COUNT(*) INTO v_obsazeno FROM TAH WHERE hra_id = p_hra_id AND radek = p_radek AND sloupec = p_sloupec;
  IF v_obsazeno > 0 THEN RAISE_APPLICATION_ERROR(-20004, 'Pole je jiz obsazene.'); END IF;

  SELECT COUNT(*) INTO v_pocet_tahu FROM TAH WHERE hra_id = p_hra_id;
  IF MOD(v_pocet_tahu, 2) = 0 THEN v_ocek_symbol := v_zacina_symbol;
  ELSE v_ocek_symbol := CASE WHEN v_zacina_symbol = 'X' THEN 'O' ELSE 'X' END; END IF;
  v_ocek_hrac_id := CASE WHEN v_ocek_symbol = 'X' THEN v_hrac_x_id ELSE v_hrac_o_id END;

  IF p_hrac_id <> v_ocek_hrac_id THEN RAISE_APPLICATION_ERROR(-20005, 'Neni na rade tento hrac.'); END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20000, 'Neexistujici hra.');
END;
/

CREATE OR REPLACE PROCEDURE ZABRAN_HRE(p_sirka NUMBER, p_vyska NUMBER, p_rada NUMBER, p_h1 NUMBER, p_h2 NUMBER) IS
  v_err NUMBER;
BEGIN
  v_err := SPATNY_PARAMETR(p_sirka, p_vyska, p_rada); 
  IF v_err <> 0 THEN RAISE_APPLICATION_ERROR(-20100, 'Chybny parametr: ' || v_err); END IF;
  IF p_h1 = p_h2 THEN RAISE_APPLICATION_ERROR(-20101, 'Hrac nemuze hrat proti sobe.'); END IF;
END;
/

CREATE OR REPLACE PROCEDURE KONEC_HRY(p_hra_id IN NUMBER) IS
  v_hrac_x_id NUMBER; v_hrac_o_id NUMBER; v_cas_x NUMBER; v_cas_o NUMBER;
BEGIN
  SELECT hrac_x_id, hrac_o_id INTO v_hrac_x_id, v_hrac_o_id FROM HRA WHERE id = p_hra_id;
  v_cas_x := HERNI_CAS(p_hra_id, v_hrac_x_id); 
  v_cas_o := HERNI_CAS(p_hra_id, v_hrac_o_id); 
  UPDATE HRA SET cas_x_s = v_cas_x, cas_o_s = v_cas_o, finished_at = SYSDATE WHERE id = p_hra_id;
END;
/

CREATE OR REPLACE PROCEDURE STATISTIKY(p_hra_id IN NUMBER) IS
  v_stav_kod VARCHAR2(30); v_hrac_x_id NUMBER; v_hrac_o_id NUMBER; v_zacina_symb CHAR(1);
BEGIN
  SELECT s.kod, h.hrac_x_id, h.hrac_o_id, h.zacina_symbol
  INTO v_stav_kod, v_hrac_x_id, v_hrac_o_id, v_zacina_symb
  FROM HRA h JOIN STAV s ON h.stav_id = s.id WHERE h.id = p_hra_id;

  IF v_stav_kod = 'VYHRA_ZAC' THEN
    IF v_zacina_symb = 'X' THEN
      UPDATE HRAC SET vyhry_zac = vyhry_zac + 1 WHERE id = v_hrac_x_id;
      UPDATE HRAC SET prohry_druhy = prohry_druhy + 1 WHERE id = v_hrac_o_id;
    ELSE
      UPDATE HRAC SET vyhry_zac = vyhry_zac + 1 WHERE id = v_hrac_o_id;
      UPDATE HRAC SET prohry_druhy = prohry_druhy + 1 WHERE id = v_hrac_x_id;
    END IF;
  ELSIF v_stav_kod = 'PROHRA_ZAC' THEN
    IF v_zacina_symb = 'X' THEN
      UPDATE HRAC SET prohry_zac = prohry_zac + 1 WHERE id = v_hrac_x_id;
      UPDATE HRAC SET vyhry_druhy = vyhry_druhy + 1 WHERE id = v_hrac_o_id;
    ELSE
      UPDATE HRAC SET prohry_zac = prohry_zac + 1 WHERE id = v_hrac_o_id;
      UPDATE HRAC SET vyhry_druhy = vyhry_druhy + 1 WHERE id = v_hrac_x_id;
    END IF;
  ELSIF v_stav_kod = 'REMIZA' THEN
    UPDATE HRAC SET remizy_zac = remizy_zac + 1 WHERE id = CASE WHEN v_zacina_symb = 'X' THEN v_hrac_x_id ELSE v_hrac_o_id END;
    UPDATE HRAC SET remizy_druhy = remizy_druhy + 1 WHERE id = CASE WHEN v_zacina_symb = 'X' THEN v_hrac_o_id ELSE v_hrac_x_id END;
  END IF;
END;
/