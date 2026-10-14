# Configuração da rede local — MARKYS SGA

Este guia é para a futura instalação no computador principal. **Não abra portas antes de concluir e testar a configuração.**

## 1. Preparar o computador principal

1. Use um computador que permaneça ligado durante o expediente.
2. Conecte-o à rede local por cabo, se possível.
3. No roteador, reserve um endereço IP para esse computador (reserva DHCP). Não escolha um IP aleatório.
4. Use uma conta Windows com senha e mantenha o sistema atualizado.
5. Extraia o pacote para uma pasta local, por exemplo `C:\MARKYS-SGA`; evite pastas sincronizadas em nuvem ou unidades de rede.

## 2. Clientes

Os outros computadores acessam o endereço do servidor pelo navegador, por exemplo `http://192.168.1.50:8080`. **Esse endereço é apenas um exemplo**: use o IP real exibido no diagnóstico e a porta que for definida na configuração final.

Os computadores clientes não devem executar cópias independentes do banco de dados. Todos precisam apontar para o mesmo servidor.

## 3. Firewall

Depois de confirmar a porta HTTP final, crie uma regra de entrada limitada ao perfil **Privado** e à rede local. Não exponha a porta do PostgreSQL (normalmente 5432) aos clientes. O hub Mercure também precisa de configuração de origem e autenticação apropriadas para os endereços usados na LAN.

Não habilite regras para redes públicas e não encaminhe portas no roteador para a internet.

## 4. Primeiro acesso e segurança

- Gere `APP_SECRET`, chaves OAuth e segredos Mercure exclusivos.
- Não use os segredos de exemplo do repositório.
- Crie a conta administradora durante a instalação inicial.
- Use dados fictícios até concluir os testes.
- Confirme login, criação de atendimento, chamadas ao vivo em dois computadores e persistência depois de reiniciar os serviços.

## 5. Backup e recuperação

O backup precisa incluir um dump consistente do PostgreSQL e os arquivos de configuração necessários para restaurá-lo. Guarde pelo menos uma cópia em outro disco ou local protegido. Teste a restauração antes de usar dados reais.

## 6. Critério para considerar pronto

Não declare a instalação pronta até validar em Windows limpo:
- inicialização e encerramento;
- instalação/migrações e login;
- dois ou mais navegadores na LAN;
- atualização de chamadas em tempo real;
- dados preservados após reinício;
- backup e restauração;
- regras de firewall limitadas à rede privada.
