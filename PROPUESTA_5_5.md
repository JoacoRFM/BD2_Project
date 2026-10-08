# Propuesta inicial — Etapa I (rúbrica 5.5)

**Curso:** Bases de Datos II — 2026-II  
**Equipo:** [Completar integrantes]  
**Estructura seleccionada:** Skip List  
**Fecha de presentación:** [Completar]

## Elección y motivación
Seleccionamos una **Skip List** porque permite observar de forma concreta cómo una estructura de indexación mantiene claves enteras ordenadas mediante varios niveles de enlaces. A diferencia de B-tree, el equilibrio es **probabilístico**: al insertar se escoge aleatoriamente la altura de cada nuevo nodo. Este proyecto nos permite comparar conceptualmente una estructura propia con el índice B-tree nativo de PostgreSQL.

## Referencias
1. Pugh, W. (1990). *Skip Lists: A Probabilistic Alternative to Balanced Trees*. Communications of the ACM, 33(6), 668–676.
2. PostgreSQL 18, documentación oficial: *Server Programming Interface (SPI)*, https://www.postgresql.org/docs/18/spi.html
3. PostgreSQL 18, documentación oficial: *Extension Building Infrastructure (PGXS)*, https://www.postgresql.org/docs/18/extend-pgxs.html

## Representación y operaciones
Cada nodo almacena **clave INTEGER**, **CTID de la fila** y un arreglo de punteros `forward[]`. Un nodo cabeza conecta los niveles; el nivel 0 contiene todas las claves ordenadas. Se construye la Skip List leyendo las parejas `(clave,ctid)` desde PostgreSQL mediante SPI. Se implementan búsqueda por igualdad e inserción; el código también admite rango y limpieza. La inserción localiza predecesores en cada nivel y enlaza un nodo con altura aleatoria. La búsqueda avanza horizontalmente y desciende hasta el nivel inferior. Se esperan búsquedas e inserciones O(log n) en promedio, O(n) en el peor caso.

## Tipo de clave y consultas
Se aceptan **claves integer**. Las consultas principales son la búsqueda exacta y, como extensión sencilla, el rango inclusivo. Para el parcial usaremos claves sin duplicados: la implementación mantiene un solo CTID por clave y reemplaza el CTID si se repite.

## Estrategia de integración con PostgreSQL
Compilaremos los archivos en C como una extensión PostgreSQL con **PGXS**; las funciones SQL `sl_build`, `sl_search`, `sl_insert` y `sl_range` invocan el código C. La construcción obtiene CTIDs de filas reales mediante SPI. Esta solución es **académica**, explícita y por sesión: no implementa un método de acceso registrado en `CREATE INDEX` ni integración automática con el planificador.

## Componentes propios y recursos reutilizados
- **Código desarrollado por el equipo:** `skiplist.c`, `skiplist.h`, `skiplist_pg.c`, esquema de extensión y pruebas originales. **Verificar y ajustar esta atribución** según autoría real.
- **Infraestructura y documentación asistidas por IA:** `Dockerfile`, `compose.yaml`, SQL de pruebas y `README.md` (OpenAI ChatGPT, octubre de 2026).
- **Bibliotecas/herramientas:** PostgreSQL 18, SPI, PGXS, Docker, compilador C, Git. No se incorpora una implementación ajena de Skip List.

## Riesgos y plan de trabajo
**Riesgos:** el CTID puede cambiar al modificar/reorganizar filas; la lista no persiste entre sesiones ni reinicios; duplicados no conservan todas sus filas; PostgreSQL no optimiza estas llamadas como índices B-tree. **Mitigación:** usar claves únicas, reconstruir ante cambios, demostrar todo en la misma conexión y explicar claramente el alcance.

**Plan:** (1) revisar representación y algoritmos, (2) validar búsqueda/construcción, (3) validar inserción, (4) integrar extensión PGXS y Docker, (5) ejecutar demostración y primera comparación con B-tree, ensayar preguntas de defensa.

> Antes de entregar: completar datos del equipo y revisar atribuciones, decisiones y referencias. Mantener el documento dentro de **dos páginas** al exportarlo.
