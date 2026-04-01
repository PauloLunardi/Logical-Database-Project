-- ** Criacao Banco Company usando o DBeaver/ PostgreQLS conectando a uma database conectada ao Neon
-- 
-- Inserte de dados nas tabelas criadas.
-- Observacao nos ajustes das FKs em update cascade (reveja esta parte para evitar ajustes depois) (linha207)
create schema  if not exists company;

-- Criando Tabela Funcionarios
create table company.employee(
	Fname varchar(50) not null,
	Minit char,
	Lname varchar(50) not null,
	Ssn char(9),
	Sex genders_type, -- Usa o tipo criado acima
	B_date DATE,
	Address varchar(100),
	City varchar(50),
	State varchar(50),
	Country varchar(50),
	Postal_code varchar(20),
	Salary decimal(10,2),
	Super_ssn char(9),
	Dno int not null,
	primary key (Ssn)
	);



-- Criando Tabela Departamentos
-- Procura schemas criados na base
select * from information_schema.schemata;


select table_name
	from information_schema.company.employee tables
	where ;


-- Lista todas as tabelas criadas nos schemas
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_schema NOT IN ('information_schema', 'pg_catalog') 
ORDER BY table_schema, table_name;

 -- Para verificar campos da tabela, so que nao funciona no DBeaver
\d public.dept_locations; 


-- Procurando os campos com SQL puro com campos
select
	column_name as coluna,
	data_type as tipo,
	is_nullable as aceita_nulo,
	column_default as valor_padrao
from  information_schema.columns
where table_name = 'dept_locations'
order by ordinal_position ;


-- Procurando os campos com SQL tudo
select
	*
from  information_schema.columns
where table_name = 'works_on'
order by ordinal_position ;

select * from company.employee e;
select * from public.department d;


-- Deletando uma tabela( O cascade permite remover string estrangeira de outra tabela)
-- Porem o campo ainda existira em outra tabela;
drop table public.department cascade;
drop table public.dept_locations cascade;



-- Criando Tabela Departamentos agora para o schema correto
create table department (
    Dname varchar(30) not null,
    Dnumber int not null,
    Mgr_ssn char(9),
    Mgr_start_date date,
    primary key (Dnumber),
    unique (Dname),
    -- Remova as aspas do banco e verifique se o schema é 'public'
    foreign key (Mgr_ssn) references company.employee (Ssn) 
);


-- Criando Tabela Dept_locations no schema correto
create table dept_locations(
	Dnumber int not null,
	Dlocation varchar(30),
	primary key (Dnumber, Dlocation),
	foreign key (Dnumber) references company.department(Dnumber)
);

-- Criando a Tabela do Projeto
CREATE TABLE project (
    pname varchar(30) not null,
    pnumber int not null,
    plocation varchar(30),
    dnum int not null, -- A COLUNA PRECISA SER DECLARADA AQUI
    
    -- Definindo a Primary Key composta com as colunas que você declarou acima
    PRIMARY KEY (pnumber, dnum), 
    
    UNIQUE (pname),
    
    -- A Foreign Key deve usar o nome EXATO da coluna declarada (dnum)
    CONSTRAINT fk_project_dept 
        FOREIGN KEY (dnum) 
        REFERENCES company.department(dnumber)
);



select * from company.employee;
drop table company.project;


-- Criando tabela Works_on
CREATE TABLE works_on (
    essn char(9) not null,
    pno int not null,
    dnum int not null, -- VOCÊ PRECISA ADICIONAR ESTA COLUNA AQUI
    hours decimal(3,1) not null,
    
    PRIMARY KEY (essn, pno),
    
    -- Referência para Employee
    FOREIGN KEY (essn) REFERENCES company.employee(ssn),
        
    -- Referência para Project (precisa dos dois campos para casar com a PK de project)
    FOREIGN KEY (pno, dnum) REFERENCES company.project(pnumber, dnum)
);

