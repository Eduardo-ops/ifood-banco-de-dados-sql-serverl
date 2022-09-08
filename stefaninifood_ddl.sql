-- **** ARQUIVO DE DEFINI��O DDL ****

USE stefaninifooddb;

-- *** USUARIO ***
-- id do usuario
-- email do usu�rio
-- senha do usu�rio

CREATE TABLE TB_USUARIO(
	US_ID INT IDENTITY(1,1) NOT NULL,
	US_EMAIL VARCHAR(50) not null,
	US_SENHA VARCHAR(100) not null,

	CONSTRAINT PK_TB_USUARIO PRIMARY KEY CLUSTERED (US_ID)
)

-- *** CLIENTE ***
-- id do cliente
-- nome do cliente
-- rg do cliente
-- cpf do cliente
-- idade do cliente
-- endereco do cliente

CREATE TABLE TB_CLIENTE(
	CLI_ID INT IDENTITY(1,1) not null,
	CLI_NOME VARCHAR(40) not null,
	CLI_RG CHAR(9) not null,
	CLI_CPF CHAR(11) not null,
	CLI_IDADE SMALLINT null,
	CLI_ENDERECO VARCHAR(80) not null,

	CONSTRAINT PK_TB_CLIENTE PRIMARY KEY CLUSTERED (CLI_ID)
)

-- *** ITEMPEDIDO ***
-- id do item
-- quantidade do item
-- pre�o do item

CREATE TABLE TB_ITEM_PEDIDO(
	IT_ID SMALLINT IDENTITY(1,1)not null,
	IT_QUANTIDADE SMALLINT not null,
	IT_PRECO SMALLMONEY not null,

	CONSTRAINT PK_TB_ITEM_PEDIDO PRIMARY KEY CLUSTERED (IT_ID)
)

-- *** PEDIDO ***
-- id do pedido
-- endereco do pedido
-- taxa de entrega do pedido
-- tipo de pagamento do pedido
-- pre�o total do pedido
-- confirma��o do pedido
-- status do pedido

CREATE TABLE TB_PEDIDO(
	PE_ID SMALLINT IDENTITY(1,1) not null,
	PE_ENDERECO VARCHAR(80) not null,
	PE_TAXA_ENTREGA SMALLMONEY null,
	PE_TIPO_PAGAMENTO VARCHAR(30) not null,
	PE_PRECO_TOTAL SMALLMONEY not null,
	PE_CONFIRMACAO_PEDIDO BIT not null,
	PE_STATUS_PEDIDO VARCHAR(14) not null,

	CONSTRAINT PK_TB_PEDIDO PRIMARY KEY CLUSTERED (PE_ID)
)

-- *** LOJA ***
-- id_loja
-- nome da loja
-- razao social da loja
-- endereco da loja
-- cnpj da loja
-- data de registro da loja

CREATE TABLE TB_LOJA(
	LO_ID SMALLINT IDENTITY(1,1) NOT NULL,
	LO_NOME VARCHAR(50) NOT NULL,
	LO_RAZAO_SOCIAL VARCHAR(50) NULL,
	LO_ENDERECO VARCHAR(80) NOT NULL,
	LO_CNPJ CHAR(14) NOT NULL,
	LO_DATA_REGISTRO DATE NOT NULL,

	CONSTRAINT PK_TB_LOJA PRIMARY KEY CLUSTERED (LO_ID)
)

-- *** PRODUTO ***
-- id do produto
-- nome do produto
-- descricao do produto
-- valor do produto

CREATE TABLE TB_PRODUTO(
	PR_ID SMALLINT IDENTITY(1,1) NOT NULL,
	PR_NOME VARCHAR(50) NOT NULL,
	PR_DESCRICAO VARCHAR(50) NULL,
	PR_VALOR SMALLMONEY NOT NULL,

	CONSTRAINT PK_TB_PRODUTO PRIMARY KEY CLUSTERED (PR_ID)
)

-- *** CATEGORIA ***
-- id da categoria
-- nome da categoria

CREATE TABLE TB_CATEGORIA(
	CA_ID SMALLINT IDENTITY(1,1) NOT NULL,
	CA_NOME VARCHAR(50) NOT NULL,

	CONSTRAINT PK_TB_CATEGORIA PRIMARY KEY CLUSTERED (CA_ID)
)

-- **** CRIA��O DE CHAVES ESTRANGEIRAS PARA RELACIONAMENTOS DE ENTIDADES ****

-- *** CHAVE ESTRANGEIRA CLIENTE EM PEDIDO COM REFERENCIA EM CLIENTE *** 
ALTER TABLE TB_PEDIDO
ADD PE_CLIENTE smallint not null

