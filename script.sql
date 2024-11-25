-- 1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido.
CREATE DATABASE desafio3_Diego_Araneda_017;

CREATE TABLE Usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(50) NOT NULL
);

INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES 
('admin@example.com', 'Diego', 'Araneda', 'administrador'),
('juan.perez@example.com', 'Juan', 'Pérez', 'usuario'),
('maria.gonzalez@example.com', 'María', 'González', 'usuario'),
('pedro.pereira@example.com', 'Pedro', 'Pereira', 'usuario'),
('lilian.geldres@example.com', 'Lilian', 'Geldres', 'usuario');

CREATE TABLE Posts (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    destacado BOOLEAN DEFAULT FALSE,
    usuario_id BIGINT REFERENCES Usuarios(id)
);

INSERT INTO Posts (titulo, contenido, usuario_id)
VALUES
('Guía para administradores', 'En este post se detallan las mejores prácticas para administrar sistemas.', 1),
('Políticas de seguridad', 'Este artículo describe cómo implementar políticas de seguridad para proteger datos.', 1),
('Recetas rápidas', 'Una lista de recetas rápidas y fáciles para cocinar en menos de 30 minutos.', 2),
('Viajes por América', 'Un recorrido por los lugares más impresionantes de América Latina.', 3),
('Noticias globales', 'Las noticias más relevantes de la última semana resumidas para tu conveniencia.', NULL);

CREATE TABLE Comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT REFERENCES Usuarios(id),
    post_id BIGINT REFERENCES Posts(id)
);

INSERT INTO Comentarios (contenido, usuario_id, post_id)
VALUES
('Muy útil, gracias por compartir esta información.', 1, 1),
('¿Podrías incluir ejemplos prácticos?', 2, 1),
('Esto me ayudó a implementar un cambio en mi sistema.', 3, 1),
('Interesante enfoque, me gustaría aprender más.', 1, 2),
('Gracias por las recomendaciones, fueron de gran ayuda.', 2, 2);


-- 2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post.
select u.nombre, u.email, p.titulo, p.contenido from Posts p 
	join Usuarios u on p.usuario_id = u.id;

-- 3. Muestra el id, título y contenido de los posts de los administradores.
--	a. El administrador puede ser cualquier id.
select p.id, p.titulo, p.contenido from Posts p 
	where p.usuario_id in (
		select u.id from Usuarios u where u.rol ='administrador'
	);

-- 4. Cuenta la cantidad de posts de cada usuario.
--  a. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.
select u.id, u.email, count(p.id) as posts from Posts p 
	join Usuarios u on p.usuario_id = u.id 
	group by p.usuario_id, u.id;

-- 5. Muestra el email del usuario que ha creado más posts.
--  a. Aquí la tabla resultante tiene un único registro y muestra solo el email.
select u.email from Usuarios u 
	join Posts p on p.usuario_id = u.id 
	group by u.id, u.email 
	order by count(p.id) 
	desc limit 1;

-- 6. Muestra la fecha del último post de cada usuario.
select u.id, u.email, max(p.fecha_creacion) from Usuarios u 
	join Posts p on u.id=p.usuario_id 
	group by u.id, u.email;

-- 7. Muestra el título y contenido del post (artículo) con más comentarios.
select p.titulo, p.contenido from Posts p 
	join Comentarios c on c.post_id=p.id
	group by p.id, p.titulo, p.contenido
	order by count(c.id) desc
	limit 1;

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario 
--		asociado a los posts mostrados, junto con el email del usuario que lo escribió.
select p.titulo, p.contenido, c.contenido, u.email from Posts p
	join Comentarios c on c.post_id = p.id
	join Usuarios u on c.usuario_id = u.id;

-- 9. Muestra el contenido del último comentario de cada usuario.
select u.email, c.contenido from Usuarios u
	join Comentarios c on c.usuario_id = u.id 
	where c.fecha_creacion in (
		select max(c.fecha_creacion) from Comentarios c where c.usuario_id = u.id
	);

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario.
select u.email from Usuarios u
	left join Comentarios c on u.id = c.usuario_id
	where c.id is null;
