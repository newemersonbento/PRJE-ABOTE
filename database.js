const sql = require('mssql');
require('dotenv').config();

// Configuração da conexão
const config = {
  server: process.env.DB_SERVER,
  port: parseInt(process.env.DB_PORT || '1433'),
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_CERTIFICATE === 'true',
    enableArithAbort: true,
    connectionTimeout: 30000,
    requestTimeout: 30000
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

// Pool de conexões
let pool = null;

/**
 * Conectar ao SQL Server
 */
async function connect() {
  try {
    if (pool) {
      return pool;
    }
    
    console.log('🔌 Conectando ao SQL Server...');
    pool = await sql.connect(config);
    console.log('✅ Conectado ao SQL Server com sucesso!');
    
    return pool;
  } catch (error) {
    console.error('❌ Erro ao conectar ao SQL Server:', error);
    throw error;
  }
}

/**
 * Executar query
 */
async function query(queryString, params = {}) {
  try {
    const poolConnection = await connect();
    const request = poolConnection.request();
    
    // Adicionar parâmetros
    Object.keys(params).forEach(key => {
      request.input(key, params[key]);
    });
    
    const result = await request.query(queryString);
    return result.recordset;
  } catch (error) {
    console.error('❌ Erro ao executar query:', error);
    throw error;
  }
}

/**
 * Executar stored procedure
 */
async function execute(procedureName, params = {}) {
  try {
    const poolConnection = await connect();
    const request = poolConnection.request();
    
    // Adicionar parâmetros
    Object.keys(params).forEach(key => {
      request.input(key, params[key]);
    });
    
    const result = await request.execute(procedureName);
    return result.recordset;
  } catch (error) {
    console.error('❌ Erro ao executar procedure:', error);
    throw error;
  }
}

/**
 * Fechar conexão
 */
async function close() {
  try {
    if (pool) {
      await pool.close();
      pool = null;
      console.log('🔌 Conexão com SQL Server fechada');
    }
  } catch (error) {
    console.error('❌ Erro ao fechar conexão:', error);
  }
}

// Fechar conexão ao encerrar processo
process.on('SIGINT', async () => {
  await close();
  process.exit(0);
});

module.exports = {
  connect,
  query,
  execute,
  close,
  sql
};
