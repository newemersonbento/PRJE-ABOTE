# 📱 API Mobile - Endpoints de Dispositivos Móveis

## 📋 Resumo

A tabela `Mobile` armazena informações de dispositivos móveis autorizados no sistema, com os seguintes campos:

- `id`: INT (Primary Key, Auto-increment)
- `nome`: VARCHAR(255) - Nome do dispositivo
- `chave`: VARCHAR(255) - Chave única de autenticação (UNIQUE)
- `created_at`: DATETIME - Data de criação
- `updated_at`: DATETIME - Última atualização (via trigger)
- `is_active`: BIT - Status ativo/inativo (default: 1)

---

## 🔐 Autenticação

**TODOS os endpoints requerem autenticação via API Key no header:**

```
X-API-Key: webapp-api-key-2024-secure-change-in-production
```

---

## 📡 Endpoints Disponíveis

### 1️⃣ **GET /api/mobile** - Listar todos os dispositivos

**Descrição**: Retorna todos os dispositivos móveis ativos.

**Request**:
```bash
curl -X GET http://localhost:3001/api/mobile \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"
```

**Response 200**:
```json
[
  {
    "id": 1,
    "nome": "iPhone 14 Pro - João",
    "chave": "mob_abc123xyz456",
    "created_at": "2024-01-15T10:30:00.000Z",
    "updated_at": "2024-01-15T10:30:00.000Z",
    "is_active": true
  },
  {
    "id": 2,
    "nome": "Samsung Galaxy S23 - Maria",
    "chave": "mob_def789ghi012",
    "created_at": "2024-01-16T14:20:00.000Z",
    "updated_at": "2024-01-16T14:20:00.000Z",
    "is_active": true
  }
]
```

---

### 2️⃣ **GET /api/mobile/:id** - Buscar dispositivo por ID

**Descrição**: Retorna um dispositivo móvel específico.

**Request**:
```bash
curl -X GET http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"
```

**Response 200**:
```json
{
  "id": 1,
  "nome": "iPhone 14 Pro - João",
  "chave": "mob_abc123xyz456",
  "created_at": "2024-01-15T10:30:00.000Z",
  "updated_at": "2024-01-15T10:30:00.000Z",
  "is_active": true
}
```

**Response 404**:
```json
{
  "error": "Dispositivo móvel não encontrado"
}
```

---

### 3️⃣ **GET /api/mobile/chave/:chave** - Buscar por chave

**Descrição**: Busca dispositivo pela chave de autenticação (útil para login mobile).

**Request**:
```bash
curl -X GET http://localhost:3001/api/mobile/chave/mob_abc123xyz456 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"
```

**Response 200**:
```json
{
  "id": 1,
  "nome": "iPhone 14 Pro - João",
  "chave": "mob_abc123xyz456",
  "created_at": "2024-01-15T10:30:00.000Z",
  "updated_at": "2024-01-15T10:30:00.000Z",
  "is_active": true
}
```

**Response 404**:
```json
{
  "error": "Dispositivo móvel não encontrado"
}
```

---

### 4️⃣ **POST /api/mobile** - Criar novo dispositivo

**Descrição**: Cria um novo dispositivo móvel no sistema.

**Request**:
```bash
curl -X POST http://localhost:3001/api/mobile \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Xiaomi 13 - Carlos",
    "chave": "mob_unique_key_789"
  }'
```

**Request Body**:
```json
{
  "nome": "Xiaomi 13 - Carlos",
  "chave": "mob_unique_key_789"
}
```

**Validações**:
- `nome`: obrigatório
- `chave`: obrigatória, deve ser única

**Response 201**:
```json
{
  "message": "Dispositivo móvel criado com sucesso",
  "data": {
    "id": 3,
    "nome": "Xiaomi 13 - Carlos",
    "chave": "mob_unique_key_789",
    "created_at": "2024-01-17T09:15:00.000Z"
  }
}
```

