const db = require('./database');

async function testConnection() {
  console.log('🧪 Testando conexão com SQL Server...\n');
  
  try {
    // Testar conexão
    console.log('1️⃣ Conectando ao banco...');
    await db.connect();
    console.log('✅ Conexão estabelecida!\n');
    
    // Testar query simples
    console.log('2️⃣ Executando query de teste...');
    const result = await db.query('SELECT @@VERSION as version');
    console.log('✅ Query executada!');
    console.log('📊 Versão do SQL Server:', result[0].version.split('\n')[0], '\n');
    
    // Listar tabelas
    console.log('3️⃣ Listando tabelas do banco...');
    const tables = await db.query(`
      SELECT TABLE_NAME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_TYPE = 'BASE TABLE'
      ORDER BY TABLE_NAME
    `);
    
    if (tables.length > 0) {
      console.log('✅ Tabelas encontradas:');
      tables.forEach(t => console.log('   📋', t.TABLE_NAME));
    } else {
      console.log('⚠️ Nenhuma tabela encontrada. Execute o script schema.sql primeiro!');
    }
    
    console.log('\n✅ Teste concluído com sucesso!');
    
  } catch (error) {
    console.error('\n❌ Erro no teste:', error.message);
    console.error('\n💡 Verifique:');
    console.error('   1. As credenciais no arquivo .env');
    console.error('   2. Se o servidor SQL Server está acessível');
    console.error('   3. Se o firewall permite a conexão');
    console.error('   4. Se o usuário tem permissões corretas');
  } finally {
    await db.close();
    process.exit(0);
  }
}

testConnection();
