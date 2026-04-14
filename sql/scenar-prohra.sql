SET SERVEROUTPUT ON;

DECLARE
  v_hra_id     NUMBER;
  v_stav_roze  NUMBER;
  v_alice      NUMBER;
  v_bob        NUMBER;

  PROCEDURE vypis_papir IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PAPIR ---');
    FOR r IN (SELECT cislo_radku, radek_text FROM PAPIR WHERE hra_id = v_hra_id ORDER BY cislo_radku) LOOP
      DBMS_OUTPUT.PUT_LINE(LPAD(r.cislo_radku,2,' ')||': '||r.radek_text);
    END LOOP;
  END;
BEGIN
  SELECT id INTO v_stav_roze  FROM STAV WHERE kod = 'ROZEHRANA';
  SELECT id INTO v_alice FROM HRAC WHERE jmeno = 'Alice';
  SELECT id INTO v_bob   FROM HRAC WHERE jmeno = 'Bob';

  -- Alice = X, Bob = O, zacina X (Alice)
  INSERT INTO HRA (sirka, vyska, delka_rady, hrac_x_id, hrac_o_id, zacina_symbol, stav_id)
  VALUES (10, 10, 5, v_alice, v_bob, 'X', v_stav_roze) RETURNING id INTO v_hra_id;

  -- Hra, kde Bob (O) vyhraje na druhem radku
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 3, 1); -- Alice udela chybu
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 5); -- Bob vyhral
  
  vypis_papir;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('--- PROHRY_ZACINAJICI ---');
  FOR x IN (SELECT * FROM PROHRY_ZACINAJICI WHERE hra_id = v_hra_id) LOOP
    DBMS_OUTPUT.PUT_LINE('hra_id='||x.hra_id||', zacinajici='||x.zacinajici||', pocet_tahu='||x.pocet_tahu);
  END LOOP;
END;
/