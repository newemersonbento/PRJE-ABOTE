-- =============================================
-- Tabela: Mobile
-- Descrição: Armazena informações de dispositivos móveis
-- Autor: Sistema Portal Way Brasil
-- Data: 2026-01-12
-- =============================================

-- Verificar se a tabela já existe e excluir (opcional)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Mobile]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Mobile]
    PRINT '⚠️  Tabela Mobile existente removida'
END
GO

-- Criar tabela Mobile
CREATE TABLE [dbo].[Mobile] (
    -- ID: Chave primária auto-incremento
    id INT IDENTITY(1,1) NOT NULL,
    
    -- Nome: Nome do dispositivo ou usuário
    nome NVARCHAR(255) NOT NULL,
    
    -- Chave: Chave única de identificação (pode ser token, UUID, etc)
    chave NVARCHAR(500) NOT NULL,
    
    -- Campos de auditoria (opcional, mas recomendado)
    created_at DATETIME DEFAULT GETDATE() NOT NULL,
    updated_at DATETIME DEFAULT GETDATE() NOT NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    
    -- Constraint de chave primária
    CONSTRAINT PK_Mobile PRIMARY KEY CLUSTERED (id ASC),
    
    -- Constraint de unicidade na chave
    CONSTRAINT UQ_Mobile_Chave UNIQUE (chave)
)
GO

-- Criar índices para performance
CREATE NONCLUSTERED INDEX IX_Mobile_Nome ON [dbo].[Mobile] (nome ASC)
GO

CREATE NONCLUSTERED INDEX IX_Mobile_Chave ON [dbo].[Mobile] (chave ASC)
GO

CREATE NONCLUSTERED INDEX IX_Mobile_IsActive ON [dbo].[Mobile] (is_active ASC)
GO

-- Criar trigger para atualização automática do campo updated_at
CREATE TRIGGER TR_Mobile_UpdateTimestamp
ON [dbo].[Mobile]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE [dbo].[Mobile]
    SET updated_at = GETDATE()
    FROM [dbo].[Mobile] m
    INNER JOIN inserted i ON m.id = i.id
END
GO

-- Inserir dados de exemplo (opcional)
INSERT INTO [dbo].[Mobile] (nome, chave)
VALUES 
    ('Dispositivo Teste 1', 'CHAVE-001-ABC123'),
    ('Dispositivo Teste 2', 'CHAVE-002-DEF456'),
    ('Usuário Mobile App', 'CHAVE-003-GHI789')
GO

-- Verificar criação
SELECT 
    COUNT(*) as Total_Registros,
    'Mobile' as Tabela
FROM [dbo].[Mobile]
GO

PRINT '✅ Tabela Mobile criada com sucesso!'
PRINT '📊 3 registros de exemplo inseridos'
PRINT ''
PRINT '📋 Estrutura da tabela:'
PRINT '   - id: INT IDENTITY(1,1) PRIMARY KEY'
PRINT '   - nome: NVARCHAR(255) NOT NULL'
PRINT '   - chave: NVARCHAR(500) NOT NULL UNIQUE'
PRINT '   - created_at: DATETIME DEFAULT GETDATE()'
PRINT '   - updated_at: DATETIME DEFAULT GETDATE()'
PRINT '   - is_active: BIT DEFAULT 1'
PRINT ''
PRINT '🔍 Índices criados:'
PRINT '   - IX_Mobile_Nome (nome)'
PRINT '   - IX_Mobile_Chave (chave)'
PRINT '   - IX_Mobile_IsActive (is_active)'
PRINT ''
PRINT '⚡ Trigger criado:'
PRINT '   - TR_Mobile_UpdateTimestamp (atualiza updated_at automaticamente)'
GO
