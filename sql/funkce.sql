-- funkce.sql
-- Povinna funkce: RADEK_PAPIRU(hra_id, cislo_radku)

CREATE OR REPLACE FUNCTION RADEK_PAPIRU(
  p_hra_id      IN NUMBER,
  p_cislo_radku IN NUMBER
) RETURN VARCHAR2
IS
  v_sirka NUMBER;
  v_row   VARCHAR2(4000);
BEGIN
  SELECT sirka INTO v_sirka
  FROM HRA
  WHERE id = p_hra_id;

  /*
    Poskladame znaky pro sloupce 1..sirka.
    Znak urcime podle toho, zda je v TAH tah hrace X nebo O.
  */
  SELECT LISTAGG(ch, '') WITHIN GROUP (ORDER BY sl)
    INTO v_row
  FROM (
    SELECT n.sl,
           NVL((
             SELECT CASE
                      WHEN t.hrac_id = h.hrac_x_id THEN 'X'
                      WHEN t.hrac_id = h.hrac_o_id THEN 'O'
                      ELSE ' '
                    END
             FROM TAH t
             JOIN HRA h ON h.id = t.hra_id
             WHERE t.hra_id = p_hra_id
               AND t.radek = p_cislo_radku
               AND t.sloupec = n.sl
           ), ' ') AS ch
    FROM (SELECT LEVEL AS sl FROM dual CONNECT BY LEVEL <= v_sirka) n
  );

  RETURN v_row;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION SPATNY_PARAMETR(
  p_sirka NUMBER, p_vyska NUMBER, p_rada NUMBER
) RETURN NUMBER IS
BEGIN
  IF p_vyska < 5 THEN RETURN 1; END IF; [cite: 68]
  IF p_vyska > 20 THEN RETURN 2; END IF; [cite: 68]
  IF p_sirka < 5 THEN RETURN 3; END IF; [cite: 69]
  IF p_sirka > 20 THEN RETURN 4; END IF; [cite: 70]
  IF p_rada < 5 THEN RETURN 5; END IF; [cite: 71]
  IF p_rada > 15 THEN RETURN 6; END IF; [cite: 72]
  IF p_rada > p_sirka THEN RETURN 7; END IF; [cite: 73]
  IF p_rada > p_vyska THEN RETURN 8; END IF; [cite: 74]
  RETURN 0; [cite: 65]
END;
/

-- Zjednodušená verze funkce VYHRA (pro účely semestrální práce) [cite: 83]
CREATE OR REPLACE FUNCTION VYHRA(p_hra_id NUMBER) RETURN BOOLEAN IS
  -- Zde by měl být algoritmus procházející 8 směrů od posledního tahu [cite: 9]
BEGIN
  -- Pro implementaci stačí ověřit, zda existuje řada stejných symbolů dané délky [cite: 85]
  -- V rámci školního projektu se často akceptuje i ruční ukončení ve scénáři, 
  -- ale tato funkce by měla vracet TRUE při splnění podmínek[cite: 84].
  RETURN FALSE; 
END;
/

-- HERNI_CAS: Sečte rozdíly časových značek tahů [cite: 79, 80]
CREATE OR REPLACE FUNCTION HERNI_CAS(
  p_hra_id  IN NUMBER,
  p_hrac_id IN NUMBER
) RETURN NUMBER IS
  v_sekundy NUMBER := 0;
BEGIN
  -- Zde implementuj logiku výpočtu času mezi tahy [cite: 14, 15, 17]
  -- Pro zjednodušení se často bere rozdíl mezi prvním a posledním tahem hráče
  RETURN v_sekundy;
END;
/

-- REMIZA: Kontrola, zda je papír plný [cite: 82]
CREATE OR REPLACE FUNCTION REMIZA(p_hra_id NUMBER) RETURN BOOLEAN IS
  v_pocet_tahu NUMBER;
  v_kapacita   NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_pocet_tahu FROM TAH WHERE hra_id = p_hra_id;
  SELECT (sirka * vyska) INTO v_kapacita FROM HRA WHERE id = p_hra_id;
  
  IF v_pocet_tahu >= v_kapacita THEN
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION VYHRA(p_hra_id NUMBER) RETURN BOOLEAN IS
  v_delka NUMBER;
  v_pocet NUMBER;
BEGIN
  -- Načtení požadované délky vítězné řady pro danou hru
  SELECT delka_rady INTO v_delka FROM HRA WHERE id = p_hra_id;

  -- Projdeme všechny dosud položené značky
  FOR t IN (SELECT hrac_id, radek, sloupec FROM TAH WHERE hra_id = p_hra_id) LOOP
    
    -- 1. Kontrola horizontálně (doprava)
    SELECT COUNT(*) INTO v_pocet FROM TAH
    WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND radek = t.radek AND sloupec >= t.sloupec AND sloupec < t.sloupec + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;

    -- 2. Kontrola vertikálně (dolů)
    SELECT COUNT(*) INTO v_pocet FROM TAH
    WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND sloupec = t.sloupec AND radek >= t.radek AND radek < t.radek + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;

    -- 3. Kontrola diagonálně (doprava dolů)
    SELECT COUNT(*) INTO v_pocet FROM TAH
    WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND (radek - t.radek) = (sloupec - t.sloupec)
      AND radek >= t.radek AND radek < t.radek + v_delka;
    IF v_pocet = v_delka THEN RETURN TRUE; END IF;

    -- 4. Kontrola diagonálně (doleva dolů)
    SELECT COUNT(*) INTO v_pocet FROM TAH
    WHERE hra_id = p_hra_id AND hrac_id = t.hrac_id
      AND (radek - t.radek) = -(sloupec - t.sloupec)
      AND radek >= t.radek AND radek < t.radek + v_delka;
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
  -- Projdeme všechny tahy seřazené podle času
  FOR r IN (
    SELECT hrac_id, played_at
    FROM TAH
    WHERE hra_id = p_hra_id
    ORDER BY played_at ASC, id ASC
  ) LOOP
    -- Pokud už máme předchozí tah a aktuální tah hraje sledovaný hráč, přičteme rozdíl
    IF v_prev_time IS NOT NULL AND r.hrac_id = p_hrac_id THEN
      v_sekundy := v_sekundy + EXTRACT(DAY FROM (r.played_at - v_prev_time)) * 86400
                             + EXTRACT(HOUR FROM (r.played_at - v_prev_time)) * 3600
                             + EXTRACT(MINUTE FROM (r.played_at - v_prev_time)) * 60
                             + EXTRACT(SECOND FROM (r.played_at - v_prev_time));
    END IF;
    -- Uložíme čas tohoto tahu jako startovací pro dalšího hráče
    v_prev_time := r.played_at;
  END LOOP;

  RETURN ROUND(v_sekundy);
END;
/