-- Criando a tabela dependente
create table dependent(
	essn char(9) not null,
	dependent_name varchar(30) not null,
	sex gender_type, -- conforme ja criado no inicio
	bdate date,
	relationship varchar(8),
	primary key (essn, dependent_name),
	foreign key (essn) references company.employee (ssn)
);


-- Verificando as tabelas criadas no Schema
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'company' 
  AND table_type = 'BASE TABLE';



-- Adicionando um campo na tabela employee

ALTER TABLE company.employee 
ADD CONSTRAINT chk_salary_minimo CHECK (salary > 2000.0);


SELECT 
    constraint_name, 
    constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'employee' 
  AND table_schema = 'company';

select * from information_schema.table_constraints tc
	where table_name = 'employee';


-- Adicionando uma regra
-- considerando uma regra de banco que diz que a data da entrada do gerente nao pode ser maior que a data de criacao do banco
ALTER TABLE company.employee 
    ADD COLUMN dnumber INT,
    ADD COLUMN dname VARCHAR(50),
    ADD COLUMN mgr_start_date DATE,
    ADD COLUMN dept_create_date DATE,
    -- Regras de Negócio (Constraints)
    ADD CONSTRAINT unique_dnumber UNIQUE (dnumber), -- Garante que dnumber não se repita
    ADD CONSTRAINT unique_name_dept UNIQUE (dname), -- Garante que dname não se repita
    ADD CONSTRAINT chk_date_dept CHECK (dept_create_date <= mgr_start_date); -- Regra das datas


select table_name from company;

-- Adiconando uma constraint na tabela ja criada anteriormente
ALTER TABLE company.project 
    ADD CONSTRAINT unique_project unique (pname);

ALTER TABLE company.project 
    ADD CONSTRAINT fk_project_dnum foreign key (dnum) references department (dnumber);

ALTER TABLE company.works_on  
    ADD CONSTRAINT fk_works_on_essn foreign key (essn) references employee (ssn),
	ADD CONSTRAINT fk_works_on_pno foreign key (pno, dnum) references project (pnumber, dnum);


ALTER TABLE company.dependent
    ADD COLUMN age INT NOT NULL,
    ADD CONSTRAINT chk_age_dependent CHECK (age < 22),
    ADD CONSTRAINT fk_dependent FOREIGN KEY (essn) REFERENCES company.employee (ssn);


-- Realizando update modo cascade
-- precisa remover as pks porque eu esqueci de adicionar
-- 1. Remove a regra "travada" que você criou antes

ALTER TABLE company.dependent  DROP CONSTRAINT fk_dependent;

ALTER TABLE company.dependent
ADD CONSTRAINT fk_dependent FOREIGN KEY (essn) REFERENCES company.employee (ssn)
ON UPDATE CASCADE ;


ALTER TABLE company.works_on DROP CONSTRAINT fk_works_on_essn;
ALTER TABLE company.works_on DROP CONSTRAINT fk_works_on_pno;

ALTER TABLE company.works_on
ADD CONSTRAINT fk_works_on_essn FOREIGN KEY (essn) REFERENCES company.employee (ssn),
ADD CONSTRAINT fk_works_on_pno FOREIGN KEY (pno, dnum) REFERENCES company.project (pnumber, dnum)
ON UPDATE CASCADE;


ALTER TABLE company.project DROP CONSTRAINT fk_project_dnum;

ALTER TABLE company.project  
ADD CONSTRAINT fk_project_dnum FOREIGN KEY (dnum) REFERENCES department (dnumber)
ON UPDATE CASCADE ;

******

--ALTER TABLE company.department  DROP CONSTRAINT fk_xxx;

ALTER TABLE company.department
ADD CONSTRAINT fk_dept FOREIGN KEY (mgr_ssn) REFERENCES employee (ssn)
ON UPDATE CASCADE ;

******

