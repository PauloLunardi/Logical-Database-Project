-- Criacao de uma nova base
CREATE SCHEMA manipulation;

select * from manipulation where TABLE_NAME = 'bank_accounts'

-- Criacao das tabela conta bancaria
CREATE TABLE bank_accounts(
	id_account INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	ag_num INT NOT NULL,
	ac_num INT NOT NULL,
	saldo DECIMAL(15,2) DEFAULT 0.00,
	CONSTRAINT identification_acccount_constraint UNIQUE (ag_num, ac_num)
	);

alter table manipulation.bank_accounts
	add  limite_credito DECIMAL(15,2) DEFAULT 500.00 not null;

-- Deixe o banco escolher o ID
INSERT INTO manipulation.bank_accounts (ag_num, ac_num, saldo) VALUES (1234, 56789, 0.00) RETURNING id_account;

select * from manipulation.bank_accounts ba 
 

-- Criacao das tabelas
CREATE TABLE bank_client(
    id_client INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_account INT UNIQUE, -- Garante que uma conta pertence a apenas um cliente
    cpf CHAR(11) NOT NULL UNIQUE, -- CPF deve ser único no sistema
    rg CHAR(9) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,    
    endereco VARCHAR(100) NOT NULL,
    renda_mensal DECIMAL(15,2) DEFAULT 0.00,
    
    CONSTRAINT fk_accounts_client 
    	FOREIGN KEY (client_account) 
        REFERENCES bank_accounts(id_account)
        ON UPDATE CASCADE
);

insert into manipulation.bank_client (client_account, cpf, rg, nome, endereco, renda_mensal) 
	values(1,'36228387832','450262877','Eliane','Rua Barao,77,Bela-Vista,Sao Paulo,SP',3250.00);

select * from manipulation.bank_client;


-- Criacao das tabelas
CREATE TABLE bank_transactions (
    id_transaction INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    
    -- Preenche automaticamente com data/hora do sistema
    ocorrencia TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, 
    status_transaction VARCHAR(20) NOT NULL,
    valor_transferido DECIMAL(15,2) NOT NULL CHECK (valor_transferido > 0),
    source_account INT,
    destination_account INT NOT NULL,
    
    -- Constraint da conta de ORIGEM
    CONSTRAINT fk_source_transaction
        FOREIGN KEY (source_account) 
        REFERENCES bank_accounts(id_account)
        ON UPDATE CASCADE,

    -- Constraint da conta de DESTINO
    CONSTRAINT fk_destination_account
        FOREIGN KEY (destination_account) 
        REFERENCES bank_accounts(id_account)
    

select * from manipulation.bank_transactions;
select * from manipulation.bank_accounts;


SELECT c.nome, a.ag_num, a.ac_num, a.saldo, a.limite_credito
	FROM manipulation.bank_client c
	JOIN manipulation.bank_accounts a ON c.client_account = a.id_account;


-- Inserindo dados na Bank_accounts
-- Gerando as contas (IDs 2, 3, 4, 5 e 6 - já que a Eliane é a 1)
INSERT INTO manipulation.bank_accounts (ag_num, ac_num, saldo, limite_credito) VALUES 
(1234, 10001, 1500.50, 1000.00),
(1234, 10002, 50.00, 500.00),
(5555, 20001, 12000.00, 5000.00),
(5555, 20002, 0.00, 200.00),
(8888, 30001, 450.25, 800.00);


-- Inserindo dados na client_accounts
INSERT INTO manipulation.bank_client (client_account, cpf, rg, nome, endereco, renda_mensal) VALUES 
(2, '11122233344', '123456781', 'Ricardo Silva', 'Av. Paulista, 1000, SP', 4500.00),
(3, '22233344455', '876543212', 'Mariana Costa', 'Rua das Flores, 50, MG', 2800.00),
(4, '33344455566', '112233443', 'Carlos Souza', 'Rua Chile, 5, BA', 15000.00),
(5, '44455566677', '556677884', 'Juliana Lima', 'Rua da Paz, 300, RJ', 1900.00),
(6, '55566677788', '990011225', 'Bruno Gomes', 'Av. Batel, 1550, PR', 3100.00);

select * from bank_accounts;
select * from bank_client;
select * from bank_transactions;
