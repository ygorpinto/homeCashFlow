# 💰 Home Cash Flow

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)

**Organize suas finanças, visualize seus gastos, e alcance seus objetivos financeiros**

[Funcionalidades](#-funcionalidades) •
[Instalação](#-instalação) •
[Tecnologias](#-tecnologias) •
[Estrutura](#-estrutura-do-projeto) •
[Contribuição](#-como-contribuir) •
[Licença](#-licença)

</div>

## 📋 Sobre o Projeto

**Home Cash Flow** é um aplicativo completo para gestão de finanças pessoais desenvolvido em Flutter, projetado para ajudar você a:

- 📊 Visualizar suas finanças de forma clara e intuitiva
- 💸 Acompanhar receitas e despesas em tempo real
- 📅 Analisar gastos semanais e mensais
- 🏷️ Categorizar transações para melhor organização
- 📱 Acessar seus dados em qualquer dispositivo (mobile, web ou desktop)

Uma solução elegante e completa para quem busca ter controle total sobre sua vida financeira, com interface moderna e amigável.

## ✨ Funcionalidades

### 🔍 Visão Geral na Tela Home
- Visualização do saldo atual
- Resumo rápido de receitas e despesas
- Lista das transações mais recentes

### 💵 Gerenciamento de Transações
- Cadastro fácil de receitas e despesas
- Categorização por tipo (Alimentação, Transporte, etc.)
- Descrições detalhadas para cada transação
- Organização por data para fácil acompanhamento

### 📊 Análises Visuais
- Visualização semanal com resumo financeiro
- Visualização mensal com gráficos de categorias
- Acompanhamento de tendências de gastos

### 🌐 Multi-plataforma
- Disponível para Android e iOS
- Versão web para acesso pelo navegador
- Suporte para Windows, macOS e Linux

## 🚀 Instalação

### Pré-requisitos
- Flutter SDK (3.0.0 ou superior)
- Dart SDK (3.0.0 ou superior)
- Git

### Passos para Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/home-cash-flow.git

# Entre na pasta do projeto
cd home-cash-flow

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run
```

### Executando em Diferentes Plataformas

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos
```

## 🛠️ Tecnologias

### Principais Ferramentas
- **Flutter**: Framework de UI multiplataforma do Google
- **Dart**: Linguagem de programação otimizada para aplicativos em múltiplas plataformas

### Pacotes e Bibliotecas
- **Provider**: Gerenciamento de estado eficiente
- **SQLite**: Armazenamento local para dispositivos móveis e desktop
- **Shared Preferences**: Armazenamento simples para a versão web
- **FL Chart**: Visualizações de dados interativas
- **Google Fonts**: Tipografia de alta qualidade
- **Intl**: Internacionalização e formatação de data/número
- **Flutter Slidable**: Ações deslizantes em listas

## 📁 Estrutura do Projeto

```
home_cash_flow/
├── lib/                       # Código fonte principal
│   ├── main.dart              # Ponto de entrada da aplicação
│   ├── models/                # Modelos de dados
│   │   └── transaction.dart   # Modelo de transação financeira
│   ├── screens/               # Telas da aplicação
│   │   ├── home_screen.dart   # Tela principal
│   │   ├── add_transaction_screen.dart  # Tela de adicionar transação
│   │   ├── monthly_screen.dart  # Visualização mensal
│   │   └── weekly_screen.dart   # Visualização semanal
│   └── services/              # Serviços e provedores
│       ├── database_service.dart  # Serviço de banco de dados
│       ├── web_storage_service.dart  # Serviço para armazenamento web
│       └── transaction_provider.dart  # Provedor de dados de transação
├── assets/                    # Recursos estáticos
│   └── images/                # Imagens e ícones
└── test/                      # Testes unitários e de integração
```

## 🤝 Como Contribuir

Agradecemos seu interesse em contribuir para o projeto! Aqui estão algumas formas de ajudar:

1. **Abra Issues**: Reporte bugs ou sugira novas funcionalidades
2. **Envie Pull Requests**: Contribua com correções ou implementações
3. **Compartilhe o Projeto**: Ajude-nos a alcançar mais desenvolvedores

### Processo para Contribuir

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Faça commit das mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Envie para o GitHub (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE) - veja o arquivo LICENSE para mais detalhes.

---

<div align="center">

**Desenvolvido com ❤️ para facilitar sua vida financeira**

[⬆ Voltar ao topo](#-home-cash-flow)

</div>
