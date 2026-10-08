\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS skiplist;
DROP TABLE IF EXISTS public.comparacion_skiplist;
CREATE TABLE public.comparacion_skiplist (id integer NOT NULL, dato text NOT NULL);
INSERT INTO public.comparacion_skiplist (id,dato)
SELECT (g * 7919) % 100003, 'fila_' || g FROM generate_series(1,10000) AS g;
ANALYZE public.comparacion_skiplist;
\echo ===== SIN INDICE (CONSULTA POR CLAVE) =====
EXPLAIN (ANALYZE, BUFFERS)
 SELECT * FROM public.comparacion_skiplist WHERE id = 7919;
\echo ===== BTREE (MISMA CONSULTA) =====
CREATE INDEX comparacion_skiplist_btree ON public.comparacion_skiplist(id);
ANALYZE public.comparacion_skiplist;
SET enable_seqscan = off;
EXPLAIN (ANALYZE, BUFFERS)
 SELECT * FROM public.comparacion_skiplist WHERE id = 7919;
RESET enable_seqscan;
\echo ===== SKIP LIST PROPIA (ACCESO EXPLICITO) =====
SELECT sl_build('public.comparacion_skiplist'::regclass,'id') AS cantidad;
SELECT sl_search(7919) IS NOT NULL AS encontro_clave;
SELECT t.id, t.dato FROM public.comparacion_skiplist t
 WHERE t.ctid = sl_search(7919);
\echo ===== NOTA: no son tiempos directamente comparables =====
\echo La Skip List no es un metodo de acceso del planificador.
