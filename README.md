COMO EJECUTAR EL PROYECTO

Necesitas Git y Docker Desktop instalado. Abre Docker Desktop antes de comenzar.

1. Abre PowerShell y descarga el proyecto:

git clone https://github.com/JoacoRFM/BD2_Project.git
cd BD2_Project

Si ya tienes la carpeta del proyecto, entra en ella y usa git pull origin main.

2. Inicia PostgreSQL:

docker compose up -d --build

3. Revisa que esté funcionando:

docker compose ps

4. Entra a la base de datos:

docker compose exec postgres psql -U bd2 -d bd2

5. Dentro de PostgreSQL, activa la extensión:

CREATE EXTENSION IF NOT EXISTS skiplist;

6. Crea una tabla e inserta datos:

CREATE TABLE alumnos (id INTEGER PRIMARY KEY, nombre TEXT, edad INTEGER);
INSERT INTO alumnos (id, nombre, edad) VALUES (1, 'Ana', 20), (2, 'Luis', 21), (3, 'Maria', 19);
SELECT * FROM alumnos;

7. Crea la Skip List usando la columna id:

SELECT sl_build('alumnos'::regclass, 'id');

8. Prueba las búsquedas:

SELECT sl_count();
SELECT sl_search(2);
SELECT * FROM alumnos WHERE ctid = sl_search(2);
SELECT * FROM sl_range(1, 3);

9. Para agregar una fila nueva a la tabla y a la Skip List:

WITH nuevo AS (
    INSERT INTO alumnos (id, nombre, edad)
    VALUES (4, 'Pedro', 22)
    RETURNING id, ctid
)
SELECT sl_insert(id, ctid) FROM nuevo;

10. Sal de PostgreSQL:

\q

PARA EJECUTAR LOS ARCHIVOS DE PRUEBA

Estos comandos van en PowerShell, fuera de PostgreSQL:

docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/01_demo.sql
docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/03_verificaciones.sql
docker compose exec -T postgres psql -U bd2 -d bd2 -f /workspace/sql/02_comparacion.sql

COMANDOS DE TERMINAL

git pull origin main                         Descargar cambios recientes
docker compose up -d --build                 Iniciar y compilar el proyecto
docker compose ps                            Ver el estado de PostgreSQL
docker compose exec postgres psql -U bd2 -d bd2   Entrar a PostgreSQL
docker compose logs postgres                 Ver mensajes del servidor
docker compose restart postgres              Reiniciar PostgreSQL
docker compose down                          Detener sin borrar datos
docker compose down -v                       Detener y borrar datos guardados

COMANDOS DENTRO DE POSTGRESQL

\l                 Mostrar bases de datos
\c bd2             Conectarse a la base bd2
\dt                Mostrar tablas
\d alumnos         Mostrar estructura de alumnos
\dx                Mostrar extensiones
\?                 Ayuda de comandos de psql
\h                 Ayuda de SQL
\q                 Salir

COMANDOS SQL

CREATE DATABASE prueba;                                    Crear base de datos
CREATE TABLE alumnos (id INTEGER PRIMARY KEY, nombre TEXT, edad INTEGER);   Crear tabla
SELECT * FROM alumnos;                                     Ver filas
SELECT * FROM alumnos WHERE id = 2;                        Buscar por id
INSERT INTO alumnos (id, nombre, edad) VALUES (5, 'Sofia', 20);   Insertar fila
UPDATE alumnos SET edad = 23 WHERE id = 2;                 Actualizar fila
DELETE FROM alumnos WHERE id = 3;                          Eliminar fila
DROP TABLE alumnos;                                        Eliminar tabla

COMANDOS DE LA SKIP LIST

CREATE EXTENSION IF NOT EXISTS skiplist;      Activar extensión
SELECT sl_build('alumnos'::regclass, 'id');   Crear o reconstruir Skip List
SELECT sl_search(2);                         Buscar clave y obtener CTID
SELECT * FROM alumnos WHERE ctid = sl_search(2);   Obtener la fila encontrada
SELECT * FROM sl_range(1, 5);                Buscar CTID entre dos claves
SELECT sl_count();                           Contar claves
SELECT sl_clear();                           Vaciar Skip List

IMPORTANTE

Los comandos docker se ejecutan en PowerShell. Los comandos SQL y los que comienzan con \ se ejecutan dentro de PostgreSQL.
La tabla queda guardada, pero la Skip List solo existe durante la conexión actual. Al volver a entrar, usa sl_build otra vez.
sl_insert solo modifica la Skip List, no la tabla. Para agregar una fila usa INSERT INTO y luego actualiza o reconstruye la Skip List.
Si cambias o borras filas con UPDATE o DELETE, reconstruye la Skip List con sl_build para evitar CTID desactualizados.
docker compose down -v borra también los datos almacenados.