**Response 400** (campos obrigatórios):
```json
{
  "error": "Nome e chave são obrigatórios"
}
```

**Response 409** (chave duplicada):
```json
{
  "error": "Chave já existe",
  "message": "Esta chave já está cadastrada no sistema"
}
```

---

### 5️⃣ **PUT /api/mobile/:id** - Atualizar dispositivo

**Descrição**: Atualiza informações de um dispositivo móvel.

**Request**:
```bash
curl -X PUT http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "iPhone 15 Pro Max - João Silva",
    "is_active": true
  }'
```

**Request Body** (campos opcionais):
```json
{
  "nome": "iPhone 15 Pro Max - João Silva",
  "chave": "mob_new_key_abc",
  "is_active": true
}
```

**Response 200**:
```json
{
  "message": "Dispositivo móvel atualizado com sucesso",
  "data": {
    "id": 1,
    "nome": "iPhone 15 Pro Max - João Silva",
    "chave": "mob_abc123xyz456",
    "updated_at": "2024-01-18T11:45:00.000Z",
    "is_active": true
  }
}
```

**Response 400**:
```json
{
  "error": "Nenhum campo para atualizar"
}
```

**Response 404**:
```json
{
  "error": "Dispositivo móvel não encontrado"
}
```

**Response 409** (chave duplicada):
```json
{
  "error": "Chave já existe",
  "message": "Esta chave já está cadastrada no sistema"
}
```

---

### 6️⃣ **DELETE /api/mobile/:id** - Desativar dispositivo

**Descrição**: Desativa um dispositivo móvel (soft delete - `is_active = 0`).

**Request**:
```bash
curl -X DELETE http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-in-production"
```

**Response 200**:
```json
{
  "message": "Dispositivo móvel desativado com sucesso",
  "data": {
    "id": 1,
    "nome": "iPhone 14 Pro - João"
  }
}
```

**Response 404**:
```json
{
  "error": "Dispositivo móvel não encontrado ou já inativo"
}
```

---

## 🧪 Exemplos de Teste

### Teste com curl (Linux/Mac/Windows PowerShell)

```bash
# 1. Criar novo dispositivo
curl -X POST http://localhost:3001/api/mobile \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
  -H "Content-Type: application/json" \
  -d '{"nome":"iPhone 14","chave":"mob_test_123"}'

# 2. Listar todos
curl -X GET http://localhost:3001/api/mobile \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"

# 3. Buscar por ID
curl -X GET http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"

# 4. Buscar por chave
curl -X GET http://localhost:3001/api/mobile/chave/mob_test_123 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"

# 5. Atualizar
curl -X PUT http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
  -H "Content-Type: application/json" \
  -d '{"nome":"iPhone 15 Pro"}'

# 6. Deletar (desativar)
curl -X DELETE http://localhost:3001/api/mobile/1 \
  -H "X-API-Key: webapp-api-key-2024-secure-change-in-production"
```

### Teste com JavaScript (frontend)

