-- falta criaçaõ das tabelas da aula 7

-- 1. Criando os tipos ENUM primeiro (boa prática para evitar erros de dependência)
CREATE TYPE category_type AS ENUM ('eletro', 'vestimenta', 'brinquedos', 'alimentos', 'moveis');
CREATE TYPE status_type AS ENUM ('Cancelado', 'Confirmado', 'Em processamento');
CREATE TYPE payment_type AS ENUM ('Boleto', 'Credito', 'Debito', 'PIX');
CREATE TYPE po_status_type AS ENUM ('Disponivel', 'Sem Estoque');
CREATE TYPE location_type AS ENUM ('CD', 'Loja', 'Hub');

-- 2. Tabela Cliente
CREATE TABLE client (
    id_client int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fname varchar(15) NOT NULL, -- Adicionado NOT NULL
    minit char(1),
    lname varchar(15) NOT NULL, -- Adicionado NOT NULL
    cpf varchar(11) NOT NULL,      -- CPF é essencial
    address_street varchar(30),
    address_number varchar(10),
    address_city varchar(30),
    address_state char(2),
    CONSTRAINT unique_cpf_client UNIQUE(cpf),
    CONSTRAINT chk_cpf_format CHECK (cpf ~ '^[0-9]{11}$') -- garante o formato do CPF
);

-- 3. Tabela Produto
CREATE TABLE product (
    id_product int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name varchar(30) NOT NULL UNIQUE,
    classification_kids BOOLEAN DEFAULT false,
    category category_type NOT NULL,
    avaliacao numeric(3,2) DEFAULT 0,
    size varchar(10)
);

-- 4. Tabela Pagamento (Gerado na hora, vinculado ao cliente)
CREATE TABLE payment (
    id_client int NOT NULL,
    id_payment int GENERATED ALWAYS AS IDENTITY, -- Corrigido para IDENTITY
    type_payment payment_type NOT NULL,
    limit_available numeric(10,2) DEFAULT 0,
    PRIMARY KEY (id_client, id_payment),
    CONSTRAINT fk_payment_client FOREIGN KEY (id_client) REFERENCES client(id_client)
);

-- 5. Tabela Pedido (Purchase Order)
CREATE TABLE purchase_order (
    id_order int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_client int NOT NULL, -- Adicionado NOT NULL para garantir que o pedido tenha um dono
    order_status status_type NOT NULL DEFAULT 'Em processamento',
    order_description varchar(260),
    send_value numeric(10,2) DEFAULT 10, -- alterado para numeric(melhor precisão)
    payment_cash BOOLEAN DEFAULT false,
    CONSTRAINT fk_orders_client FOREIGN KEY (id_client) REFERENCES client(id_client)
);

-- 6. Tabela Fornecedor (supplier)
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

-- 7. Tabela Localizacao do estoque (storage_location)
CREATE TABLE storage_location(
    id_location int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    storage_name varchar(50) NOT NULL,
    storage_type location_type NOT NULL DEFAULT 'CD',
    street varchar(30),
    number varchar(10),
    city varchar(30),
    state char(2),
    CONSTRAINT unique_storage_location UNIQUE (storage_name, city, state)
);

-- 8. Tabela produto em estoque (storage)
CREATE TABLE product_storage(
    id_product_storage int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_product int NOT NULL,
    id_location int NOT NULL,
    quantity int NOT NULL DEFAULT 0,
    CONSTRAINT fk_storage_product FOREIGN KEY (id_product) REFERENCES product(id_product),
    CONSTRAINT fk_storage_location FOREIGN KEY (id_location) REFERENCES storage_location(id_location),
    CONSTRAINT unique_product_storage UNIQUE (id_product, id_location),
    CONSTRAINT chk_product_storage CHECK (quantity >= 0)
);

-- 9. Tabela vendedor (seller)
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

-- 10. Tabela vendedor do produto (product_seller)
CREATE TABLE product_seller(
    id_seller int NOT NULL,
    id_product int NOT NULL,
    prod_quantity int NOT NULL DEFAULT 1,
    PRIMARY KEY (id_seller, id_product),
    CONSTRAINT fk_product_seller FOREIGN KEY (id_seller) REFERENCES seller(id_seller),
    CONSTRAINT fk_product_seller_product FOREIGN KEY (id_product) REFERENCES product(id_product),
    CONSTRAINT chk_product_seller_quantity CHECK (prod_quantity > 0)
);

-- 11. Tabela Ordem Produto  (Produtos na Ordem de Compra)
CREATE TABLE product_order(
    id_product int NOT NULL,
    id_order int NOT NULL,
    po_quantity int NOT NULL DEFAULT 1,
    price numeric(10,2) NOT NULL,
    po_status po_status_type NOT NULL DEFAULT 'Disponivel',
    PRIMARY KEY (id_product, id_order),
    CONSTRAINT fk_product_order_product FOREIGN KEY (id_product) REFERENCES product(id_product),
    CONSTRAINT fk_product_order_purchase FOREIGN KEY (id_order) REFERENCES purchase_order(id_order),
    CONSTRAINT chk_order_quantity CHECK (po_quantity > 0)
);
    
