CREATE OR REPLACE FUNCTION RADEK_PAPIRU(
  p_hra_id      IN NUMBER,
  p_cislo_radku IN NUMBER
) RETURN VARCHAR2
IS
  v_sirka NUMBER;
  v_row   VARCHAR2(4000);
BEGIN
  SELECT sirka INTO v_sirka FROM HRA WHERE id = p_hra_id;
  SELECT LISTAGG(ch, '') WITHIN GROUP (ORDER BY sl) INTO v_row
  FROM (
    SELECT n.sl,
           NVL((
             SELECT CASE
                      WHEN t.hrac_id = h.hrac_x_id THEN 'X'
                      WHEN t.hrac_id = h.hrac_o_id THEN 'O'
                      ELSE ' '
                    END
             FROM TAH t JOIN HRA h ON h.id = t.hra_id
             WHERE t.hra_id = p_hra_id AND t.radek = p_cislo_radku AND t.sloupec = n.sl
           ), ' ') AS ch
    FROM (SELECT LEVEL AS sl FROM dual CONNECT BY LEVEL <= v_sirka) n
  );
  RETURN v_row;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION SPATNY_PARAMETR(
  p_sirka NUMBER, p_vyska NUMBER, p_rada NUMBER
) RETURN NUMBER IS
BEGIN
  IF p_vyska < 5 THEN RETURN 1; END IF; 
  IF p_vyska > 20 THEN RETURN 2; END IF; 
  IF p_sirka < 5 THEN RETURN 3; END IF; 
  IF p_sirka > 20 THEN RETURN 4; END IF; 
  IF p_rada < 5 THEN RETURN 5; END IF; 
  IF p_rada > 15 THEN RETURN 6; END IF; 
  IF p_rada > p_sirka THEN RETURN 7; END IF; 
  IF p_rada > p_vyska THEN RETURN 8; END IF; 
  RETURN 0; 
END;
/

CREATE OR REPLACE FUNCTION REMIZA(p_hra_id NUMBER) RETURN BOOLEAN IS
  v_pocet_tahu NUMBER;
  v_kapacita   NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_pocet_tahu FROM TAH WHERE hra_id = p_hra_id;
  SELECT (sirka * vyska) INTO v_kapacita FROM HRA WHERE id = p_hra_id;
  IF v_pocet_tahu >= v_kapacita THEN RETURN TRUE; END IF;
  RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION VYHRA(p_hra_id NUMBER) RETURN BOOLEAN IS
  v_delka NUMBER;
  v_pocet NUMBER;
BEGIN
  SELECT delka_rady INTO v_delka FROM HRA WHERE id = p_hra_id;
  FOR t IN (SELECT hrac_id, radek, sloupec FROM TAH WHERE hra_id = p_hra_id) LOOP
    SELECT COUNT(*) INTO v_pocet FROM TAH WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND radek = t.radek AND sloupec >= t.sloupec AND sloupec < t.sloupec + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;
    SELECT COUNT(*) INTO v_pocet FROM TAH WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND sloupec = t.sloupec AND radek >= t.radek AND radek < t.radek + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;
    SELECT COUNT(*) INTO v_pocet FROM TAH WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND (radek - t.radek) = (sloupec - t.sloupec) AND radek >= t.radek AND radek < t.radek + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;
    SELECT COUNT(*) INTO v_pocet FROM TAH WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND (radek - t.radek) = -(sloupec - t.sloupec) AND radek >= t.radek AND radek < t.radek + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;
  END LOOP;
  RETURN FALSE; 
END;
/

CREATE OR REPLACE FUNCTION HERNI_CAS(
  p_hra_id  IN NUMBER,
  p_hrac_id IN NUMBER
) RETURN NUMBER IS
  v_sekundy NUMBER := 0;
  v_prev_time TIMESTAMP;
BEGIN
  FOR r IN (SELECT hrac_id, played_at FROM TAH WHERE hra_id = p_hra_id ORDER BY played_at ASC, id ASC) LOOP
    IF v_prev_time IS NOT NULL AND r.hrac_id = p_hrac_id THEN
      v_sekundy := v_sekundy + EXTRACT(DAY FROM (r.played_at - v_prev_time)) * 86400
                             + EXTRACT(HOUR FROM (r.played_at - v_prev_time)) * 3600
                             + EXTRACT(MINUTE FROM (r.played_at - v_prev_time)) * 60
                             + EXTRACT(SECOND FROM (r.played_at - v_prev_time));
    END IF;
    v_prev_time := r.played_at;
  END LOOP;
  RETURN ROUND(v_sekundy);
END;
/