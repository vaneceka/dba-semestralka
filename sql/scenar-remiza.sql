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

  -- Založení malé hry 5x5
  INSERT INTO HRA (sirka, vyska, delka_rady, hrac_x_id, hrac_o_id, zacina_symbol, stav_id)
  VALUES (5, 5, 5, v_alice, v_bob, 'X', v_stav_roze) RETURNING id INTO v_hra_id;

 -- 25 tahů, přísné střídání (Alice, Bob, Alice, Bob...)
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   1, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   1, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 1, 5);
  
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 2, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 2, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   2, 5);
  
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 3, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   3, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 3, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   3, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 3, 5);

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   4, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 4, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   4, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 4, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   4, 5);

  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 5, 1);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   5, 2);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 5, 3);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_bob,   5, 4);
  INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, v_alice, 5, 5);
  vypis_papir;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('--- REMIZY ---');
  FOR x IN (SELECT * FROM REMIZY WHERE hra_id = v_hra_id) LOOP
    DBMS_OUTPUT.PUT_LINE('hra_id='||x.hra_id||', zacinajici='||x.zacinajici||', doba='||x.doba_celkem_s);
  END LOOP;
END;
/