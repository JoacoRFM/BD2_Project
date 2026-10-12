# BD2 — Skip List en PostgreSQL (etapa I, hasta 5.6)

Implementación académica de una Skip List **en C** con un puente **SQL → extensión C → estructura en memoria** mediante SPI de PostgreSQL. El alcance termina en el punto **5.6** de la rúbrica (parcial práctico). No incluye distribución ni experimentación de la etapa II.

## Requisitos
- Docker Desktop (Windows: motor Linux/WSL2) o Docker Engine con Docker Compose.
- Git para clonar el proyecto.
- Puerto local 55432 libre.
- Docker debe poder descargar la imagen `postgres:18.6-bookworm`.

## Desde cero: Windows PowerShell o terminal Linux/macOS
1. Inicia Docker Desktop / Docker Engine.
2. Clona el proyecto y entra a su carpeta:
   ```sh
   git clone https://github.com/JoacoRFM/BD2_Project.git
   cd BD2_Project
   ```
   En un repositorio privado, debes autenticarte en GitHub previamente.
3. Construye la imagen e inicia PostgreSQL 18.6:
   ```sh
   docker compose up -d --build
   ```
4. Comprueba el estado (espera a que aparezca healthy):
   ```sh
   docker compose ps
   ```
5. Ejecuta la demostración **en una sola conexión**:
   ```sh
   docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/01_demo.sql
   ```
6. Comprueba las verificaciones automáticas:
   ```sh
   docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/03_verificaciones.sql
   ```
7. Ejecuta la comparación preliminar sin índice / B-tree / Skip List:
   ```sh
   docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/02_comparacion.sql
   ```

Las funciones `sl_build`, `sl_search`, `sl_insert`, `sl_range`, `sl_count` y `sl_clear` operan en la **sesión PostgreSQL actual**. No ejecutes `sl_build` en un comando `psql -c` y `sl_search` en otro: cada comando abre una conexión nueva y pierde esa Skip List.

## Sesión SQL interactiva para exposición
```sh
docker compose exec postgres psql -U bd2 -d bd2
```
Ya dentro de `psql`:
```sql
CREATE EXTENSION IF NOT EXISTS skiplist;
SELECT sl_build('public.demo_skiplist'::regclass,'id');
SELECT sl_search(20);
SELECT * FROM public.demo_skiplist WHERE ctid = sl_search(20);
SELECT sl_search(999) IS NULL AS ausente;
SELECT sl_count();
\q
```

## Reiniciar
```sh
docker compose restart postgres
```
Luego repite `01_demo.sql`, porque la Skip List no es persistente. La **tabla SQL sí persiste**. Para borrar también los datos y comenzar limpio:
```sh
docker compose down -v
docker compose up -d --build
```

## Qué está integrado y qué NO
- `skiplist.c/h`: nodos, niveles aleatorios, construcción, búsqueda, inserción, validación y rango.
- `skiplist_pg.c`: expone las funciones SQL, utiliza SPI para leer filas y sus `ctid`, y mantiene los nodos en memoria de la conexión.
- `skiplist--1.0.sql`: registra las funciones en PostgreSQL.
- `Makefile`, `skiplist.control`: compilan/registran la extensión PGXS.
- `Dockerfile` y `compose.yaml`: instalación reproducible con PostgreSQL 18.6.
- La Skip List **no** es un `CREATE INDEX USING skiplist` ni un índice seleccionado automáticamente por `EXPLAIN`. La comparación es una **primera demostración funcional**, NO un benchmark científico equivalente.
- Cada clave se almacena una vez. Claves duplicadas reemplazan el CTID previo.
- `sl_insert` **no hace INSERT a la tabla**: primero inserta en SQL y luego registra el CTID retornado. Los UPDATE/DELETE y reorganizaciones que cambien CTID obligan a reconstruir la Skip List.
- No hay WAL propio, persistencia de la estructura ni coordinación entre conexiones.

## Explicación para el examen
**Construcción:** `sl_build(tabla,columna)` abre un cursor SPI, lee `(integer,ctid)` y agrega cada par ordenadamente por `skiplist_insert`.
**Búsqueda:** `sl_search(k)` recorre enlaces horizontales desde el nivel más alto al más bajo; devuelve el CTID encontrado o NULL.
**Inserción:** `skiplist_insert` encuentra los predecesores de la clave en cada nivel y enlaza un nuevo nodo de altura aleatoria. Si existe la clave, actualiza el CTID.
**Complejidad esperada:** búsqueda e inserción O(log n), construcción incremental O(n log n), memoria O(n). El peor caso puede ser O(n).
**Comparación:** en `02_comparacion.sql` se consulta la misma clave sin índice y luego con B-tree y se demuestra búsqueda explícita con la Skip List. No atribuir al planificador un acceso automático a la Skip List.

## Referencias y procedencia
- William Pugh, *Skip Lists: A Probabilistic Alternative to Balanced Trees* (1990), Communications of the ACM.
- Documentación oficial PostgreSQL: [SPI](https://www.postgresql.org/docs/18/spi.html) y [PGXS](https://www.postgresql.org/docs/18/extend-pgxs.html).
- Se preserva el código C de Skip List y el puente PostgreSQL preexistente del equipo. Los archivos de Docker, SQL de demostración/verificación/comparación y esta documentación fueron preparados con asistencia de IA (OpenAI ChatGPT, octubre de 2026); el equipo debe revisar, comprender y declarar su uso.

## Límites respecto a la rúbrica
Este repositorio cubre código y demostraciones de la etapa I. La **propuesta inicial de hasta 2 páginas** del punto 5.5 requiere agregar los nombres del equipo, motivación propia y decisiones acordadas. Tampoco se implementa la etapa II (secciones 6 en adelante).
