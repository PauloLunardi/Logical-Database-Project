-- ainda nao criado apenas em desenvolvimento

-- 1. Criando os tipos ENUM primeiro (boa prática para evitar erros de dependência)
CREATE TYPE category_type AS ENUM ('eletro', 'vestimenta', 'brinquedos', 'alimentos', 'moveis');
CREATE TYPE status_type AS ENUM ('Cancelado', 'Confirmado', 'Em processamento');
CREATE TYPE payment_type AS ENUM ('Boleto', 'Credito', 'Debito', 'PIX');

-- 2. Tabela Cliente
CREATE TABLE client (
    id_client int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fname varchar(15) NOT NULL, -- Adicionado NOT NULL
    minit char(1),
    lname varchar(15) NOT NULL, -- Adicionado NOT NULL
    cpf char(11) NOT NULL,      -- CPF é essencial
    address_street varchar(30),
    address_number varchar(10),
    address_city varchar(30),
    address_state char(2),
    CONSTRAINT unique_cpf_client UNIQUE(cpf)
);

-- 3. Tabela Produto
CREATE TABLE product (
    id_product int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name varchar(30) NOT NULL UNIQUE,
    classification_kids BOOLEAN DEFAULT false,
    category category_type NOT NULL,
    avaliacao float DEFAULT 0,
    size varchar(10)
);

-- 4. Tabela Pagamento (Gerado na hora, vinculado ao cliente)
CREATE TABLE payment (
    id_client int NOT NULL,
    id_payment int GENERATED ALWAYS AS IDENTITY, -- Corrigido para IDENTITY
    type_payment payment_type NOT NULL,
    limit_available float DEFAULT 0,
    PRIMARY KEY (id_client, id_payment),
    CONSTRAINT fk_payment_client FOREIGN KEY (id_client) REFERENCES client(id_client)
);

-- 5. Tabela Pedido (Purchase Order)
CREATE TABLE purchase_order (
    id_order int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_order_client int NOT NULL, -- Adicionado NOT NULL para garantir que o pedido tenha um dono
    order_status status_type NOT NULL DEFAULT 'Em processamento',
    order_description varchar(260),
    send_value float DEFAULT 10,
    payment_cash BOOLEAN DEFAULT false,
    CONSTRAINT fk_orders_client FOREIGN KEY (id_order_client) REFERENCES client(id_client)
);

-- 6. Tabela Fornecedor (supplier)
CREATE TABLE supplier (
    id_supplier int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    social_name varchar(255) not null,
    cnpj_supplier char(14) not null,
    contact char(11) not null,
    supplier_location_street varchar(30),
    supplier_location_number varchar(10),
    supplier_location_city varchar(30),
    supplier_location_state char(2),
    CONSTRAINT unique_supplier unique (cnpj_supplier)
);
