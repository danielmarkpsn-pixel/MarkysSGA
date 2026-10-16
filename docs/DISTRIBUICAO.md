# MARKYS SGA — arquitetura de distribuição

## Objetivo

Distribuir o NovoSGA 2.4 personalizado sem pedir ao usuário final que configure PHP, Composer ou PostgreSQL manualmente. A primeira entrega será validada em Docker Compose; depois será empacotada num instalador Windows com interface e atalho.

## Modos previstos

- **Online (principal):** aplicação e PostgreSQL num servidor gerenciado. Os computadores dos usuários acessam pelo navegador; o atalho pode abrir o endereço HTTPS. Exige internet e hospedagem.
- **Local/rede (alternativa):** aplicação e PostgreSQL num computador da organização. Outros computadores acessam pela rede local. O computador servidor precisa permanecer ligado; internet não é necessária depois de instalar as imagens e dependências.
- **Instalador Windows:** camada de conveniência que verifica pré-requisitos, instala/abre o ambiente local, cria atalho e oferece diagnóstico. Não será chamado de estável antes de testes em Windows limpo.

## Primeira execução com Docker Compose

1. Instale Docker Engine + Compose no servidor Linux ou Docker Desktop/WSL 2 no Windows compatível.
2. Copie .env.example para .env.
3. Troque APP_SECRET, POSTGRES_PASSWORD, DATABASE_URL e MERCURE_JWT_SECRET por valores exclusivos. A senha do DATABASE_URL deve corresponder a POSTGRES_PASSWORD.
4. Valide a configuração com:

   docker compose -f compose.yaml -f compose.production.yaml config

5. Inicie a pilha com:

   docker compose -f compose.yaml -f compose.production.yaml up -d --build

6. Confira os logs com:

   docker compose -f compose.yaml -f compose.production.yaml logs -f app database

7. Acesse http://localhost:8080 (ou a porta definida em APP_PORT). A configuração inicial do NovoSGA — criação de administrador e unidade — ainda precisa ser concluída e validada antes de uso real.

## Regras de segurança

- Nunca versione .env; somente .env.example pode ficar no Git.
- Não exponha a porta 5432 do PostgreSQL publicamente.
- Para uso online, configure HTTPS, domínio, firewall, backups automáticos e política de atualização no servidor antes de cadastrar dados reais.
- Para uso local em rede, limite o acesso ao segmento de rede confiável; não encaminhe a porta do sistema diretamente à internet.
- Faça backups consistentes do banco e teste a restauração periodicamente.
- Segredos incluídos no histórico Git devem ser considerados públicos e rotacionados; apagar o arquivo no commit atual não remove o histórico anterior.

## Critérios antes de marcar como estável

- [ ] docker compose config passa com .env de teste.
- [ ] Imagem da aplicação compila e inicializa em ambiente limpo.
- [ ] Migrações e comando de instalação do NovoSGA são documentados e validados.
- [ ] Login, criação de unidade, filas e chamadas são testados com dados fictícios.
- [ ] Reinício do servidor mantém os dados.
- [ ] Backup e restauração foram exercitados.
- [ ] Instalador Windows foi testado em uma máquina sem ferramentas de desenvolvimento.
- [ ] Atualização e rollback foram documentados.
