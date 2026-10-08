\set ON_ERROR_STOP on
\echo ===== VERSION Y EXTENSION =====
SELECT version();
CREATE EXTENSION IF NOT EXISTS skiplist;
DROP TABLE IF EXISTS public.demo_skiplist;
CREATE TABLE public.demo_skiplist (id integer PRIMARY KEY, nombre text NOT NULL);
INSERT INTO public.demo_skiplist (id,nombre) VALUES
 (5,'A'),(10,'B'),(20,'C'),(30,'D');
\echo ===== CONSTRUCCION DESDE FILAS REALES =====
SELECT sl_build('public.demo_skiplist'::regclass,'id') AS cantidad;
SELECT sl_count() AS cantidad_en_skiplist;
\echo ===== BUSQUEDA EXISTENTE Y AUSENTE =====
SELECT sl_search(20) IS NOT NULL AS encontro_20,
       sl_search(999) IS NULL AS no_encontro_999;
\echo ===== RECUPERAR UNA FILA USANDO EL CTID ENCONTRADO =====
SELECT id,nombre FROM public.demo_skiplist WHERE ctid = sl_search(20);
\echo ===== BUSQUEDA POR RANGO =====
SELECT t.id, t.nombre
FROM sl_range(8,25) AS hits(ctid_buscado)
JOIN public.demo_skiplist t ON t.ctid = hits.ctid_buscado
ORDER BY t.id;
\echo ===== INSERTAR FILA SQL Y REGISTRAR SU CTID =====
WITH nueva AS (
  INSERT INTO public.demo_skiplist (id,nombre)
  VALUES (40,'E') RETURNING id,ctid
)
SELECT sl_insert(id,ctid) AS agregado_a_skiplist FROM nueva;
SELECT t.id,t.nombre FROM public.demo_skiplist t WHERE t.ctid = sl_search(40);
SELECT sl_count() AS cantidad_despues_de_insert;
\echo ===== RECONSTRUCCION Y REINICIO DE MEMORIA =====
SELECT sl_build('public.demo_skiplist'::regclass,'id') AS cantidad_reconstruida;
SELECT sl_search(40) IS NOT NULL AS insercion_persistente_en_tabla;
SELECT sl_clear();
SELECT sl_count() = 0 AS lista_limpiada;
SELECT sl_build('public.demo_skiplist'::regclass,'id') = 5 AS reconstruccion_correcta;
\echo ===== DEMO COMPLETA =====
