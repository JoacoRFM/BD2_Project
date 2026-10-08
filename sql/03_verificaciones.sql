\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS skiplist;
DROP TABLE IF EXISTS public.verificacion_skiplist;
CREATE TABLE public.verificacion_skiplist(id integer PRIMARY KEY);
INSERT INTO public.verificacion_skiplist SELECT generate_series(1,100);
DO $$
BEGIN
  IF sl_build('public.verificacion_skiplist'::regclass, 'id') <> 100 THEN
    RAISE EXCEPTION 'Fallo: construir 100 claves';
  END IF;
  IF sl_search(50) IS NULL OR sl_search(-1) IS NOT NULL THEN
    RAISE EXCEPTION 'Fallo: busqueda existente/ausente';
  END IF;
  IF (SELECT count(*) FROM sl_range(10,20)) <> 11 THEN
    RAISE EXCEPTION 'Fallo: rango esperado de 11';
  END IF;
  IF sl_count() <> 100 THEN
    RAISE EXCEPTION 'Fallo: conteo';
  END IF;
END $$;
WITH nueva AS (
 INSERT INTO public.verificacion_skiplist VALUES (101) RETURNING id,ctid
) SELECT sl_insert(id,ctid) AS actualizado FROM nueva;
DO $$
BEGIN
 IF sl_search(101) IS NULL OR sl_count() <> 101 THEN
   RAISE EXCEPTION 'Fallo: insercion';
 END IF;
END $$;
SELECT sl_clear();
DO $$
BEGIN
 IF sl_count() <> 0 THEN RAISE EXCEPTION 'Fallo: limpieza'; END IF;
 IF sl_build('public.verificacion_skiplist'::regclass,'id') <> 101 THEN
   RAISE EXCEPTION 'Fallo: reconstruccion'; END IF;
END $$;
\echo TODAS LAS VERIFICACIONES TERMINARON SIN ERROR
