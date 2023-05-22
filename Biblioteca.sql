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
       ('Livro 3', 'Autor 3', 2021, 'Romance');

-- Inserindo dados na tabela "usuarios"
INSERT INTO usuarios (nome, email, data_nascimento)
VALUES ('Usuário 1', 'usuario1@email.com', '1990-01-01'),
       ('Usuário 2', 'usuario2@email.com', '1985-05-10');

-- Inserindo dados na tabela "emprestimos"
INSERT INTO emprestimos (id_livro, id_usuario, data_emprestimo, data_devolucao)
VALUES (1, 1, '2023-01-01', NULL),
       (2, 1, '2023-02-01', '2023-02-15'),
       (3, 2, '2023-03-01', NULL);

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

-- Consulta para obter a média de dias que os livros são emprestados
SELECT AVG(DATEDIFF(data_devolucao, data_emprestimo)) AS media_dias_emprestimo
FROM emprestimos
WHERE data_devolucao IS NOT NULL;

call listar_livros_emprestados_por_usuario(1);
