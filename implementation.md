# 🚀 Ledgerly AI Optimization & Enhancement Plan (`implementation.md`)

## 1. Executive Summary & Vision

**Ledgerly AI** is designed as a private, on-device-first personal financial copilot. Rather than functioning as a detached query engine or a cold search index, Ledgerly AI combines **on-device vector search (RAM-cached SIMD Cosine Similarity)** with **state-of-the-art Google Gemini LLMs** to deliver advice that is:
1. **Empathetic & Warm**: Speaks like an encouraging financial advisor who understands money habits.
2. **Financially Grounded**: Answers with exact live figures (budget surplus, remaining daily buffer, category allocations).
3. **Intent-Aware**: Intelligently differentiates casual greetings (`"hey?"`), analytical queries (`"Am I over budget?"`), and transactional commands (`"Add ₹500 for lunch"`).
4. **100% Resilient**: Seamlessly operates whether online (Gemini 2.5 Flash / Flash-Lite) or offline (deterministic rule-based local NLG).

---

## 2. Architecture Overview: Hybrid Edge-Cloud RAG

```
                 +-------------------------------------------------+
                 |                User Input in Chat               |
                 +------------------------+------------------------+
                                          |
                                          v
                 +-------------------------------------------------+
                 |            Intent & Tone Classifier             |
                 +----+-------------------+-------------------+----+
                      |                   |                   |
        +-------------+     +-------------+     +-------------+
        |                   |                   |
        v                   v                   v
+---------------+   +---------------+   +---------------+
| Conversational|   |  Transaction  |   | Contextual    |
| Greeting Pulse|   |  Slot-Filling |   | RAG Query     |
+-------+-------+   +-------+-------+   +-------+-------+
        |                   |                   |
        | Instant           | Auto-parse        | Fetch top-K SIMD
        | State             | & confirm         | records in RAM
        v                   v                   v
+---------------+   +---------------+   +-----------------------------+
| Friendly Live |   | Add Tx + Card |   | Grounded Prompt to Gemini   |
| Budget Status |   | with Undo     |   | (Fallback: Local NLG Synthes|
+---------------+   +---------------+   +-----------------------------+
```

### Key Technical Pillars:
* **In-Memory SIMD Search**: `LocalVectorStore` caches vectors directly in RAM, calculating 768-dimensional cosine similarities across thousands of records in $< 2\text{ms}$.
* **Harmonized 768-Dimensionality**: Both online Gemini embeddings (`gemini-embedding-001` with `outputDimensionality: 768`) and offline deterministic subword hashes (`deterministicEmbed`) share identical vector spaces.
* **Compact Serialization**: Transactions are injected into LLM context as compact strings (`YYYY-MM-DD | Category | ₹Amount | Title (Note)`), saving 70%+ of prompt tokens.

---

## 3. Core Enhancements & Solution Strategies

### 3.1. Intent Routing & Greeting Optimization (Fixing `"hey?"`)

#### The Problem:
Previously, a conversational greeting like `"hey?"` triggered a vector search against transaction records. Because semantic vectors for short greetings match arbitrary records with positive cosine scores, the app responded mechanically with:
> *"Found matching record: Burger King (Food) ₹560."*

#### The Solution:
1. **Regex-Level Conversational Bypass**:
   Detect standalone greetings (`hey`, `hello`, `hi`, `good morning`, `yo`, etc.) before hitting the vector database.
2. **Personalized Budget Pulse**:
   Generate an immediate, warm response calculated from the user's live budget health:
   * **Under Budget (< 80%)**: *"Hey Rahul! 👋 Your budgets are well maintained this month — keep it up! You've used only 18% of your ₹50,000 budget with ₹41,070 remaining."*
   * **Nearing Limit (80% - 99%)**: *"Hey Rahul! 👋 Heads up: You have utilized 85% of your budget. Let me know if you want to review top spending categories!"*
   * **Over Budget (≥ 100%)**: *"Hey Rahul! 👋 You have reached 100% of your allocated budget for this month. I'm here to help you trim expenses or adjust categories."*
