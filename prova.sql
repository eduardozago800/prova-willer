CREATE TABLE aeronaves (
    id SERIAL PRIMARY KEY,
    modelo VARCHAR(100) NOT NULL,
    codigo_cauda VARCHAR(10) UNIQUE NOT NULL,
    capacidade INTEGER NOT NULL CHECK (capacidade > 0)
);


CREATE TABLE pilotos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    codigo_anac CHAR(6) UNIQUE NOT NULL,
    horas_voo INTEGER DEFAULT 0 CHECK (horas_voo >= 0)
);


CREATE TABLE voos (
    id SERIAL PRIMARY KEY,
    aeronave_id INTEGER NOT NULL,
    piloto_id INTEGER NOT NULL,
    numero_voo VARCHAR(20) NOT NULL,
    origem VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendado',


    FOREIGN KEY (aeronave_id) REFERENCES aeronaves(id),
    FOREIGN KEY (piloto_id) REFERENCES pilotos(id),


    CHECK (status IN ('Agendado', 'Em Voo', 'Concluido', 'Cancelado'))
);


CREATE TABLE passageiros (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);


CREATE TABLE passagens (
    id SERIAL PRIMARY KEY,
    voo_id INTEGER NOT NULL,
    passageiro_id INTEGER NOT NULL,
    assento VARCHAR(5) NOT NULL,
    classe VARCHAR(20) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,


    FOREIGN KEY (voo_id) REFERENCES voos(id),
    FOREIGN KEY (passageiro_id) REFERENCES passageiros(id),


    CHECK (classe IN ('Economica', 'Executiva'))
);


INSERT INTO aeronaves (modelo, codigo_cauda, capacidade)
VALUES
('Airbus A320', 'PT101', 180),
('Boeing 737', 'PT202', 190),
('Airbus A321', 'PT303', 220),
('Embraer 195', 'PT404', 130),
('Boeing 787', 'PT505', 290);


INSERT INTO pilotos (nome, codigo_anac, horas_voo)
VALUES
('Lucas Silva', 'ANAC11', 3000),
('Pedro Santos', 'ANAC12', 4000),
('Joao Lima', 'ANAC13', 2500),
('Carlos Souza', 'ANAC14', 4500),
('Matheus Costa', 'ANAC15', 1800);


INSERT INTO passageiros (nome, cpf, email)
VALUES
('Ana Lima', '11111111111', 'ana@email.com'),
('Bruno Silva', '22222222222', 'bruno@email.com'),
('Carlos Mendes', '33333333333', 'carlos@email.com'),
('Julia Souza', '44444444444', 'julia@email.com'),
('Marcos Lima', '55555555555', 'marcos@email.com');


INSERT INTO voos
(aeronave_id, piloto_id, numero_voo, origem, destino, data_hora, status)
VALUES
(1, 1, 'BR101', 'Sao Paulo', 'Rio de Janeiro', '2026-10-05 08:00:00', 'Agendado'),
(2, 2, 'BR202', 'Florianopolis', 'Sao Paulo', '2026-10-05 10:00:00', 'Em Voo'),
(3, 3, 'BR303', 'Brasilia', 'Salvador', '2026-10-06 14:00:00', 'Concluido'),
(4, 4, 'BR404', 'Recife', 'Fortaleza', '2026-10-06 16:00:00', 'Cancelado'),
(5, 5, 'BR505', 'Rio de Janeiro', 'Manaus', '2026-10-07 20:00:00', 'Agendado');


INSERT INTO passagens
(voo_id, passageiro_id, assento, classe, valor)
VALUES
(1, 1, '12A', 'Economica', 450.00),
(2, 2, '05B', 'Executiva', 950.00),
(3, 3, '08C', 'Economica', 600.00),
(5, 4, '02A', 'Executiva', 1200.00),
(1, 5, '14D', 'Economica', 500.00);


SELECT
    v.numero_voo,
    v.origem,
    v.destino,
    a.modelo,
    p.nome AS piloto
FROM voos v
JOIN aeronaves a
    ON v.aeronave_id = a.id
JOIN pilotos p
    ON v.piloto_id = p.id
WHERE v.status IN ('Agendado', 'Em Voo');


SELECT
    classe,
    SUM(valor) AS total
FROM passagens
GROUP BY classe;


SELECT
    p.nome AS passageiro,
    v.numero_voo,
    pa.assento,
    pa.valor
FROM passagens pa
JOIN passageiros p
    ON pa.passageiro_id = p.id
JOIN voos v
    ON pa.voo_id = v.id
WHERE pa.classe = 'Executiva'
AND pa.valor > 800
ORDER BY pa.valor DESC;


CREATE VIEW vw_painel_aeroporto AS
SELECT
    v.numero_voo,
    v.data_hora,
    v.origem,
    v.destino,
    a.modelo,
    a.codigo_cauda,
    v.status
FROM voos v
JOIN aeronaves a
    ON v.aeronave_id = a.id;


CREATE VIEW vw_faturamento_por_voo AS
SELECT
    v.id AS voo_id,
    v.numero_voo,
    v.destino,
    COUNT(pa.id) AS quantidade_passageiros,
    COALESCE(SUM(pa.valor), 0) AS receita_total
FROM voos v
LEFT JOIN passagens pa
    ON v.id = pa.voo_id
GROUP BY v.id, v.numero_voo, v.destino;


SELECT * FROM vw_painel_aeroporto;


SELECT * FROM vw_faturamento_por_voo;