```javascript
// Configuração
const API_URL = 'http://localhost:3001';
const API_KEY = 'webapp-api-key-2024-secure-change-in-production';

// Headers padrão
const headers = {
  'Content-Type': 'application/json',
  'X-API-Key': API_KEY
};

// 1. Listar todos os dispositivos
async function listarDispositivos() {
  const response = await fetch(`${API_URL}/api/mobile`, { headers });
  const data = await response.json();
  console.log('Dispositivos:', data);
  return data;
}

// 2. Criar novo dispositivo
async function criarDispositivo(nome, chave) {
  const response = await fetch(`${API_URL}/api/mobile`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ nome, chave })
  });
  const data = await response.json();
  console.log('Dispositivo criado:', data);
  return data;
}

// 3. Buscar por chave (autenticação)
async function autenticarDispositivo(chave) {
  const response = await fetch(`${API_URL}/api/mobile/chave/${chave}`, { headers });
  if (response.ok) {
    const data = await response.json();
    console.log('Dispositivo autenticado:', data);
    return data;
  } else {
    console.error('Dispositivo não encontrado');
    return null;
  }
}

// 4. Atualizar dispositivo
async function atualizarDispositivo(id, updates) {
  const response = await fetch(`${API_URL}/api/mobile/${id}`, {
    method: 'PUT',
    headers,
    body: JSON.stringify(updates)
  });
  const data = await response.json();
  console.log('Dispositivo atualizado:', data);
  return data;
}

// 5. Desativar dispositivo
async function desativarDispositivo(id) {
  const response = await fetch(`${API_URL}/api/mobile/${id}`, {
    method: 'DELETE',
    headers
  });
  const data = await response.json();
  console.log('Dispositivo desativado:', data);
  return data;
}

// Exemplo de uso
(async () => {
  // Criar dispositivo
  await criarDispositivo('iPhone 14 - João', 'mob_abc123');
  
  // Listar todos
  const dispositivos = await listarDispositivos();
  
  // Autenticar
  const auth = await autenticarDispositivo('mob_abc123');
  
  if (auth) {
    console.log('✅ Autenticação bem-sucedida:', auth.nome);
  }
})();
```

---

## 🔒 Segurança

### Proteções Implementadas

1. **API Key Obrigatória**: Todos os endpoints requerem `X-API-Key` header
2. **Rate Limiting**: 100 requisições por 15 minutos por IP
3. **SQL Injection Protection**: Todas as queries usam prepared statements
4. **CORS**: Configurado para permitir apenas origens autorizadas
5. **Soft Delete**: Dispositivos não são deletados fisicamente, apenas desativados

### Boas Práticas

1. **Gerar chaves únicas**: Use UUID ou hash seguros
   ```javascript
   // Exemplo de geração de chave
   const chave = `mob_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
   ```

2. **Não expor API Key no frontend**: Use variáveis de ambiente
   ```javascript
   // React/Vite
   const API_KEY = import.meta.env.VITE_API_KEY;
   ```

3. **Validar chave antes de operações críticas**:
   ```javascript
   // Verificar se dispositivo está ativo
   const dispositivo = await fetch(`/api/mobile/chave/${chave}`);
   if (!dispositivo.is_active) {
     throw new Error('Dispositivo inativo');
   }
   ```

---

## 📊 Estrutura da Tabela

```sql
CREATE TABLE Mobile (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    chave VARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    is_active BIT DEFAULT 1
);

-- Trigger para updated_at automático
CREATE TRIGGER trg_mobile_updated_at
ON Mobile
AFTER UPDATE
AS
BEGIN
    UPDATE Mobile
    SET updated_at = GETDATE()
    FROM Mobile m
    INNER JOIN inserted i ON m.id = i.id
END;
```

---

## 📝 Changelog

### Versão 1.0.0 (2024-01-18)
- ✅ Criação da tabela Mobile
- ✅ 6 endpoints CRUD completos
- ✅ Autenticação por API Key
- ✅ Soft delete implementado
- ✅ Busca por chave para autenticação mobile
- ✅ Proteção contra chaves duplicadas
- ✅ Trigger de updated_at automático

---

## 🆘 Suporte

- **Documentação completa**: `/home/user/webapp-api/README.md`
- **Schema SQL**: `/home/user/webapp-api/create-table-mobile.sql`
- **Repositório**: https://github.com/newemersonbento/PRJE-ABOTE

---

## ✅ Checklist de Implementação

- [x] Tabela `Mobile` criada no SQL Server
- [x] 6 endpoints CRUD implementados
- [x] Autenticação via API Key
- [x] Proteção contra SQL injection
- [x] Rate limiting configurado
- [x] Soft delete (is_active)
- [x] Trigger de auditoria (updated_at)
- [x] Documentação completa
- [ ] Testes unitários
- [ ] Integração com frontend
- [ ] Deploy em produção

---

**Última atualização**: 2024-01-18  
**Versão da API**: 1.0.0  
**Autor**: Portal de Indicadores Way Brasil
