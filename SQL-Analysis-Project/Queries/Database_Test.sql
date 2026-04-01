-- Linguagem de modelagem de dados em Postgre SQL

-- ** 1. Criando type, no Postgres, você precisa criar o tipo ENUM primeiro

	CREATE TYPE gender_type AS ENUM ('M', 'F');

-- ** 2. Criar a tabela ajustada para o postgresql

	CREATE TABLE person (
		person_id smallint, -- Removido 'unsigned' (Postgres não usa)
		fname varchar(50),  -- Aumentei para 50 (20 é muito pouco para nomes)
		lname varchar(50),
		gender gender_type, -- Usa o tipo criado acima
		birth_date DATE,
		street varchar(100),
		city varchar(50),
		state varchar(50),
		country varchar(50),
		postal_code varchar(20),
		constraint pk_person primary key (person_id) -- Removida a vírgula extra aqui
	);
	
-- ** 3. Criar outa tabela linkada pela constrain

	CREATE TABLE favorite_food(
		person_id smallint,
		food varchar(20),
		constraint pk_favorite_food primary key (person_id, food),
		constraint fk_favorite_food_person_id foreign key (person_id)
		references person(person_id)
	);
	
	
select * from favorite_food;

select * from information_schema.table_constraints
	where constraint_schema = 'DataBase_Bootcamp';
	
	
-- Inserindo dados na tabela person
insert into person values('1','Carolina','Silva','F','1979-03-19',
							'Rua tal','Cidade J','26038-86');

insert into person values('2','Joao','Bastiao','M','1979-01-09',
							'Rua tap','Cidade P','26138-67');

insert into person values('3','Rogeria','Camargo','F','1979-03-28',
							'Rua tik','Cidade J','26438-53');

insert into person values('4','Erica','Boing Boing','F','1979-02-27',
							'Rua tek','Cidade L','22938-12');

insert into person values('5','Bruna','Surfistinha','F','1979-08-12',
							'Rua tak','Cidade F','22088-23');

insert into person values('6','Carol','Surfistinha','F','1979-10-21',
							'Rua tak','Cidade F','22088-23');

select * from person;



