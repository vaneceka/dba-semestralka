SET SERVEROUTPUT ON;
DECLARE
  v_stav_roze NUMBER;
  v_alice     NUMBER;
  v_bob       NUMBER;

  PROCEDURE zkus_hru(p_sirka NUMBER, p_vyska NUMBER, p_delka NUMBER, p_hx NUMBER, p_ho NUMBER, p_popis VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Test: ' || p_popis);
    INSERT INTO HRA (sirka, vyska, delka_rady, hrac_x_id, hrac_o_id, zacina_symbol, stav_id)
    VALUES (p_sirka, p_vyska, p_delka, p_hx, p_ho, 'X', v_stav_roze);
    DBMS_OUTPUT.PUT_LINE('CHYBA: Hra se nespravne zalozila!');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Spravne zachyceno: ' || SQLERRM);
  END;
BEGIN
  SELECT id INTO v_stav_roze FROM STAV WHERE kod = 'ROZEHRANA';
  SELECT id INTO v_alice FROM HRAC WHERE jmeno = 'Alice';
  SELECT id INTO v_bob   FROM HRAC WHERE jmeno = 'Bob';

  zkus_hru(4, 10, 5, v_alice, v_bob, 'Prilis mala sirka (4)');
  zkus_hru(25, 10, 5, v_alice, v_bob, 'Prilis velka sirka (25)');
  zkus_hru(10, 10, 20, v_alice, v_bob, 'Prilis dlouha rada (20)');
  zkus_hru(10, 10, 5, v_alice, v_alice, 'Hrac hraje sam proti sobe');
  COMMIT;
END;
/