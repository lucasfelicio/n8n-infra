#!/bin/bash
set -e

# Função para criar um banco de dados se não existir
create_database() {
    local database=$1
    echo "Criando banco de dados '$database'..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        SELECT 'CREATE DATABASE $database'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database')\gexec
EOSQL
    echo "Banco de dados '$database' criado com sucesso!"
}

# Se POSTGRES_MULTIPLE_DATABASES for definido, cria os bancos adicionais
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Configurando múltiplos bancos de dados..."
    
    # Separar os bancos por vírgula
    IFS=',' read -ra DATABASES <<< "$POSTGRES_MULTIPLE_DATABASES"
    
    # Criar cada banco de dados
    for db in "${DATABASES[@]}"; do
        # Remove espaços em branco
        db=$(echo "$db" | xargs)
        
        # Não recriar o banco principal
        if [ "$db" != "$POSTGRES_DB" ]; then
            create_database "$db"
        fi
    done
    
    echo "Todos os bancos de dados foram configurados!"
fi