--ALTER TABLE company.dept_locations  DROP CONSTRAINT fk_xxx;

ALTER TABLE company.dept_locations
ADD CONSTRAINT fk_dept_locations FOREIGN KEY (dnumber) REFERENCES department (dnumber)
ON UPDATE CASCADE ;



********************************************************
********************************************************

-- Verificacao da tabela e Insercao dos dados (Insert)
-- Verificando as tabelas no schema
SELECT * 
FROM information_schema.tables
WHERE table_schema = 'company' 
  --AND table_type = 'BASE TABLE';

-- Verificando as tabelas
SELECT * 
FROM company.employee e
--WHERE table_schema = 'company' 
  --AND table_type = 'BASE TABLE';

-- inserindo dados na tabela employee
INSERT INTO company.employee VALUES (
    'Jhon', 'B', 'Smith', '123456789', 'M', '1988-06-12', 
    'Rua_Sao_Domingos-731-Bela_Vista', 'Sao Paulo', 'Sao Paulo', 
    'Brasil', '01264-837', 3000.00, NULL, 1
);

-- 1. Funcionário com Supervisor (Dno 1)

INSERT INTO company.employee VALUES (
    'Alice', 'M', 'Oliveira', '987654321', 'F', '1992-03-25', 
    'Av_Paulista-1500-Bela_Vista', 'Sao Paulo', 'Sao Paulo', 
    'Brasil', '01310-200', 4500.00, '123456789', 1
);

-- 2. Funcionario de outro departamento
INSERT INTO company.employee VALUES (
    'Carlos', 'A', 'Souza', '456123789', 'M', '1985-11-02', 
    'Rua_das_Flores-12-Centro', 'Curitiba', 'Parana', 
    'Brasil', '80010-000', 3800.50, NULL, 2
);


