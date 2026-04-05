-- *********************************************************************************************
-- Estou utilizando o postgreSQL ao invés do MySQL.

-- Criando os tipos 
-- Criando os tipos ENUM primeiro (boa prática para evitar erros de dependência)
CREATE TYPE category_type AS ENUM ('eletro', 'vestimenta', 'brinquedos', 'alimentos', 'moveis');
CREATE TYPE status_type AS ENUM ('Cancelado', 'Confirmado', 'Em processamento');
CREATE TYPE payment_type AS ENUM ('Boleto', 'Credito', 'Debito', 'PIX');
CREATE TYPE po_status_type AS ENUM ('Disponivel', 'Sem Estoque');
CREATE TYPE location_type AS ENUM ('CD', 'Loja', 'Hub');

-- *********************************************************************************************
-- Criando as tabelas

-- Tabela Cliente
CREATE TABLE client (
    id_client int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fname varchar(15) NOT NULL, 
    minit char(1),
    lname varchar(15) NOT NULL,
    cpf varchar(11) NOT NULL,
    address_street varchar(30),
    address_number varchar(10),
    address_city varchar(30),
    address_state char(2),
    CONSTRAINT unique_cpf_client UNIQUE(cpf),
    CONSTRAINT chk_cpf_format CHECK (cpf ~ '^[0-9]{11}$')
);

-- Tabela Produto
CREATE TABLE product (
    id_product int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name varchar(30) NOT NULL UNIQUE,
    classification_kids BOOLEAN DEFAULT false,
    category category_type NOT NULL,
    avaliacao numeric(3,2) DEFAULT 0,
    size varchar(10)
);

-- Tabela Pagamento
CREATE TABLE payment (
    id_client int NOT NULL,
    id_payment int GENERATED ALWAYS AS IDENTITY,
    type_payment payment_type NOT NULL,
    limit_available numeric(10,2) DEFAULT 0,
    PRIMARY KEY (id_client, id_payment),
    CONSTRAINT fk_payment_client FOREIGN KEY (id_client) REFERENCES client(id_client) ON DELETE CASCADE
    -- se o cliente for excluido os pagamentos tbm serao
);

-- Tabela Pedido
CREATE TABLE purchase_order (
    id_order int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_client int NOT NULL,
    order_status status_type NOT NULL DEFAULT 'Em processamento',
    order_description varchar(260),
    send_value numeric(10,2) DEFAULT 10, 
    payment_cash BOOLEAN DEFAULT false,
    CONSTRAINT fk_orders_client FOREIGN KEY (id_client) REFERENCES client(id_client) ON DELETE CASCADE
    -- qnd cliente apagado, os pedidos serao deletados
);

-- Tabela Fornecedor
CREATE TABLE supplier (
    id_supplier int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    social_name varchar(255) NOT NULL,
    cnpj_supplier varchar(14) NOT NULL,
    contact_supplier varchar(15) NOT NULL,
    supplier_location_street varchar(30),
    supplier_location_number varchar(10),
    supplier_location_city varchar(30),
    supplier_location_state char(2),
    CONSTRAINT unique_supplier unique (cnpj_supplier),
    CONSTRAINT chk_cnpj_supplier CHECK (cnpj_supplier ~ '^[0-9]{14}$')
);

-- Tabela Localizacao do estoque
CREATE TABLE storage_location(
    id_location int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    storage_name varchar(50) NOT NULL,
    storage_type location_type NOT NULL DEFAULT 'CD',
    street varchar(30),
    number varchar(10),
    city varchar(30),
    state char(2),
    CONSTRAINT unique_storage_location UNIQUE (storage_name, city, state),
);

-- Tabela produto em estoque
CREATE TABLE product_storage(
    id_product_storage int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_product int NOT NULL,
    id_location int NOT NULL,
    quantity int NOT NULL DEFAULT 0,
    CONSTRAINT fk_storage_product FOREIGN KEY (id_product) REFERENCES product(id_product) ON DELETE CASCADE,
    CONSTRAINT fk_storage_location FOREIGN KEY (id_location) REFERENCES storage_location(id_location) ON DELETE CASCADE,
    CONSTRAINT unique_product_storage UNIQUE (id_product, id_location),
    CONSTRAINT chk_product_storage CHECK (quantity >= 0)
);