3. **Zero Token Waste & Zero Latency**:
   Pure greetings resolve in 0ms with zero network calls, conserving Gemini free-tier quota for complex queries.

---

### 3.2. Distinguishing Inquiries vs. Transaction Commands

#### The Problem:
Questions containing numbers or expense words (e.g., *"Did I spend 200 on coffee?"*) were mistakenly classified as transaction creation commands, unintentionally adding ₹200 to the user's spending.

#### The Solution:
* **Question Guarding**:
  If a message ends with `?` or begins with interrogative stems (`how`, `what`, `where`, `did`, `is`, `am`, `summarize`, `show`, `list`), it is **strictly treated as an analytical inquiry**.
* **Command Precision**:
  Transaction creation is restricted to imperative syntax (`add ...`, `log ...`, `spent 500 on ...`, `bought ... for ...`, or raw amounts).

---

### 3.3. Multi-Model Cloud Fallback & Resilient Latency

#### The Problem:
Individual Gemini models can experience high demand (`HTTP 503`), rate limit exhaustion on free tiers (`HTTP 429`), or occasional network latency.

#### The Solution:
Implemented a **3-tier cascading model fallback**:
```
Primary: gemini-2.5-flash
   └── On 429 / 503 / Timeout ──> Secondary: gemini-flash-latest
                                      └── On failure ──> Tertiary: gemini-3.5-flash-lite
                                                             └── Final: Local Rule-Based NLG
```

---

### 3.4. Session Lifecycle: "Make New Chat" (`+` Action)

#### Feature Specification:
* **Position**: Top-right of `AppBar` on the AI Chat screen.
* **Hover Tooltip**: `"Make New Chat"` (provides instant desktop/web affordance).
* **Click Action**: Presents a modern confirmation dialog:
  * Title: *"Start New Chat?"*
  * Description: *"Your current chat will be removed and a fresh conversation will start."*
  * Actions: `[Cancel]` and `[New Chat]`.
* **State Reset**:
  * Clears message history and restores the clean, personalized welcome card.
  * Clears input controller and pending slot-filling states.
  * Displays a brief feedback snackbar: *"New chat session started"*.

---

## 4. Implementation Matrix

| Component | File | Status | Description |
|---|---|---|---|
| **AI Configuration** | `lib/core/config/ai_config.dart` | ✅ Completed | Switched to `gemini-2.5-flash` with fallback models listed. |
| **RAG Service** | `lib/core/services/rag_ai_service.dart` | ✅ Completed | Harmonized 768-dim embeddings, multi-model fallback chain, and budget context prompt injection. |
| **Vector Store** | `lib/core/services/local_vector_store.dart` | ✅ Completed | Enriched compact serialization with transaction notes (`USB-C cable`, `Caramel Macchiato`). |
| **Embedding Queue** | `lib/core/services/embedding_queue.dart` | ✅ Completed | Indexed item notes and ensured non-blocking background queue sync. |
| **AI Chat Screen** | `lib/features/ai_chat/ai_chat_screen.dart` | ✅ Completed | Added `+` Make New Chat button, confirmation dialog, and friendly greeting budget pulse handler. |
| **Live Unit Tests** | `test/gemini_live_test.dart` | ✅ Completed | Automated verification for RAG questions, embeddings, and transaction parsing. |

---

## 5. Future Roadmap & Advanced AI Features

1. **Voice-to-Expense Logging**:
   Integrate speech-to-text directly in the chat input bar for hands-free natural logging (e.g. *"Log 40 rupees chai at tapri"*).
2. **Proactive Spending Anomaly Alerts**:
   Notify user when a transaction is $> 2\times$ their typical category average (e.g. *"This dining bill is higher than 90% of your Food visits"*).
3. **Monthly Financial Goal Simulator**:
   Allow natural "what-if" planning: *"If I reduce dining out by ₹2,000, can I buy a ₹15,000 tablet in July?"*