-- Mais opcoes de insert
INSERT INTO company.employee VALUES ('Ricardo', 'A', 'Almeida', '111222333', 'M', '1980-01-15', 'Rua Amazonas, 10', 'Belo Horizonte', 'Minas Gerais', 'Brasil', '30110-010', 7500.00, NULL, 1);
INSERT INTO company.employee VALUES ('Mariana', 'C', 'Costa', '222333444', 'F', '1990-05-20', 'Rua das Flores, 50', 'Contagem', 'Minas Gerais', 'Brasil', '32000-000', 4200.00, '111222333', 1);
INSERT INTO company.employee VALUES ('Roberto', 'S', 'Silva', '333444555', 'M', '1985-08-12', 'Av. Central, 100', 'Belo Horizonte', 'Minas Gerais', 'Brasil', '30150-200', 3900.00, '111222333', 1);
INSERT INTO company.employee VALUES ('Fernanda', 'R', 'Rocha', '444555666', 'F', '1993-11-30', 'Rua Piauí, 22', 'Belo Horizonte', 'Minas Gerais', 'Brasil', '30130-050', 3100.00, '111222333', 1);
-- Departamento 2
INSERT INTO company.employee VALUES ('Lucas', 'M', 'Mendes', '555666777', 'M', '1982-04-10', 'Rua da Paz, 300', 'Rio de Janeiro', 'Rio de Janeiro', 'Brasil', '20010-000', 8200.00, NULL, 2);
INSERT INTO company.employee VALUES ('Juliana', 'F', 'Ferreira', '666777888', 'F', '1988-09-05', 'Av. Brasil, 4500', 'Rio de Janeiro', 'Rio de Janeiro', 'Brasil', '21040-361', 5000.00, '555666777', 2);
INSERT INTO company.employee VALUES ('Andre', 'P', 'Pereira', '777888999', 'M', '1991-02-28', 'Rua do Ouvidor, 15', 'Rio de Janeiro', 'Rio de Janeiro', 'Brasil', '20040-030', 4800.00, '555666777', 2);
INSERT INTO company.employee VALUES ('Camila', 'G', 'Gomes', '888999000', 'F', '1994-06-14', 'Rua Ipanema, 101', 'Rio de Janeiro', 'Rio de Janeiro', 'Brasil', '22410-000', 4600.00, '555666777', 2);
-- Departamento 3
INSERT INTO company.employee VALUES ('Marcos', 'E', 'Evangelista', '121212343', 'M', '1979-12-25', 'Rua da Lapa, 99', 'Salvador', 'Bahia', 'Brasil', '40040-000', 9000.00, NULL, 3);
INSERT INTO company.employee VALUES ('Sofia', 'D', 'Duarte', '343434565', 'F', '1996-01-10', 'Av. Sete de Setembro, 20', 'Salvador', 'Bahia', 'Brasil', '40060-001', 3200.00, '121212343', 3);
INSERT INTO company.employee VALUES ('Tiago', 'H', 'Henrique', '565656787', 'M', '1987-03-18', 'Rua Chile, 5', 'Salvador', 'Bahia', 'Brasil', '40020-000', 3400.00, '121212343', 3);
-- Departamento 4
INSERT INTO company.employee VALUES ('Patricia', 'K', 'Klein', '989898121', 'F', '1983-07-22', 'Rua Independencia, 88', 'Porto Alegre', 'Rio Grande do Sul', 'Brasil', '90010-001', 6700.00, NULL, 4);
INSERT INTO company.employee VALUES ('Gustavo', 'B', 'Borges', '767676434', 'M', '1992-10-05', 'Av. Farrapos, 1200', 'Porto Alegre', 'Rio Grande do Sul', 'Brasil', '90220-002', 2900.00, '989898121', 4);
INSERT INTO company.employee VALUES ('Aline', 'V', 'Vieira', '545454989', 'F', '1995-12-12', 'Rua dos Andradas, 500', 'Porto Alegre', 'Rio Grande do Sul', 'Brasil', '90020-000', 2850.00, '989898121', 4);
-- Departamento 5
INSERT INTO company.employee VALUES ('Daniel', 'J', 'Junior', '101010202', 'M', '1975-05-30', 'Rua XV de Novembro, 200', 'Curitiba', 'Parana', 'Brasil', '80020-310', 11000.00, NULL, 5);
INSERT INTO company.employee VALUES ('Larissa', 'O', 'Oliveira', '202020303', 'F', '1998-02-14', 'Rua das Araucarias, 44', 'Curitiba', 'Parana', 'Brasil', '80240-000', 2500.00, '101010202', 5);
INSERT INTO company.employee VALUES ('Bruno', 'W', 'Wilson', '303030404', 'M', '1991-06-22', 'Av. Batel, 1550', 'Curitiba', 'Parana', 'Brasil', '80420-000', 4100.00, '101010202', 5);
-- Adicionais Aleatórios
INSERT INTO company.employee VALUES ('Helena', 'T', 'Teixeira', '404040505', 'F', '1989-08-08', 'Rua Goias, 12', 'Goiania', 'Goias', 'Brasil', '74000-000', 5500.00, NULL, 3);
INSERT INTO company.employee VALUES ('Fabio', 'I', 'Inacio', '505050606', 'M', '1992-04-04', 'Rua das Palmeiras, 9', 'Vitoria', 'Espirito Santo', 'Brasil', '29000-000', 4300.00, NULL, 2);
INSERT INTO company.employee VALUES ('Renata', 'Q', 'Queiroz', '606060707', 'F', '1986-09-17', 'Av. Boa Viagem, 1000', 'Recife', 'Pernambuco', 'Brasil', '51011-000', 6200.00, NULL, 4);



-- inserindo dados na tabela employee
-- Dependentes do Ricardo (SSN 111222333)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('111222333', 'Lucas Almeida', 'M', '2015-03-10', 'Filho', 11);

INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('111222333', 'Fernanda Almeida', 'F', '2018-06-20', 'Filha', 7);

