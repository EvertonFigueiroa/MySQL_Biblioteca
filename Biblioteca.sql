-- Criando o banco de dados
CREATE DATABASE Biblioteca;

-- Usando o banco de dados
use Biblioteca;

-- Criando a tabela "livros"
CREATE TABLE livros (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(100) NOT NULL,
  autor VARCHAR(50) NOT NULL,
  ano_publicacao INT,
  categoria VARCHAR(50)
);

-- Criando a tabela "usuarios"
CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  data_nascimento DATE
);

-- Criando a tabela "emprestimos"
CREATE TABLE emprestimos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_livro INT NOT NULL,
  id_usuario INT NOT NULL,
  data_emprestimo DATE NOT NULL,
  data_devolucao DATE,
  FOREIGN KEY (id_livro) REFERENCES livros(id),
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
);

-- Inserindo dados na tabela "livros"
INSERT INTO livros (titulo, autor, ano_publicacao, categoria)
VALUES ('Livro 1', 'Autor 1', 2000, 'Ficção'),
       ('Livro 2', 'Autor 2', 2010, 'Fantasia'),
       ('Livro 3', 'Autor 3', 2021, 'Romance'),
       ('Livro 4', 'Autor 4', 2005, 'Aventura'),
       ('Livro 5', 'Autor 5', 2015, 'Suspense'),
       ('Livro 6', 'Autor 6', 2022, 'Drama'),
       ('Livro 7', 'Autor 7', 2023, 'Terror'),
       ('Livro 8', 'Autor 8', 2005, 'Ação'),
       ('Livro 9', 'Autor 9', 2010, 'Comédia'),
       ('Livro 10', 'Autor 10', 2022, 'Romance');
      
-- Inserindo dados na tabela "usuarios"
INSERT INTO usuarios (nome, email, data_nascimento)
VALUES ('Everton', 'everton@gmail.com', '1970-06-01'),
       ('Daniel', 'daniel@gmail.com', '1996-09-30'),
       ('Matheus', 'matheus@gmail.com', '1987-05-25'),
       ('Vinicius', 'vinicius@gmail.com', '1985-05-10');

-- Inserindo dados na tabela "emprestimos"
INSERT INTO emprestimos (id_livro, id_usuario, data_emprestimo, data_devolucao)
VALUES (1, 1, '2023-01-20', NULL),
       (7, 1, '2023-02-21', '2023-02-25'),
       (10, 4, '2023-05-29', NULL),
       (6, 2, '2023-04-30', NULL),
       (5, 2, '2023-03-11', NULL);

-- Criando trigger para atualizar a data de devolução automaticamente
DELIMITER //
CREATE TRIGGER atualizar_data_devolucao
BEFORE INSERT ON emprestimos
FOR EACH ROW
BEGIN
  IF NEW.data_devolucao IS NULL THEN
    SET NEW.data_devolucao = ADDDATE(NEW.data_emprestimo, INTERVAL 15 DAY);
  END IF;
END //
DELIMITER ;

-- Criando trigger para mensagem de atenção antes de deletar algum registro da tabela emprestimo
DELIMITER //
CREATE TRIGGER alterar_table_emprestimo
BEFORE DELETE ON emprestimos
FOR EACH ROW
BEGIN
  IF OLD.data_devolucao IS NULL OR OLD.data_devolucao IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido a exclusão dessa informação';
  END IF;
END //
DELIMITER ;

-- Criando stored procedure para listar os livros emprestados por um determinado usuário
DELIMITER //
CREATE PROCEDURE listar_livros_emprestados_por_usuario(IN usuario_id INT)
BEGIN
  SELECT l.titulo, l.autor, l.ano_publicacao, l.categoria
  FROM livros l
  INNER JOIN emprestimos e ON l.id = e.id_livro
  WHERE e.id_usuario = usuario_id;
END //
DELIMITER ;

-- Consulta para obter a contagem de livros em cada categoria
SELECT categoria, COUNT(*) AS quantidade
FROM livros
GROUP BY categoria;

-- Consulta para saber qual livro cada usuário possuí
SELECT u.nome, l.titulo, l.categoria, e.data_devolucao 
FROM usuarios u 
inner join emprestimos e ON e.id_usuario = u.id
inner join livros l ON l.id = e.id_livro
order BY nome;

-- Consulta para saber quantos livro cada usuário possuí
SELECT u.nome, count(u.nome) as Livros
FROM usuarios u 
inner join emprestimos e ON e.id_usuario = u.id
inner join livros l ON l.id = e.id_livro
GROUP BY u.nome;

-- Consulta para obter a média de dias que os livros são emprestados
SELECT AVG(DATEDIFF(data_devolucao, data_emprestimo)) AS media_dias_emprestimo
FROM emprestimos
WHERE data_devolucao IS NOT NULL;

SELECT * FROM emprestimos;

UPDATE emprestimos
SET data_devolucao = '2023-04-10'
WHERE id = 5; 

DELETE FROM emprestimos
WHERE id = 5;

CALL listar_livros_emprestados_por_usuario(1);