-- Tabela vendedor
CREATE TABLE seller(
    id_seller int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_social_name varchar(255) NOT NULL,
    abbrev_name varchar(255),
    cnpj_seller varchar(14),
    cpf_seller varchar(11),
    contact_seller varchar(15) NOT NULL,
    seller_location_street varchar(30) NOT NULL,
    seller_location_number varchar(10) NOT NULL,
    seller_location_city varchar(30) NOT NULL,
    seller_location_state char(2) NOT NULL,
    CONSTRAINT unique_cnpj_seller unique (cnpj_seller),
    CONSTRAINT unique_cpf_seller unique (cpf_seller),

    CONSTRAINT chk_seller_doc CHECK (
            (cpf_seller IS NOT NULL AND cnpj_seller IS NULL) 
        OR  (cpf_seller IS NULL AND cnpj_seller IS NOT NULL)),
    
    CONSTRAINT chk_cpf_seller_format CHECK (cpf_seller ~ '^[0-9]{11}$'),
    CONSTRAINT chk_cnpj_seller_format CHECK (cnpj_seller ~ '^[0-9]{14}$')
);

-- Tabela vendedor do produto
CREATE TABLE product_seller(
    id_seller int NOT NULL,
    id_product int NOT NULL,
    prod_quantity int NOT NULL DEFAULT 1,
    PRIMARY KEY (id_seller, id_product),
    CONSTRAINT fk_product_seller FOREIGN KEY (id_seller) REFERENCES seller(id_seller) ON DELETE CASCADE,
    CONSTRAINT fk_product_seller_product FOREIGN KEY (id_product) REFERENCES product(id_product) ON DELETE CASCADE,
    CONSTRAINT chk_product_seller_quantity CHECK (prod_quantity > 0)
);

-- Tabela Produtos na Ordem de Compra
CREATE TABLE product_order(
    id_product int NOT NULL,
    id_order int NOT NULL,
    po_quantity int NOT NULL DEFAULT 1,
    price numeric(10,2) NOT NULL,
    po_status po_status_type NOT NULL DEFAULT 'Disponivel',
    PRIMARY KEY (id_product, id_order),
    CONSTRAINT fk_product_order_product FOREIGN KEY (id_product) REFERENCES product(id_product) ON DELETE CASCADE,
    CONSTRAINT fk_product_order_purchase FOREIGN KEY (id_order) REFERENCES purchase_order(id_order) ON DELETE CASCADE,
    CONSTRAINT chk_order_quantity CHECK (po_quantity > 0)
);

-- Tabela fornecedor de Produto
CREATE TABLE product_supplier(
    id_ps_supplier int NOT NULL,
    id_ps_product int NOT NULL,
    ps_quantity int NOT NULL DEFAULT 1,
    PRIMARY KEY (id_ps_supplier, id_ps_product),
    CONSTRAINT fk_product_supplier_supplier FOREIGN KEY (id_ps_supplier) REFERENCES supplier(id_supplier) ON DELETE CASCADE,
    CONSTRAINT fk_product_supplier_product FOREIGN KEY (id_ps_product) REFERENCES product(id_product) ON DELETE CASCADE,
    CONSTRAINT chk_ps_quantity CHECK (ps_quantity > 0)
);

-- *********************************************************************************************
-- Criando os insert dos dados

-- Insert tabela client
INSERT INTO client (fname, minit, lname, cpf, address_city, address_state) VALUES
('Joao','A','Silva','11111111111','SP','SP'),
('Maria','B','Souza','22222222222','RJ','RJ'),
('Carlos','C','Oliveira','33333333333','BH','MG'),
('Ana','D','Costa','44444444444','POA','RS'),
('Pedro','E','Santos','55555555555','SP','SP'),
('Lucas','F','Almeida','66666666666','Curitiba','PR'),
('Julia','G','Ferreira','77777777777','Salvador','BA'),
('Rafael','H','Gomes','88888888888','Fortaleza','CE'),
('Bruna','I','Ribeiro','99999999999','Recife','PE'),
('Diego','J','Martins','10101010101','Goiania','GO');