-- Dependentes da Mariana (SSN 222333444)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('222333444', 'Tiago Costa', 'M', '2020-01-15', 'Filho', 6);

-- Dependentes do Lucas (SSN 555666777)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('555666777', 'Ana Mendes', 'F', '2005-11-30', 'Filha', 20);

-- Dependentes do Marcos (SSN 121212343)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('121212343', 'Pedro Evangelista', 'M', '2022-05-05', 'Filho', 3);

-- Dependente da Patricia (SSN 989898121)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('989898121', 'Julia Klein', 'F', '2010-08-12', 'Filha', 15);

-- Dependente do Daniel (SSN 101010202)
INSERT INTO company.dependent (essn, dependent_name, sex, bdate, relationship, age) 
VALUES ('101010202', 'Alice Junior', 'F', '2013-09-25', 'Filha', 12);


-- Inserindo os dados da tabela department
-- Departamento 1: Sede (Gerente: Ricardo Almeida)
INSERT INTO company.department VALUES ('Sede', 1, '111222333', '2020-01-01');

-- Departamento 2: Vendas (Gerente: Lucas Mendes)
INSERT INTO company.department VALUES ('Vendas', 2, '555666777', '2021-03-15');

-- Departamento 3: Marketing (Gerente: Marcos Evangelista)
INSERT INTO company.department VALUES ('Marketing', 3, '121212343', '2019-11-20');

-- Departamento 4: Recursos Humanos (Gerente: Patricia Klein)
INSERT INTO company.department VALUES ('Recursos Humanos', 4, '989898121', '2022-05-10');

-- Departamento 5: TI (Gerente: Daniel Junior)
INSERT INTO company.department VALUES ('TI', 5, '101010202', '2018-06-01');

-- Departamento 6: Juridico (Gerente: Fabio Inacio - SSN do lote anterior)
INSERT INTO company.department VALUES ('Juridico', 6, '505050606', '2023-01-10');

-- Departamento 7: Logistica (Gerente: Renata Queiroz - SSN do lote anterior)
INSERT INTO company.department VALUES ('Logistica', 7, '606060707', '2022-08-15');

-- Departamento 8: Pesquisa e Desenvolvimento (Gerente: Alice Oliveira)
INSERT INTO company.department VALUES ('Pesquisa e Desenvolvimento', 8, '987654321', '2021-12-01');

-- Departamento 9: Financeiro (Gerente: Carlos Souza)
INSERT INTO company.department VALUES ('Financeiro', 9, '456123789', '2020-10-25');

-- Departamento 10: Suporte Tecnico (Gerente: Jhon Smith - O primeiro que criamos)
INSERT INTO company.department VALUES ('Suporte Tecnico', 10, '123456789', '2023-06-01');


-- Inserindo valores na tabela dept_locations
-- Departamento 1 (Sede) em múltiplas cidades
INSERT INTO company.dept_locations VALUES (1, 'Belo Horizonte');
INSERT INTO company.dept_locations VALUES (1, 'Sao Paulo');

-- Departamento 2 (Vendas)
INSERT INTO company.dept_locations VALUES (2, 'Rio de Janeiro');
INSERT INTO company.dept_locations VALUES (2, 'Niteroi');

-- Departamento 3 (Marketing)
INSERT INTO company.dept_locations VALUES (3, 'Salvador');
INSERT INTO company.dept_locations VALUES (3, 'Goiania');

-- Departamento 4 (Recursos Humanos)
INSERT INTO company.dept_locations VALUES (4, 'Porto Alegre');
INSERT INTO company.dept_locations VALUES (4, 'Recife');

-- Departamento 5 (TI)
INSERT INTO company.dept_locations VALUES (5, 'Curitiba');
INSERT INTO company.dept_locations VALUES (5, 'Florianopolis');

