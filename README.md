# MARKYS SGA

**Sistema de gerenciamento de filas e atendimento**

O **MARKYS SGA** é uma versão personalizada baseada no projeto de código aberto [NovoSGA](https://github.com/novosga/novosga), destinada à adaptação da identidade visual, configuração e evolução do sistema conforme as necessidades da MARKYS.

> **Aviso:** este repositório está em processo de personalização. A disponibilidade de recursos e o funcionamento em ambiente de produção devem ser validados após a instalação e os testes.

## Sobre o projeto

O objetivo do MARKYS SGA é servir como base para organizar o atendimento por senhas e filas, com possibilidade de futuras adaptações para o fluxo de trabalho da organização.

Este projeto deriva do NovoSGA, criado originalmente por Rogério Lino em 2012 e desenvolvido com contribuições da comunidade. A personalização deste repositório não representa, por si só, uma versão oficial do NovoSGA.

## Situação atual

- [x] Repositório próprio para personalizações da MARKYS.
- [x] Documentação inicial em português.
- [ ] Revisão da identidade visual e dos nomes exibidos no sistema.
- [ ] Validação da instalação e das dependências no ambiente de destino.
- [ ] Testes dos fluxos de filas, chamadas e atendimento.
- [ ] Documentação específica de instalação e configuração da versão MARKYS.

Os itens pendentes devem ser marcados como concluídos somente depois de implementados e testados.

## Tecnologias e dependências

O código-base utiliza PHP e componentes do ecossistema Symfony. Consulte o arquivo [composer.json](composer.json) para verificar as dependências e os requisitos definidos pela versão presente neste repositório.

## Instalação e documentação

Como esta versão está sendo adaptada, utilize primeiro a documentação do projeto original como referência e confira os requisitos da versão existente neste repositório:

- [Documentação oficial do NovoSGA](https://novosga.org/docs/)
- [Código-fonte original do NovoSGA](https://github.com/novosga/novosga)
- [Dependências do MARKYS SGA](composer.json)

As instruções definitivas de instalação, configuração de banco de dados, servidor web e execução serão registradas aqui depois de verificadas para esta cópia.

## Personalização MARKYS

As alterações específicas da MARKYS serão documentadas à medida que forem implementadas. Este README não afirma que recursos ainda não testados estejam disponíveis.

## Créditos e licença

O MARKYS SGA é uma adaptação independente baseada no [NovoSGA](https://github.com/novosga/novosga).

Créditos do projeto original: **Rogério Lino e comunidade de colaboradores do NovoSGA**.

O projeto original é distribuído sob a licença MIT. O aviso de copyright e o texto da licença abaixo são mantidos para respeitar os termos aplicáveis ao código derivado.

### Licença MIT

```text
Copyright (c) 2012-present Rogerio Lino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

---

**MARKYS SGA** — personalização independente do NovoSGA.