-- Insert tabela product
INSERT INTO product (product_name, category, avaliacao) VALUES
('TV','eletro',4.5),
('Camiseta','vestimenta',4.2),
('Boneca','brinquedos',3.8),
('Arroz','alimentos',4.9),
('Sofa','moveis',4.0),
('Geladeira','eletro',4.7),
('Calca','vestimenta',4.1),
('Carrinho','brinquedos',3.9),
('Feijao','alimentos',4.6),
('Mesa','moveis',4.3);

-- Insert tabela suplier
INSERT INTO supplier (social_name, cnpj_supplier, contact_supplier) VALUES
('Fornecedor A','11111111000101','11999999991'),
('Fornecedor B','22222222000102','11999999992'),
('Fornecedor C','33333333000103','11999999993'),
('Fornecedor D','44444444000104','11999999994'),
('Fornecedor E','55555555000105','11999999995'),
('Fornecedor F','66666666000106','11999999996'),
('Fornecedor G','77777777000107','11999999997'),
('Fornecedor H','88888888000108','11999999998'),
('Fornecedor I','99999999000109','11999999999'),
('Fornecedor J','10101010000100','11999999990');

-- Insert tabela storage_location
INSERT INTO storage_location (storage_name, storage_type, city, state) VALUES
('CD SP','CD','SP','SP'),
('CD RJ','CD','RJ','RJ'),
('Loja SP','Loja','SP','SP'),
('Loja BH','Loja','BH','MG'),
('Hub Sul','Hub','POA','RS'),
('CD PR','CD','Curitiba','PR'),
('Loja BA','Loja','Salvador','BA'),
('Hub NE','Hub','Fortaleza','CE'),
('CD PE','CD','Recife','PE'),
('Loja GO','Loja','Goiania','GO');

-- Insert tabela seller
INSERT INTO seller (seller_social_name, cpf_seller, contact_seller, seller_location_street, seller_location_number, seller_location_city, seller_location_state) VALUES
('Vendedor 1','11111111111','11911111111','Rua A','10','SP','SP'),
('Vendedor 2','22222222222','11922222222','Rua B','20','RJ','RJ'),
('Vendedor 3','33333333333','11933333333','Rua C','30','BH','MG'),
('Vendedor 4','44444444444','11944444444','Rua D','40','POA','RS'),
('Vendedor 5','55555555555','11955555555','Rua E','50','SP','SP'),
('Vendedor 6','66666666666','11966666666','Rua F','60','Curitiba','PR'),
('Vendedor 7','77777777777','11977777777','Rua G','70','Salvador','BA'),
('Vendedor 8','88888888888','11988888888','Rua H','80','Fortaleza','CE'),
('Vendedor 9','99999999999','11999999999','Rua I','90','Recife','PE'),
('Vendedor 10','10101010101','11910101010','Rua J','100','Goiania','GO');

-- Insert purchase_order
INSERT INTO purchase_order (id_client, order_description) VALUES
(1,'Pedido 1'),(2,'Pedido 2'),(3,'Pedido 3'),(4,'Pedido 4'),(5,'Pedido 5'),
(6,'Pedido 6'),(7,'Pedido 7'),(8,'Pedido 8'),(9,'Pedido 9'),(10,'Pedido 10');

-- Insert tabela payment
INSERT INTO payment (id_client, type_payment, limit_available) VALUES
(1,'Credito',1000),(2,'Debito',500),(3,'PIX',0),(4,'Boleto',0),(5,'Credito',2000),
(6,'PIX',0),(7,'Debito',800),(8,'Credito',1500),(9,'Boleto',0),(10,'PIX',0);

