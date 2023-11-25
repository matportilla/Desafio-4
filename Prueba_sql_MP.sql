-- iniciar postgresql

psql -U postgres

-- 1) Revisión y Creacion de Modelo

-- Creacion de Base de datos
CREATE DATABASE prueba_sql_matias_portilla_685;

-- ingresar a Base

\c prueba_sql_matias_portilla_685

-- Crear Tablas 

CREATE TABLE peliculas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255),
  anno INTEGER);

CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  tag VARCHAR(32));

-- Tabla intermedia 
CREATE TABLE peliculas_tags (
  id SERIAL PRIMARY KEY,
  id_pelicula INTEGER REFERENCES peliculas(id),
  id_tag INTEGER REFERENCES tags(id));

-- 2) Inserta 5 películas y 5 tags; la primera película debe tener 3 tags asociados, la segunda película debe tener 2 tags asociados.

-- Peliculas
INSERT INTO peliculas (nombre, anno) VALUES
  ('Zombi', 1978),
  ('Zombies Party', 2004),
  ('Train to Busan', 2016),
  ('28 Días después', 2002),
  ('Los Hambrientos', 2017);

-- Tags
INSERT INTO tags (tag) VALUES
  ('Horror'),
  ('Comedia'),
  ('Suspenso'),
  ('Zombies'),
  ('Acción');


-- Asosiación Tags Peliculas
INSERT INTO peliculas_tags (id_pelicula, id_tag) VALUES
  (1, 1),
  (1, 3),
  (1, 4),
  (2, 1),
  (2, 2);


-- 3) Cuenta la cantidad de tags que tiene cada película. Si una película no tiene tags debe mostrar 0.
SELECT p.id, p.nombre, COUNT(t.id_tag) as cantidad_tags
FROM peliculas as p
LEFT JOIN peliculas_tags as t ON p.id = t.id_pelicula
GROUP BY p.id, p.nombre
ORDER BY cantidad_tags desc;

-- 4) Crea las tablas correspondientes respetando los nombres, tipos, claves primarias y foráneas y tipos de datos.

-- Tabla preguntas
CREATE TABLE preguntas (
  id SERIAL PRIMARY KEY,
  pregunta VARCHAR(255),
  respuesta_correcta VARCHAR
);

-- Tabla usuarios
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255),
  edad INTEGER
);

-- Tabla respuestas
CREATE TABLE respuestas (
  id SERIAL PRIMARY KEY,
  respuesta VARCHAR(255),
  usuario_id INTEGER REFERENCES usuarios(id) ,
  pregunta_id INTEGER REFERENCES preguntas(id));

-- 5) Agrega 5 usuarios y 5 preguntas.

-- Insertar los usuarios
INSERT INTO usuarios (nombre, edad) VALUES
    ('Pedro Pablo.', 49),
    ('Mauro Morales', 30),
    ('Simon Sim', 52),
    ('Yhon Yho', 20),
    ('Bjorg Lopez', 28);

-- Insertar las preguntas
INSERT INTO preguntas (pregunta, respuesta_correcta) VALUES
    ('¿Quién se esconde detrás de la máscara en la sala oscura?', 'Un espectro sin rostro'),
    ('¿Cuál es el origen de los murmullos que llenan la casa en la madrugada?', 'Almas atormentadas'),
    ('¿Quién es el dueño de la tienda de antigüedades que nunca envejece?', 'Un comerciante inmortal'),
    ('¿Qué acecha en las sombras durante la luna llena en el pueblo?', 'Una presencia indescriptible'),
    ('¿Qué revelan los ojos distorsionados en la antigua fotografía del ático?', 'La mirada de lo paranormal');

-- a) La primera pregunta debe estar respondida correctamente dos veces, por dos usuarios diferentes.
    -- Usuario 2 responde correctamente la pregunta 1
    -- Usuario 3 responde correctamente la pregunta 1
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id) VALUES
  ('Un espectro sin rostro', 2, 1), 
  ('Un espectro sin rostro', 3, 1); 
  

-- b) La segunda pregunta debe estar contestada correctamente solo por un usuario.
    -- Usuario 1 responde correctamente la pregunta 2
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id) VALUES
  ('Almas atormentadas', 1, 2); 

-- c) Las otras tres preguntas deben tener respuestas incorrectas.
-- Usuario 4 responde incorrectamente la pregunta 3
-- Usuario 5 responde incorrectamente la pregunta 4
-- Usuario 3 responde incorrectamente la pregunta 5
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id) VALUES
  ('La mirada de lo paranormal', 4, 3), 
  ('Zombies', 5, 4), 
  ('Una presencia indescriptible', 3, 5); 

-- 6) Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta).
SELECT u.nombre, count(r.id) as respuestas_correctas
FROM usuarios u
INNER JOIN respuestas r ON u.id = r.usuario_id
INNER JOIN preguntas p ON p.id = r.pregunta_id
WHERE p.respuesta_correcta = r.respuesta
GROUP BY u.nombre
ORDER BY u.nombre;

-- 7) Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios respondieron correctamente.
SELECT p.id AS pregunta_id, p.pregunta, p.respuesta_correcta, COUNT(r.usuario_id) as usuarios_correctos
FROM preguntas AS p
LEFT JOIN respuestas AS r  ON p.id = r.pregunta_id AND r.respuesta = p.respuesta_correcta
GROUP BY p.id, p.pregunta, p.respuesta_correcta;

-- 8) Implementa un borrado en cascada de las respuestas al borrar un usuario. Prueba la implementación borrando el primer usuario.
ALTER TABLE respuestas 
DROP CONSTRAINT IF EXISTS respuestas_usuario_id_fkey, 
ADD CONSTRAINT respuestas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE;

DELETE FROM usuarios WHERE id = 1;

SELECT * FROM usuarios;

SELECT * FROM respuestas;

-- 9) Crea una restricción que impida insertar usuarios menores de 18 años en la base de datos.
ALTER TABLE usuarios 
DROP CONSTRAINT IF EXISTS ck_edad_minima, 
ADD CONSTRAINT ck_edad_minima CHECK (edad >= 18);

INSERT INTO usuarios (nombre, edad) VALUES
  ('Ti West', 16);

-- 10) Altera la tabla existente de usuarios agregando el campo email. Debe tener la restricción de ser único.
ALTER TABLE usuarios ADD COLUMN email VARCHAR(255);

ALTER TABLE  usuarios 
DROP CONSTRAINT IF EXISTS unique_email, 
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO usuarios (nombre, edad, email) VALUES
  ('Alfred Hitchcock', 80, 'hitchcock@gmail.com'),
  ('Patricia Hitchcock', 93, 'hitchcock@gmail.com'); 