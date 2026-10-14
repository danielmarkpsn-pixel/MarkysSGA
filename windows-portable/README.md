# MARKYS SGA — plano de execução portátil para Windows

> **Estado: preparação técnica; ainda não é um instalador pronto.** Este documento não afirma que o pacote foi compilado ou testado.

## Objetivo

Executar o MARKYS SGA num computador Windows principal e permitir que outros computadores da mesma rede local acedam pelo navegador, sem instalar Docker Desktop.

## Por que não basta copiar o projeto

O repositório atual depende de PHP 8.2+, Symfony, Composer, PostgreSQL e Mercure. O Dockerfile usa **FrankenPHP com Caddy e a diretiva Mercure**, e o `compose.yaml` atual define PostgreSQL e Mercure, mas não define um serviço para a aplicação. O runtime e as chamadas em tempo real precisam de uma solução compatível com Windows antes de ser possível distribuir um ZIP confiável.

Não use os scripts de desenvolvimento do Docker Compose como se fossem um instalador Windows. Um pacote só deverá ser anunciado como pronto depois de validar a inicialização, a instalação inicial, o login, a criação de atendimentos, as chamadas em tempo real em dois navegadores e a persistência após reiniciar o computador.

## Arquitetura pretendida

- **Servidor principal:** aplicação, PostgreSQL e hub Mercure.
- **Clientes da rede:** apenas navegador atualizado; não precisam de PHP nem de PostgreSQL.
- **Dados:** diretório persistente separado dos binários e do código.
- **Rede:** IP reservado no roteador ou endereço fixo, portas liberadas somente na rede privada e senha de administrador exclusiva.
- **Backup:** cópia consistente do banco de dados e dos arquivos de configuração; manter pelo menos uma cópia em outro disco ou local protegido.

## Próximas etapas para criar um pacote real

1. Escolher e testar um runtime de aplicação nativo para Windows compatível com o projeto Symfony e as dependências atuais.
2. Preparar PostgreSQL para Windows e configurar armazenamento persistente.
3. Preparar um hub Mercure compatível com Windows e configurar URLs internas e públicas para o IP do servidor.
4. Instalar as dependências PHP de produção e gerar chaves/segredos exclusivos para essa instalação.
5. Automatizar a primeira instalação e a criação do usuário administrador sem gravar senhas no repositório.
6. Criar inicializador e encerramento seguros, verificação de portas e backup/recuperação.
7. Testar em Windows limpo e em pelo menos dois computadores da rede antes de publicar o ZIP.

## Segurança

- Não exponha PostgreSQL diretamente à rede de clientes.
- Não reutilize os segredos de exemplo do arquivo `.env`.
- Não publique senhas, chaves privadas ou backups com dados reais no GitHub.
- Restrinja as regras do Firewall do Windows ao perfil de rede privada.
- Use dados fictícios durante os testes de instalação.

## Diagnóstico inicial

Execute `verificar-requisitos.ps1` no computador que será o servidor para registrar a versão do Windows, o IP local e o estado das portas habituais. O diagnóstico não instala componentes nem altera o Firewall.