-- Departamento 6 (Juridico)
INSERT INTO company.dept_locations VALUES (6, 'Vitoria');

-- Departamento 7 (Logistica)
INSERT INTO company.dept_locations VALUES (7, 'Recife');

-- Departamento 8 (P&D)
INSERT INTO company.dept_locations VALUES (8, 'Campinas');

-- Departamento 9 (Financeiro)
INSERT INTO company.dept_locations VALUES (9, 'Curitiba');

-- Departamento 10 (Suporte Tecnico)
INSERT INTO company.dept_locations VALUES (10, 'Sao Paulo');

-- Inserindo dados na tabela Projects
-- Projetos do Departamento 1 (Sede)
INSERT INTO company.project VALUES ('Reorganizacao Geral', 101, 'Belo Horizonte', 1);
INSERT INTO company.project VALUES ('Expansao Sudeste', 102, 'Sao Paulo', 1);

-- Projetos do Departamento 2 (Vendas)
INSERT INTO company.project VALUES ('Novo Portal CRM', 201, 'Rio de Janeiro', 2);
INSERT INTO company.project VALUES ('Campanha Verao', 202, 'Niteroi', 2);

-- Projetos do Departamento 3 (Marketing)
INSERT INTO company.project VALUES ('Redes Sociais 2024', 301, 'Salvador', 3);

-- Projetos do Departamento 4 (Recursos Humanos)
INSERT INTO company.project VALUES ('Treinamento Lideranca', 401, 'Porto Alegre', 4);

-- Projetos do Departamento 5 (TI)
INSERT INTO company.project VALUES ('Migracao Nuvem', 501, 'Curitiba', 5);
INSERT INTO company.project VALUES ('Seguranca de Dados', 502, 'Florianopolis', 5);

-- Projetos do Departamento 6 (Juridico)
INSERT INTO company.project VALUES ('Auditoria Compliance', 601, 'Vitoria', 6);

-- Projetos do Departamento 7 (Logistica)
INSERT INTO company.project VALUES ('Otimizacao de Rotas', 701, 'Recife', 7);

-- Projetos do Departamento 8 (P&D)
INSERT INTO company.project VALUES ('Novo Produto X', 801, 'Campinas', 8);

-- Projetos do Departamento 9 (Financeiro)
INSERT INTO company.project VALUES ('Reducao de Custos', 901, 'Curitiba', 9);

-- Projetos do Departamento 10 (Suporte Tecnico)
INSERT INTO company.project VALUES ('Autoatendimento IA', 1001, 'Sao Paulo', 10);

-- Inserindo dados na tabela works_on
-- -- Alocando funcionários ao Projeto 101 (Depto 1 - Reorganização Geral)
INSERT INTO company.works_on VALUES ('111222333', 101, 1, 10.5); -- Ricardo
INSERT INTO company.works_on VALUES ('222333444', 101, 1, 20.0); -- Mariana

-- Alocando funcionários ao Projeto 102 (Depto 1 - Expansão Sudeste)
INSERT INTO company.works_on VALUES ('333444555', 102, 1, 15.0); -- Roberto
INSERT INTO company.works_on VALUES ('123456789', 102, 1, 05.0); -- Jhon

-- Alocando funcionários ao Projeto 201 (Depto 2 - Novo Portal CRM)
INSERT INTO company.works_on VALUES ('555666777', 201, 2, 08.0); -- Lucas
INSERT INTO company.works_on VALUES ('666777888', 201, 2, 40.0); -- Juliana

-- Alocando funcionários ao Projeto 501 (Depto 5 - Migração Nuvem)
INSERT INTO company.works_on VALUES ('101010202', 501, 5, 12.5); -- Daniel
INSERT INTO company.works_on VALUES ('303030404', 501, 5, 35.0); -- Bruno

