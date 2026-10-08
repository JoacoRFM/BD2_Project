CREATE EXTENSION IF NOT EXISTS skiplist;
CREATE TABLE IF NOT EXISTS demo_skiplist (id integer PRIMARY KEY, nombre text);
TRUNCATE demo_skiplist;
INSERT INTO demo_skiplist(id, nombre) VALUES (5,'A'),(10,'B'),(20,'C'),(30,'D');
SELECT sl_build('demo_skiplist'::regclass, 'id') AS nodos;
SELECT sl_count() AS nodos_en_memoria;
SELECT sl_search(20) AS ctid_encontrado;
SELECT sl_search(999) IS NULL AS ausente;
SELECT * FROM sl_range(8,25);
-- Inserción manual para demostrar la llamada al algoritmo C (no INSERT a tabla)
SELECT sl_insert(40, '(0,99)'::tid) AS insertado;
SELECT sl_search(40) AS ctid_manual;
SELECT sl_clear();
SELECT sl_count() AS nodos_despues_de_limpiar;
