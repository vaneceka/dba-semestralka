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

  PROCEDURE zkus_tah(p_hrac NUMBER, p_r NUMBER, p_s NUMBER, p_popis VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Zkousim: ' || p_popis);
    INSERT INTO TAH(hra_id, hrac_id, radek, sloupec) VALUES (v_hra_id, p_hrac, p_r, p_s);
    DBMS_OUTPUT.PUT_LINE('Vysledek: Tah uspesne proveden.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('CHYBA ZACHYCENA -> ' || SQLERRM);
  END;

BEGIN
  SELECT id INTO v_stav_roze  FROM STAV WHERE kod = 'ROZEHRANA';
  SELECT id INTO v_alice FROM HRAC WHERE jmeno = 'Alice';
  SELECT id INTO v_bob   FROM HRAC WHERE jmeno = 'Bob';

  INSERT INTO HRA (sirka, vyska, delka_rady, hrac_x_id, hrac_o_id, zacina_symbol, stav_id)
  VALUES (10, 10, 5, v_alice, v_bob, 'X', v_stav_roze) RETURNING id INTO v_hra_id;

  zkus_tah(v_alice, 15, 15, 'Tah mimo papir (Alice na 15,15)');
  zkus_tah(v_alice, 1, 1, 'Spravny tah zacinajiciho hrace (Alice 1,1)');
  zkus_tah(v_alice, 1, 2, 'Hrac neni na rade (Alice se pokousi hrat znovu)');
  zkus_tah(v_bob, 1, 1, 'Tah na obsazene pole (Bob na 1,1)');

  zkus_tah(v_bob,   2, 1, 'Spravny tah (Bob 2,1)');
  zkus_tah(v_alice, 1, 2, 'Spravny tah (Alice 1,2)');
  zkus_tah(v_bob,   2, 2, 'Spravny tah (Bob 2,2)');
  zkus_tah(v_alice, 1, 3, 'Spravny tah (Alice 1,3)');
  zkus_tah(v_bob,   2, 3, 'Spravny tah (Bob 2,3)');
  zkus_tah(v_alice, 1, 4, 'Spravny tah (Alice 1,4)');
  zkus_tah(v_bob,   2, 4, 'Spravny tah (Bob 2,4)');
  
  zkus_tah(v_alice, 1, 5, 'Vitezny tah (Alice 1,5)');
  zkus_tah(v_bob,   2, 5, 'Tah v ukoncene hre (Bob 2,5)');
  COMMIT;
END;
/