-- Alocando funcionários ao Projeto 901 (Depto 9 - Redução de Custos)
INSERT INTO company.works_on VALUES ('456123789', 901, 9, 10.0); -- Carlos
INSERT INTO company.works_on VALUES ('606060707', 901, 9, 05.5); -- Renata

-- Um funcionário trabalhando em dois projetos diferentes (Alice)
INSERT INTO company.works_on VALUES ('987654321', 801, 8, 25.0); -- No Projeto 801 (Depto 8)
INSERT INTO company.works_on VALUES ('987654321', 101, 1, 10.0); -- No Projeto 101 (Depto 1)

-- Alocando Beatriz ao Projeto 101
INSERT INTO company.works_on VALUES ('741852963', 101, 1, 15.0);

*********************
select * from company.employee;
select * from company.department d;
select * from company.dependent d;
select * from company.project p;
select * from company.works_on w;

-- Analisando o gerente e seu d	epartamento
SELECT d.dname, e.ssn, e.fname, e.lname from company.employee e , department d where (e.ssn = d.mgr_ssn);

-- Analisando dependentes de empregados
SELECT e.fname, d.dependent_name, d.relationship  from company.employee e, dependent d where (d.essn = e.ssn);

-- Analisando uma pessoa pelo nome
SELECT b_date, address from company.employee e
	where fname = 'Jhon' and minit ='B' and lname = 'Smith';

-- Analisando um departamento especifico
SELECT * from company.department d 
	where dname = 'Vendas';

SELECT e.fname, e.lname, e.address from company.employee e, department d 
	where d.dname = 'Vendas' and (d.dnumber = e.dno);

SELECT p.pname, w.essn, e.fname, w.hours from company.project p, company.works_on w, company.employee e
	where (p.pnumber = w.pno) and (w.essn = e.ssn);


-- Concatenando 2 colunas de adiconando outro nome na coluna
SELECT 
    fname, 
    minit, 
    lname || ', ' || state AS completname 
FROM company.employee;

-- Schema Company
-- Exemplo de calculo no select - Schema Company
select fname, lname, salary, salary * 0.011 from employee;
select fname, lname, salary, salary * 0.011  as INSS from employee;
select fname, lname, salary, round(salary * 0.011,2) from employee;


-- Schema Company
-- Exemplo de alteracao em colunas com condicional
select *
	from employee e , works_on w, project p 
	where (e.ssn = w.essn and w.pno = p.pnumber);

select concat(fname, ' ', lname) complet_name, p.pname, e.salary, e.salary * 1.1 as increased_salary
	from employee e, works_on w, project p
	where (e.ssn = w.essn) 
	and (w.pno = p.pnumber)
	and (p.pname = 'Reorganizacao Geral');
	-- and (e.ssn = '111222333');



select concat(fname, ' ', lname) complet_name, 
	p.pname, 
	e.salary as original_salary,
	-- calculo do novo salario
	round(e.salary * 1.10,2) as increased_salary,
	-- calculo da diferenca salarial
	round((e.salary * 1.10) - e.salary, 2) as diference_value,
	-- Calculo da variacao em porcentagem
	round((((e.salary * 1.10) - e.salary) / e.salary) * 100,2) || '%' as percentage_increase
	
	from company.employee e
		join works_on w
			on (e.ssn = w.essn)
		join company.project p
			on (w.pno = p.pnumber)
		where (e.salary > 3000)
		-- and (p.pname = 'Reorganizacao Geral');
		-- and (e.ssn = '111222333');
	
select * from employee e;
select * from works_on w;
select * from project p;		


***********************************************************************
-- Fazendo analises dos dados no banco

SELECT *
FROM information_schema.columns
WHERE table_name = 'dept_locations';

select * from dept_locations dl;
select * from department d;
select * from employee e;
select * from project p;
select * from works_on wo;

-- Recuperando informacoes dos departamentos presente em uma cidade
select d.dname as Department_Name, d.mgr_ssn as Manager, e.address from department d, dept_locations dl, employee e
	where d.dnumber = dl.dnumber and dl.dlocation  = 'Sao Paulo';

