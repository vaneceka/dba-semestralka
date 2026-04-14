-- pohledy.sql
-- Povinne pohledy: PAPIR, VYHRY_ZACINAJICI (s CTE)

CREATE OR REPLACE VIEW PAPIR AS
SELECT
  h.id AS hra_id,
  r.rn AS cislo_radku,
  RADEK_PAPIRU(h.id, r.rn) AS radek_text
FROM HRA h
CROSS JOIN (SELECT LEVEL rn FROM dual CONNECT BY LEVEL <= 20) r
WHERE r.rn <= h.vyska;

-- VYHRY_ZACINAJICI:
-- (stejne zakladni sloupce jako REMIZY) + pocet tahu
-- Pouziti CTE je povinne.
CREATE OR REPLACE VIEW VYHRY_ZACINAJICI AS
WITH zaklad AS (
  SELECT
    hra.id AS hra_id,
    hra.sirka,
    hra.vyska,
    hra.delka_rady,

    hx.jmeno AS hrac_x,
    ho.jmeno AS hrac_o,

    CASE WHEN hra.zacina_symbol = 'X' THEN hx.jmeno ELSE ho.jmeno END AS zacinajici,
    hra.zacina_symbol,

    CASE WHEN hra.zacina_symbol = 'X' THEN 'O' ELSE 'X' END AS druhy_symbol,
    CASE WHEN hra.zacina_symbol = 'X' THEN ho.jmeno ELSE hx.jmeno END AS druhy_hrac,

    NVL(hra.cas_x_s, 0) AS cas_x_s,
    NVL(hra.cas_o_s, 0) AS cas_o_s,
    NVL(hra.cas_x_s, 0) + NVL(hra.cas_o_s, 0) AS doba_celkem_s,

    st.kod AS stav_kod
  FROM HRA hra
  JOIN HRAC hx ON hx.id = hra.hrac_x_id
  JOIN HRAC ho ON ho.id = hra.hrac_o_id
  JOIN STAV st ON st.id = hra.stav_id
),
tahy AS (
  SELECT hra_id, COUNT(*) AS pocet_tahu
  FROM TAH
  GROUP BY hra_id
)
SELECT
  z.hra_id,
  z.sirka, z.vyska, z.delka_rady,
  z.hrac_x, z.hrac_o,
  z.zacinajici, z.zacina_symbol,
  z.druhy_hrac, z.druhy_symbol,
  z.doba_celkem_s,
  t.pocet_tahu
FROM zaklad z
JOIN tahy t ON t.hra_id = z.hra_id
WHERE z.stav_kod = 'VYHRA_ZAC';

-- Přidej do pohledy.sql k již existujícím:

CREATE OR REPLACE VIEW REMIZY AS
SELECT 
    h.id AS hra_id, h.sirka, h.vyska, h.delka_rady,
    hx.jmeno AS hrac_x, ho.jmeno AS hrac_o,
    CASE WHEN h.zacina_symbol = 'X' THEN hx.jmeno ELSE ho.jmeno END AS zacinajici,
    h.zacina_symbol,
    NVL(h.cas_x_s, 0) + NVL(h.cas_o_s, 0) AS doba_celkem_s
FROM HRA h
JOIN HRAC hx ON h.hrac_x_id = hx.id
JOIN HRAC ho ON h.hrac_o_id = ho.id
JOIN STAV s ON h.stav_id = s.id
WHERE s.kod = 'REMIZA';

CREATE OR REPLACE VIEW PROHRY_ZACINAJICI AS
SELECT 
    h.id AS hra_id, h.sirka, h.vyska, h.delka_rady,
    hx.jmeno AS hrac_x, ho.jmeno AS hrac_o,
    CASE WHEN h.zacina_symbol = 'X' THEN hx.jmeno ELSE ho.jmeno END AS zacinajici,
    h.zacina_symbol,
    NVL(h.cas_x_s, 0) + NVL(h.cas_o_s, 0) AS doba_celkem_s,
    (SELECT COUNT(*) FROM TAH t WHERE t.hra_id = h.id) AS pocet_tahu
FROM HRA h
JOIN HRAC hx ON h.hrac_x_id = hx.id
JOIN HRAC ho ON h.hrac_o_id = ho.id
JOIN STAV s ON h.stav_id = s.id
WHERE s.kod = 'PROHRA_ZAC';