-- Insert tabela product_storage
INSERT INTO product_storage (id_product, id_location, quantity) VALUES
(1,1,10),(2,2,20),(3,3,15),(4,4,50),(5,5,5),
(6,6,8),(7,7,30),(8,8,12),(9,9,40),(10,10,6);

-- Insert tabela product_seller
INSERT INTO product_seller (id_seller, id_product, prod_quantity) VALUES
(1,1,5),(2,2,10),(3,3,7),(4,4,20),(5,5,2),
(6,6,3),(7,7,15),(8,8,6),(9,9,25),(10,10,4);

-- Insert tabela product_order
INSERT INTO product_order (id_product, id_order, po_quantity, price) VALUES
(1,1,1,1000),(2,2,2,50),(3,3,1,80),(4,4,5,20),(5,5,1,2000),
(6,6,1,3000),(7,7,2,120),(8,8,1,90),(9,9,3,15),(10,10,1,500);

-- Insert tabela product_supplier
INSERT INTO product_supplier (id_ps_supplier, id_ps_product, ps_quantity) VALUES
(1,1,100),(2,2,200),(3,3,150),(4,4,500),(5,5,50),
(6,6,80),(7,7,300),(8,8,120),(9,9,400),(10,10,60);

-- *********************************************************************************************
-- Analisando os dados

-- Verificando o faturamento total
SELECT SUM(po.po_quantity * po.price) AS faturamento_total
    FROM product_order po;

-- Verificando o faturamento por cliente
SELECT
    concat(c.fname, ' ', c.lname) AS Nome_sobrenome,
    SUM(po.po_quantity * po.price) AS total_vendido
    FROM client c
    JOIN purchase_order o 
        ON (c.id_client = o.id_client)
    JOIN product_order po
        ON (o.id_order = po.id_order)
    GROUP BY c.id_client, Nome_sobrenome
    ORDER BY total_vendido DESC;
    
-- Verificando qual que é o produto mais vendido
SELECT 
    p.product_name,
    SUM(po.po_quantity) as venda_total
    FROM product p
    JOIN product_order po 
        ON (p.id_product = po.id_product)
    GROUP BY p.product_name
    ORDER BY venda_total DESC
    LIMIT 10;

-- Valor medio dos pedidos
SELECT
    AVG(order_total) AS 'Media dos pedidos'
    FROM(
        SELECT
            o.id_order,
            SUM(po.po_quantity * po.price) AS order_total
        FROM purchase_order o 
        JOIN product_order po
            ON (o.id_order = po.id_order)
        GROUP BY o.id_order
) sub;

-- Estoque de produtos
SELECT
    p.product_name,
    SUM(ps.quantity) AS total_stock
FROM product p
JOIN product_storage ps 
    ON (p.id_product = ps.id_product)
GROUP BY p.product_name
    -- HAVING SUM(ps.quantity) < 10; -- use para verificar estoque min
ORDER BY total_stock DESC;

-- Verificar produtos por vendedor
SELECT
    s.seller_social_name,
    p.product_name,
    ps.quantity)
FROM seller s
JOIN product_seller ps 
    ON (s.id_seller = ps.id_seller)
JOIN product p
    ON (ps.id_product = p.iproduct)

-- Produtos por fornecedor
SELECT 
    sup.social_name,
    p.product_name,
    ps.ps_quantity
FROM supplier sup
JOIN product_supplier ps 
    ON (sup.id_supplier = ps.id_ps_supplier)
JOIN product p 
    ON (ps.id_ps_product = p.id_product);

-- Pedidos com statu dos produtos
SELECT 
    o.id_order,
    p.product_name,
    po.po_status
FROM purchase_order o
JOIN product_order po 
    ON (o.id_order = po.id_order)
JOIN product p 
    ON (po.id_product = p.id_product);

-- Rendimento por categoria
SELECT 
    p.category,
    SUM(po.po_quantity * po.price) AS revenue
FROM product p
JOIN product_order po 
    ON (p.id_product = po.id_product)
GROUP BY p.category
ORDER BY revenue DESC;