-- Recuperando informacoes
select d.dname as Department_Name, concat(e.fname, ' ', e.lname) as Manager_Name, d.mgr_ssn as Manager_Code, e.address from department d, dept_locations dl, employee e
	where d.dnumber = dl.dnumber and dl.dlocation  = 'Sao Paulo'
		and d.mgr_ssn = e.ssn;

-- Recuperando dados referentes aos gerentes e projetos
select  p.pnumber as Project_Number,
		p.pname as Project_Name,
		d.dname as Department,
		p.dnum as Department_Number,
		concat(fname, ' ',lname) as Manager, 
		e.b_date,
		address as Address
	from department d,
		project p,
		employee e
	where d.dnumber = p.dnum 
		and p.plocation  = 'Sao Paulo'
		and mgr_ssn = e.ssn;

-- operando analises com LIKE e BETWEEN	
-- Like
select concat(e.fname, ' ', e.lname) as Complete_Name,
		d.dname as Department_Name,
		d.dnumber as Department_Number,
		e.address 
	from employee e,
		department d
	where (e.dno = d.dnumber)
		and  (e.address ilike '%Rua%');


-- Between (Veja a diferenca)
select fname, lname from employee e
	where (e.salary > 3000 and e.salary < 4000);

select fname, lname from employee e
	where e.salary between 3000 and 4000;

-- Union / Intersection / Except

-- Union
select distinct p.pnumber, p.pname
	from project p, department d, employee e
		where p.dnum = d.dnumber 	
			and d.mgr_ssn = e.ssn 
			and e.lname = 'Oliveira'
UNION 

select distinct p.pnumber, p.pname 
	from project p, works_on w, employee e
	where p.pnumber = w.pno 
		and w.essn = e.ssn
		and e.lname = 'Oliveira';



*************************************************************************

-- Order By e Group By


select * from dept_locations dl;
select * from department d;
select * from employee e;
select * from project p;
select * from works_on wo;

select fname, lname, city, state
	from employee
	order by state desc;

select city, state, count(*) as registros
	from employee
	group by state, city
	order by state desc;

-------------------------------------------------------------
-- Case When

-- Usando Case when para criar atributos
select fname, lname, city, state, 
case
	when (salary < 1500) then 'Min Salary'
	when (salary >= 1500 and salary < 3000) then 'Mid Salary'
	when (salary >= 3000 and salary < 4500) then 'Senior Salary'
	when (salary >= 4500) then 'High Salary'
end as Salary_Range
	from employee
	order by city asc, state desc;

-- agora vamos somar as pessoas dessas faixas salariais
select -- fname, lname, city, 
	state, 
case
	when (salary < 1500) then 'Min Salary'
	when (salary >= 1500 and salary < 3000) then 'Mid Salary'
	when (salary >= 3000 and salary < 4500) then 'Senior Salary'
	when (salary >= 4500) then 'High Salary'
end as Salary_Range,
count(*) as total_por_faixa
	from employee
	group by salary_range, state
	order by state asc, salary_range desc, total_por_faixa desc;

-- analisando a soma de salarios por atributos definidos em colunas ao inves do campo, como no modelo acima
select state,
	SUM(case when salary >= 3000 then salary else 0 end) as Senior_payrol,
	SUM(case when salary < 3000 then salary else 0 end) as Junior_payrol
from employee 
group by state 
order by state asc;

-- Analisando os salarios e quebrando por pessoa(fname)
-- ** Podemos ver o total de SP = 12700, e a soma do senior payrol de Alice, Beatriz e Jhon
select fname, state,
	SUM(case when salary >= 3000 then salary else 0 end) as Senior_payrol,
	SUM(case when salary < 3000 then salary else 0 end) as Junior_payrol
from employee 
group by fname,state 
order by fname, state asc;











