# EstudAI - Aplicativo de Ciclo e Registro de Estudos

Aplicativo completo para controle e otimização de estudos com suporte **Multiplataforma (Web e Android/APK)**, desenvolvido com **Frontend em Flutter** e **Backend em Kotlin (Spring Boot 3 + Java 21)**.

---

## ✨ Funcionalidades Principais

1. **Dois Tipos de Registro de Estudo**:
   - 📝 **Estudo por Questões**: Quantidade total de questões resolvidas, acertos, cálculo dinâmico da taxa de acerto (%) e tempo de estudo.
   - 📖 **Estudo por PDF / Material**: Título do material, página onde parou (checkpoint de leitura), páginas lidas na sessão e tempo de estudo.
2. **Ciclo de Estudos Inteligente**:
   - Organização e ordenação das disciplinas no ciclo.
   - **Sugestão Inteligente ("Continue de Onde Parou")**: Destaca automaticamente o último conteúdo estudado e a página/bloco de questões exato onde você parou, ou avança para a próxima disciplina da sequência.
3. **Cronômetro & Timer de Sessão**:
   - Cronômetro digital integrado em tempo real com iniciar, pausar, retomar, zerar e botões rápidos de incremento (+15m, +30m, +45m, +60m).
4. **Dashboard & Métricas de Desempenho**:
   - Horas totais acumuladas, total de questões e taxa geral de acerto, páginas lidas em PDFs, e progresso detalhado por matéria.
5. **Multiplataforma (Web & Android)**:
   - Interface responsiva Material 3 com suporte a tema claro e escuro, funcionando perfeitamente em navegadores Web e compilável para APK Android.

---

## 📂 Estrutura do Projeto

```
Estudai/
├── backend/               # Kotlin + Spring Boot 3 + Spring Data JPA + H2
│   ├── src/main/kotlin/com/estudai/
│   │   ├── controller/   # REST Controllers (/api/subjects, /api/sessions, /api/cycle, /api/dashboard)
│   │   ├── service/      # Regras de negócio, sugestão de ciclo e métricas
│   │   ├── model/        # Entidades JPA (Subject, StudySession, StudyType)
│   │   ├── repository/   # Repositórios JPA
│   │   ├── dto/          # Data Transfer Objects
│   │   └── config/       # CORS e Data Initializer (Seed Data)
│   └── build.gradle.kts
│
├── frontend/              # Flutter App (Web + Android)
│   ├── lib/
│   │   ├── models/       # Subject, StudySession, NextStudySuggestion, DashboardStats
│   │   ├── providers/    # StudyProvider (Gerenciamento de estado + Cronômetro)
│   │   ├── services/     # ApiService (Comunicação HTTP com o backend)
│   │   ├── theme/        # AppTheme (Material 3 + Dark/Light Mode)
│   │   ├── screens/      # Dashboard, Registro, Ciclo, Disciplinas, Histórico
│   │   └── widgets/      # Timer, Cards de Métricas, Hero Suggestion Card
│   └── pubspec.yaml
│
├── run_backend.bat        # Script para iniciar o Backend Kotlin
└── run_frontend.bat       # Script para iniciar o Frontend Flutter no Chrome
```

---

## 🚀 Como Executar

### 1. Iniciar o Backend em Kotlin
No terminal (ou executando o arquivo `run_backend.bat`):
```bash
cd backend
.\gradlew.bat bootRun
```
> O backend iniciará na porta **8080** com banco H2 automático e dados de exemplo já inseridos.  
> Console H2 disponível em: `http://localhost:8080/h2-console`

---

### 2. Iniciar o Frontend em Flutter (Web)
No terminal (ou executando o arquivo `run_frontend.bat`):
```bash
cd frontend
flutter run -d chrome
```

---

### 3. Gerar a APK para Android
Para gerar a APK instalável no celular Android:
```bash
cd frontend
flutter build apk --release
```
A APK gerada estará disponível em: `frontend/build/app/outputs/flutter-apk/app-release.apk`.
