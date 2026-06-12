# Ruby Lab: AI + Human Handshake

> **Duration:** 3 hours | **Level:** Beginner–Intermediate Ruby
>
> **Objective:** Experience the full spectrum of Ruby development — writing it solo, debugging AI-generated code, and building a real tool by collaborating with AI.

---

## Prerequisites

Before the session starts, make sure you have ruby installed on your machine by using `asdf`.

## Schedule

| Time          | Duration | Phase                                  |
| ------------- | -------- | -------------------------------------- |
| 13:00 – 13:45 | 45 min   | Phase 1: Pure Human — Grade Calculator |
| 13:45 – 14:30 | 45 min   | Phase 2: The AI Audit — Bank Account   |
| 14:30 – 14:45 | 15 min   | Break                                  |
| 14:45 – 15:45 | 60 min   | Phase 3: Architect Mode — Event Router |
| 15:45 – 16:00 | 15 min   | Phase 3: Architect's Debrief           |

---

## Phase 1 — Pure Human: Grade Calculator

**Time:** 13:00 – 13:45 (45 minutes)

### Rules

- **No AI.** No ChatGPT, no Copilot, no suggestions.
- You may use [ruby-doc.org](https://ruby-doc.org) for syntax lookups only.
- Work individually.

### Task

Build a command-line Grade Calculator in Ruby. The program should:

1. Ask the user how many scores they want to enter.
2. Collect each score as input (numbers between 0 and 100).
3. Calculate and display:
   - The **average** score
   - The **letter grade** based on the average
   - The **highest** and **lowest** scores

### Grading Scale

| Average  | Letter Grade |
| -------- | ------------ |
| 90 – 100 | A            |
| 80 – 89  | B            |
| 70 – 79  | C            |
| 60 – 69  | D            |
| Below 60 | F            |

### Expected Terminal Output

```
How many scores? 4
Enter score 1: 88
Enter score 2: 72
Enter score 3: 95
Enter score 4: 60

Results:
  Average : 78.75
  Grade   : C
  Highest : 95
  Lowest  : 60
```

> **Need a hint?** Run `ruby lab_hints.rb` in your terminal.

---

## Phase 2 — The AI Audit: Bank Account Bug Hunt

**Time:** 13:45 – 14:30 (45 minutes)

### Background

A developer used AI to generate a `BankAccount` class in Ruby. The AI made **5 mistakes** — 2 syntax errors and 3 logic flaws. Your job is to find and fix all 5.

### Task

1. Open the file `bank_account_buggy.rb`.
2. Read through the code carefully.
3. For each bug you find, add a comment above the line in this format:

```ruby
# BUG [number]: [what is wrong] → FIX: [what it should be]
```

4. Fix the code so that it runs correctly.
5. Test it by running `ruby bank_account_buggy.rb` — it should produce sensible output with no errors.

### What to Look For

There are exactly:

- **2 syntax errors** — Ruby will refuse to run the file at all until these are fixed.
- **3 logic flaws** — Ruby will run but produce wrong results (wrong numbers, or no protection against bad states).

### Answer Checklist (fill in after you find each one)

| #   | Type   | Line (approx.) | Description |
| --- | ------ | -------------- | ----------- |
| 1   | Syntax |                |             |
| 2   | Syntax |                |             |
| 3   | Logic  |                |             |
| 4   | Logic  |                |             |
| 5   | Logic  |                |             |

### Expected Correct Output (after all fixes)

```
=== Account Info ===
Owner  : Alice
Balance: $1000.00

Depositing $500...
  New balance: $1500.00

Withdrawing $200...
  New balance: $1300.00

Applying 5% interest...
  New balance: $1365.00

Attempting to overdraw $2000...
  Error: Insufficient funds. Balance: $1365.00
```

---

## Break

**14:30 – 14:45** — Step away from the screen, get some water.

---

<!-- look at this file first before start solving phase 3 .lab_config -->

## Phase 3 — Architect Mode: The Smart Event Router

**Time:** 14:45 – 15:45 (60 minutes)

### Concept

You are the architect. AI is your intern. Before writing a single line of code, design the system on paper — then direct AI to implement each piece and reject anything that violates the design.

### Design Patterns & Principles

This phase applies two classic patterns in combination:

| Pattern      | Role in this system                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------ |
| **Observer** | `EventRouter` notifies all registered handlers when an event fires                               |
| **Strategy** | Each `Handler` subclass is a swappable algorithm — add or remove one without touching the router |

Both patterns are held together by **SOLID**:

| Letter | Principle             | One-liner                                                      |
| ------ | --------------------- | -------------------------------------------------------------- |
| **S**  | Single Responsibility | One class, one reason to change                                |
| **O**  | Open / Closed         | Extend by adding classes, not editing existing ones            |
| **L**  | Liskov Substitution   | All handlers are interchangeable                               |
| **I**  | Interface Segregation | `Handler` has exactly one method                               |
| **D**  | Dependency Inversion  | `EventRouter` depends on the abstraction, never on concretions |

### Architecture

```
              ┌──────────────────────────────────────────┐
              │              EventRouter                 │
              │   handlers: [Handler, Handler, ...]      │
              │   dispatch(event) → calls each handler   │
              └──────────────────┬───────────────────────┘
                                 │  knows only Handler (D)
          ┌──────────────────────┼───────────────────────┐
          ▼                      ▼                       ▼
  ┌───────────────┐    ┌──────────────────┐    ┌──────────────────┐
  │ ConsoleHandler│    │   FileHandler    │    │  <YourHandler>   │
  │  prints event │    │ appends to log   │    │  Stats / HTML /  │
  │  to terminal  │    │      file        │    │  SQLite (O)      │
  └───────────────┘    └──────────────────┘    └──────────────────┘
        one job each (S) — interchangeable (L) — lean interface (I)
```

### The Brief

You are building **LifeTrack** — a CLI tool that lets users log life events (work sessions, study blocks, workouts, meals) and reacts to each one through a pluggable pipeline of outputs. The app should feel like this:

```
=== LifeTrack ===
1. Log a work session
2. Log a study session
3. Log an exercise session
4. Log a meal
5. Exit

Choose an option: 2
Description: Deep work on Ruby SOLID principles
Duration (minutes): 45

[2026-06-03 14:51] STUDY — Deep work on Ruby SOLID principles (45 min)
✓ Event logged.
```

Every time an event is logged, **all registered outputs fire simultaneously** — a terminal print, a log file append, and your own third output of choice. None of them know the others exist.

---

### Design Challenge

Answer these on paper before opening your editor. There are no answers written in this lab — the hints file is your only lifeline.

> **What data does a single life event need to carry?** Think about what every output will need to know. Write the fields down.

> **You want to print an event AND write it to a file at the same time, without putting both in the same class.** How do you structure that?

> **What is the one thing every output must have in common** so the router can call them all without knowing which specific output it is talking to?

> **If adding a new output requires opening and editing the router — which SOLID principle breaks, and how does the architecture diagram above prevent that?**

---

### Build It

The architecture diagram and the brief above are your spec. Choose your own file names, class names, and method signatures.

**The system must satisfy all of these — verify before submitting:**

- [ ] A single dispatched event triggers every registered output simultaneously
- [ ] The router never references any output by name — only the shared interface
- [ ] Adding a new output means creating one new file; nothing existing changes (except the entry-point wiring)
- [ ] Each output class does exactly one thing and has no knowledge of the others
- [ ] The shared interface enforces its contract at runtime — a class that forgets to implement it must fail loudly, not silently

**Your third output — pick one:**

| What to build        | The hard constraint                                               |
| -------------------- | ----------------------------------------------------------------- |
| A statistics summary | Must fire automatically on exit — the menu loop must not call it  |
| An HTML dashboard    | Must regenerate the full page on every single event               |
| A SQLite log         | Must survive between runs — past sessions visible on next startup |

---

### Bonus — The Architect's Test

Your product manager just asked for Slack notifications on every logged event. **Before writing any code**, write your answers to these:

> 1. What would you name the new class and where would it live?
>    - **Class Name**: `LifeTrack::Handlers::SlackHandler`
>    - **Location**: `lib/lifetrack/handlers/slack_handler.rb`
> 2. What is the one method it must implement?
>    - It must implement the `#handle(event)` method.
> 3. List every existing file you would open to plug it in.
>    - Only `lifetrack.rb` (the entry point where we configure which plugins to use).
> 4. If that list includes the router or the shared interface — stop. Name the violated principle and fix the design before touching any code.
>    - None of those files are opened! If we had to modify them, it would violate the **Open/Closed Principle (OCP)**, which dictates that modules should be open for extension but closed for modification.

---

### Setup

```bash
gem install sqlite3   # only needed if you pick the SQLite log output
```

> **Need a hint?** Run `ruby lab_hints.rb` in your terminal.

---

### SOLID Self-Check

- [x] **S** — Each class has exactly one reason to change. Your terminal output class has no file I/O in it. Your router has no menu logic in it.
- [x] **O** — You added your third output by creating one new file. You did not open the router to do it.
- [x] **L** — You can swap any one output for another in the registered list and the router still works without modification.
- [x] **I** — The shared interface has exactly one method. No output is forced to implement something it does not use.
- [x] **D** — Open your router file. Search for any concrete output class name. The result must be zero.

---

### Architect's Debrief

**Time:** 15:45 – 16:00

Pick **one** question and explain your answer to the group in 1–2 minutes. Open your actual code — point to the line.

**On design:**

- Open your router file live. How many concrete output class names appear in it? Why must that number be zero?
- Walk through adding your third output: which files did you create, which did you edit? What does that count tell you about Open/Closed?
- Swap your terminal output for your third output in the registered list. Does everything still work? Which principle guarantees it?
- Point to where **Observer** lives in your code, then point to where **Strategy** lives. Are they the same place or different?

**On Ruby:**

- Show a one-liner using `.map`, `.select`, or `.each` from your code — explain what it does
- Show how string interpolation `"#{...}"` works and where it can silently break (hint: Phase 2 had one)
- Explain what `NotImplementedError` does in your shared interface and what happens if you delete that line
- Show how you structured your data class — what does it carry, and what does it deliberately _not_ do?

**On trade-offs:**

- Compare with a neighbour who picked a different third output. Which was harder to add, and why?
- Your event data class has no idea how it gets stored or displayed. Is that always the right decision? When would you break that rule?

---

## Submission

### Phase 1 & Phase 2 — Due during the lab session

Both phases must be submitted before the lab session ends. No late submissions accepted.

- [ ] `grade_calculator.rb` — Phase 1 _(submit by end of Phase 1 slot: 13:45)_
- [ ] `bank_account_buggy.rb` — Phase 2 with bug comments and fixes applied _(submit by end of Phase 2 slot: 14:30)_

### Phase 3 — Due by end of day

Phase 3 must be pushed to a **public GitHub repository** and submitted by **end of day (23:59)** on the day of the lab.

- [ ] Public GitHub repo created and shared
- [ ] Phase 3 — working CLI that logs events and fans them out to at least three outputs
- [ ] Phase 3 — SOLID Self-Check filled in (all five boxes ticked)
- [ ] Phase 3 — Bonus Architect's Test written answers included

---

_Good luck — and remember: understanding the code matters more than the number of lines you write._
