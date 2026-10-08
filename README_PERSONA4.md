# Integración PGXS — Persona 4

## Archivos
- `skiplist.c`, `skiplist.h`: código del grupo (incluido para compilar; sustituir por versiones oficiales del equipo).
- `skiplist_pg.c`: funciones puente PostgreSQL/C.
- `Makefile`: compila `skiplist.c` y `skiplist_pg.c` en una sola librería `skiplist.so`.
- `skiplist.control`: metadata de extensión.
- `skiplist--1.0.sql`: definiciones SQL de funciones.
- `PRUEBA.sql`: demostración del flujo.

## Dentro del contenedor de PostgreSQL 18 con herramientas de desarrollo

```sh
make
make install
```

Luego, **dentro de una única sesión psql**:

```sql
CREATE EXTENSION skiplist;
\i PRUEBA.sql
```

`CREATE EXTENSION` se ejecuta una vez por base de datos; usa `IF NOT EXISTS` en pruebas repetidas.

## Importante

- `sl_build('tabla'::regclass, 'columna')`: consulta mediante SPI filas reales y sus CTID; construye una Skip List solo para el backend que ejecutó la función.
- `sl_search(clave)`: busca en la estructura C y retorna un CTID (`tid`) o NULL.
- `sl_insert(clave, ctid)`: actualiza **solo la estructura en memoria**, NO inserta una fila SQL.
- `sl_range(lo, hi)`: devuelve CTID dentro del rango.
- `sl_clear()`, `sl_count()`: control de sesión.
- Si se ejecuta la siguiente consulta desde **otra conexión PostgreSQL**, se pierde acceso a la instancia anterior: cada backend tiene su propia variable global.
- La Skip List **no es un índice de PostgreSQL elegido automáticamente por EXPLAIN**. No reemplaza CREATE INDEX USING btree.
- `ctid` cambia con UPDATE/VACUUM FULL y otras reorganizaciones. Reconstruir luego de cambios de la tabla.
- No se admite un CTID por cada fila con clave duplicada: el core original sustituye el CTID para claves iguales.
- La extensión no tiene persistencia/WAL, bloqueo concurrente ni integración con el planificador.
- Este paquete NO incluye un Dockerfile: lo realiza la Persona 1.
- Registro de referencias y ayuda externa requerido por rúbrica.
