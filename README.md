**Ejecutar el proyecto desde cero**

1. Instalar Git y Docker Desktop. Abrir Docker Desktop y esperar a que esté iniciado.
2. Abrir PowerShell o una terminal y descargar el proyecto:

```bash
git clone https://github.com/JoacoRFM/BD2_Project.git
cd BD2_Project
```

3. Construir e iniciar PostgreSQL con la extensión:

```bash
docker compose up -d --build
docker compose ps
```

4. Entrar a PostgreSQL:

```bash
docker compose exec postgres psql -U bd2 -d bd2
```

5. Dentro de PostgreSQL, activar la extensión y crear una tabla de ejemplo:

```sql
CREATE EXTENSION IF NOT EXISTS skiplist;

CREATE TABLE alumnos (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100),
    edad INTEGER
);

INSERT INTO alumnos (id, nombre, edad) VALUES
(1, 'Ana', 20),
(2, 'Luis', 21),
(3, 'Maria', 19);

SELECT * FROM alumnos;
```

6. Construir la Skip List y probar las búsquedas:

```sql
SELECT sl_build('alumnos'::regclass, 'id');
SELECT sl_count();
SELECT sl_search(2);
SELECT * FROM alumnos WHERE ctid = sl_search(2);

SELECT a.*
FROM sl_range(1, 3) AS r(tid_encontrado)
JOIN alumnos a ON a.ctid = r.tid_encontrado
ORDER BY a.id;
```

7. Para agregar una fila nueva a la tabla y a la Skip List en la misma operación:

```sql
WITH nuevo AS (
    INSERT INTO alumnos (id, nombre, edad)
    VALUES (4, 'Pedro', 22)
    RETURNING id, ctid
)
SELECT sl_insert(id, ctid) FROM nuevo;
```

8. Salir de PostgreSQL con `\q`.

**Ejecutar las pruebas del proyecto**

Estos comandos se ejecutan en PowerShell o en la terminal, fuera de PostgreSQL:

```bash
docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/01_demo.sql
docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/03_verificaciones.sql
docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/02_comparacion.sql
```

**Comandos de Docker y terminal**

| Comando | Para qué sirve |
|---|---|
| `git pull origin main` | Descargar los últimos cambios del repositorio |
| `docker compose up -d --build` | Construir e iniciar el proyecto |
| `docker compose ps` | Ver si PostgreSQL está funcionando |
| `docker compose exec postgres psql -U bd2 -d bd2` | Entrar a PostgreSQL |
| `docker compose logs postgres` | Ver mensajes del contenedor |
| `docker compose restart postgres` | Reiniciar PostgreSQL |
| `docker compose down` | Detener los contenedores sin borrar los datos |
| `docker compose down -v` | Detener y borrar también los datos guardados en Docker |

**Comandos dentro de PostgreSQL (psql)**

| Comando | Para qué sirve |
|---|---|
| `\l` | Ver las bases de datos |
| `\c bd2` | Conectarse a la base de datos bd2 |
| `\dt` | Ver las tablas |
| `\d alumnos` | Ver las columnas de la tabla alumnos |
| `\dx` | Ver las extensiones instaladas |
| `\?` | Ver ayuda de comandos de psql |
| `\h` | Ver ayuda de SQL |
| `\q` | Salir de PostgreSQL |

**Comandos SQL para manejar la base de datos**

| Comando | Para qué sirve |
|---|---|
| `CREATE DATABASE prueba;` | Crear una base de datos |
| `CREATE TABLE alumnos (id INTEGER PRIMARY KEY, nombre TEXT);` | Crear una tabla |
| `SELECT * FROM alumnos;` | Ver todas las filas |
| `SELECT * FROM alumnos WHERE id = 2;` | Buscar una fila por su id |
| `INSERT INTO alumnos (id, nombre) VALUES (5, 'Sofia');` | Insertar una fila (ejemplo para una tabla de dos columnas) |
| `UPDATE alumnos SET edad = 23 WHERE id = 2;` | Modificar una fila de la tabla de tres columnas |
| `DELETE FROM alumnos WHERE id = 3;` | Eliminar una fila |
| `DROP TABLE alumnos;` | Eliminar la tabla |

**Comandos de la Skip List**

| Comando | Para qué sirve |
|---|---|
| `CREATE EXTENSION IF NOT EXISTS skiplist;` | Activar la extensión |
| `SELECT sl_build('alumnos'::regclass, 'id');` | Construir o reconstruir la Skip List desde la tabla |
| `SELECT sl_search(2);` | Buscar la clave 2 y devolver su CTID |
| `SELECT * FROM alumnos WHERE ctid = sl_search(2);` | Obtener la fila correspondiente |
| `SELECT * FROM sl_range(1, 5);` | Buscar CTID de claves entre 1 y 5 |
| `SELECT sl_count();` | Contar las claves guardadas |
| `SELECT sl_clear();` | Vaciar la Skip List |
| `SELECT sl_insert(5, '(0,1)'::tid);` | Insertar una clave y un CTID manualmente (solo ejemplo de sintaxis; el CTID debe ser real) |

**Importante**

- Los comandos `docker` se ejecutan en PowerShell o en la terminal. Los comandos SQL y los que empiezan con `\` se ejecutan dentro de `psql`.
- La tabla se guarda en PostgreSQL, pero la Skip List está en memoria y solo existe en la conexión actual. Si sales con `\q` y vuelves a entrar, ejecuta nuevamente `sl_build`.
- `sl_insert` no agrega filas a la tabla: solo registra una clave y su CTID en la Skip List. Para agregar una fila nueva usa `INSERT INTO` y después actualiza o reconstruye la Skip List.
- Después de `UPDATE` o `DELETE`, conviene ejecutar nuevamente `SELECT sl_build('alumnos'::regclass, 'id');`, ya que los CTID pueden cambiar o quedar obsoletos.
- La Skip List de este proyecto se usa llamando sus funciones SQL; no reemplaza automáticamente los índices de PostgreSQL.
