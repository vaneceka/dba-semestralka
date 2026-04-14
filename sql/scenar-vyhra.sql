-- scenar-vyhra.sql
-- Scenar hry bez neplatneho tahu, vyhraje zacinajici hrac.
-- Po kazdem tahu vypis PAPIR, na konci vypis VYHRY_ZACINAJICI + HRA + HRAC.

SET SERVEROUTPUT ON;

DECLARE
  v_hra_id     NUMBER;
  v_stav_roze  NUMBER;
  v_stav_vyhra NUMBER;
  v_alice      NUMBER;
  v_bob        NUMBER;

  PROCEDURE vypis_papir IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PAPIR (hra_id='||v_hra_id||') ---');
    FOR r IN (
      SELECT cislo_radku, radek_text
      FROM PAPIR
      WHERE hra_id = v_hra_id
      ORDER BY cislo_radku
    ) LOOP
      DBMS_OUTPUT.PUT_LINE(LPAD(r.cislo_radku,2,' ')||': '||r.radek_text);
    END LOOP;
  END;
BEGIN
  SELECT id INTO v_stav_roze  FROM STAV WHERE kod = 'ROZEHRANA';
  SELECT id INTO v_stav_vyhra FROM STAV WHERE kod = 'VYHRA_ZAC';
  SELECT id INTO v_alice FROM HRAC WHERE jmeno = 'Alice';
  SELECT id INTO v_bob   FROM HRAC WHERE jmeno = 'Bob';

  -- Alice = X, Bob = O, zacina X (Alice)
  INSERT INTO HRA (sirka, vyska, delka_rady, hrac_x_id, hrac_o_id, zacina_symbol, stav_id)
  VALUES (10, 10, 5, v_alice, v_bob, 'X', v_stav_roze)
  RETURNING id INTO v_hra_id;

  -- Vyherni rada pro X na radku 1, sloupce 1..5
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 1); vypis_papir;
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 1); vypis_papir;

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 2); vypis_papir;
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 2); vypis_papir;

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 3); vypis_papir;
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 3); vypis_papir;

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 4); vypis_papir;
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 4); vypis_papir;

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 5); vypis_papir;

  
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('--- VYHRY_ZACINAJICI ---');
  FOR x IN (SELECT * FROM VYHRY_ZACINAJICI WHERE hra_id = v_hra_id) LOOP
    DBMS_OUTPUT.PUT_LINE('hra_id='||x.hra_id||', zacinajici='||x.zacinajici||', pocet_tahu='||x.pocet_tahu);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('--- HRA ---');
  FOR h IN (SELECT id, sirka, vyska, delka_rady, zacina_symbol, stav_id, cas_x_s, cas_o_s FROM HRA WHERE id = v_hra_id) LOOP
    DBMS_OUTPUT.PUT_LINE('id='||h.id||', '||h.sirka||'x'||h.vyska||', delka='||h.delka_rady||', zacina='||h.zacina_symbol||
                         ', stav_id='||h.stav_id||', casX='||h.cas_x_s||', casO='||h.cas_o_s);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('--- HRAC ---');
  FOR p IN (SELECT id, jmeno, vyhry_zac, prohry_zac, remizy_zac, vyhry_druhy, prohry_druhy, remizy_druhy FROM HRAC ORDER BY id) LOOP
    DBMS_OUTPUT.PUT_LINE('id='||p.id||', '||p.jmeno);
  END LOOP;
END;
/