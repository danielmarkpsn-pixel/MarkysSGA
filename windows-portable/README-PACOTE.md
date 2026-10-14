# MARKYS SGA — pacote portátil para Windows

Este ZIP é montado pelo GitHub Actions a partir do código do repositório e de runtimes oficiais para Windows. O primeiro computador é o servidor; os demais usam apenas o navegador.

## Primeira instalação

1. Baixe e extraia todo o ZIP numa pasta local, por exemplo `C:\MARKYS-SGA` (não execute dentro do ZIP).
2. No computador servidor, clique com o botão direito em `INSTALAR-MARKYS.ps1` e escolha executar com PowerShell. Se a política do Windows bloquear, abra PowerShell na pasta e execute `powershell -ExecutionPolicy Bypass -File .\INSTALAR-MARKYS.ps1`.
3. O instalador cria dados locais e segredos. Não apague `.env.local` nem a pasta `data`.
4. Execute `INICIAR-MARKYS.bat`. Se ocorrer erro, copie a mensagem completa para suporte.
5. A instalação inicial do NovoSGA ainda exige criar o usuário administrador e a unidade pelo comando `novosga:install`. O pacote não deve ser usado com dados reais antes de essa etapa ser validada.
6. Para outros computadores, descubra o IPv4 do servidor com `ipconfig` e abra `http://IP-DO-SERVIDOR:8080` no navegador. Configure uma reserva DHCP no roteador e uma regra do Firewall restrita à rede privada.

## Importante

- Estado: pacote experimental; deve ser validado em um Windows limpo antes de uso clínico/produção.
- Não exponha a porta 5432 à rede. Só o servidor web deve estar acessível aos clientes.
- Faça backups regulares de `data\postgres`, `.env.local` e `config\jwt`. Para um backup PostgreSQL consistente, use `pg_dump`; não copie a pasta de dados enquanto o banco estiver em execução.
- O servidor deve estar ligado para os outros computadores acessarem o sistema.