ALTER TABLE TB_PEDIDO
ADD CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (PE_CLIENTE) REFERENCES TB_CLIENTE(CLI_ID)


-- *** CHAVE ESTRANGEIRA DE ITEM_PEDIDO PARA PEDIDO ***
ALTER TABLE TB_ITEM_PEDIDO
ADD IT_PEDIDO smallint not null

ALTER TABLE TB_ITEM_PEDIDO
ADD CONSTRAINT FK_TB_ITEM_PEDIDO_TB_PEDIDO FOREIGN KEY (IT_PEDIDO) REFERENCES TB_PEDIDO(PE_ID)


-- *** CHAVE ESTRANGEIRA LOJA EM PRODUTO COM REFERENCIA EM LOJA ***
ALTER TABLE TB_PRODUTO
ADD PR_LOJA smallint not null

ALTER TABLE TB_PRODUTO
ADD CONSTRAINT FK_TB_PRODUTO_TB_LOJA FOREIGN KEY (PR_LOJA) REFERENCES TB_LOJA(LO_ID)

-- *** CHAVE ESTRANGEIRA LOJA EM PEDIDO COM REFERENCIA EM LOJA ***
ALTER TABLE TB_PEDIDO
ADD TB_LOJA smallint not null

ALTER TABLE TB_PEDIDO
ADD CONSTRAINT FK_TB_PEDIDO_TB_LOJA FOREIGN KEY (PE_LOJA) REFERENCES TB_LOJA(LO_ID)

-- **** CRIACAO DE TABELA J� COM RELA��O DE MANY TO MANY ENTRE PRODUTOS E CATEGORIAS ****
-- id principal da rela��o
-- id do produto(pk)
-- id da categoria(pk)

CREATE TABLE TB_PRODUTO_CATEGORIA(
	PC_PRODUTO SMALLINT NOT NULL,
	PC_CATEGORIA SMALLINT NOT NULL

	CONSTRAINT PK_PRODUTO_CATEGORIA PRIMARY KEY (PC_PRODUTO,PC_CATEGORIA),
	CONSTRAINT FK_TB_PRODUTO_TB_CATEGORIA FOREIGN KEY (PC_PRODUTO) REFERENCES TB_PRODUTO(PR_ID), 
	CONSTRAINT FK_TB_PRODUTO_CATEGORIA2 FOREIGN KEY (PC_CATEGORIA) REFERENCES TB_CATEGORIA(CA_ID) 
)

-- **** CRIA��O DE INDICES ****
-- Indices de cada tabela definida com suas determinadas colunas como refer�ncia

CREATE NONCLUSTERED INDEX IX_CLIENTE_RG ON TB_CLIENTE(CLI_RG)
CREATE NONCLUSTERED INDEX IX_PRODUTO_NOME ON TB_PRODUTO(PR_NOME)
CREATE NONCLUSTERED INDEX IX_LOJA_NOME ON TB_LOJA(LO_NOME)
CREATE NONCLUSTERED INDEX IX_PEDIDO_CLIENTE ON TB_PEDIDO(PE_CLIENTE)


-- **** CRIA��O DE STORED PROCEDURES ****

-- Procedure que ser� utilizada para toda vez que o pedido for confirmado, ele receba seu status de CONFIRMADO ou NAO CONFIRMADO.
CREATE PROCEDURE st_atualizar_status_pedido
AS
BEGIN
	UPDATE TB_PEDIDO SET PE_STATUS_PEDIDO = 'Confirmado'
	WHERE PE_CONFIRMACAO_PEDIDO = 1

	UPDATE TB_PEDIDO SET PE_STATUS_PEDIDO = 'N�o confirmado' 
	WHERE PE_CONFIRMACAO_PEDIDO = 0
END


-- **** CRIA��O DE FUN��ES ****

-- Fun��o que retorna o faturamento total de um determinado m�s com base nos pedidos.
CREATE FUNCTION fc_faturamento_mes(@mes AS DATE) RETURNS SMALLMONEY
AS
BEGIN
	DECLARE @faturamento SMALLMONEY
	SELECT @faturamento = SUM(PE_PRECO_TOTAL) FROM TB_PEDIDO
	WHERE PE_DATA = @mes
	RETURN @faturamento
END

-- Fun��o que nos retorna a quantidade total de pedidos em um determinado m�s.
CREATE FUNCTION fc_quantidade_pedidos_mes(@mes AS DATE) RETURNS INT
AS 
BEGIN
	DECLARE @quantidade int
	SELECT @quantidade = COUNT(PE_ID) FROM TB_PEDIDO
	WHERE PE_DATA = @mes
	RETURN @quantidade
END