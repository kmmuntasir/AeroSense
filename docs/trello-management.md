# Trello Board Structure: AeroSense MVP

## 1. Lists (Columns)
Set up your board with these lists from left to right:
1. **Project Reference:** API docs, design assets, and high-level Epic descriptions.
2. **Product Backlog:** All pending User Stories and Foundational Tasks.
3. **To Do (Next Up):** The 2-3 cards queued up for immediate development.
4. **In Progress:** The 1-2 cards you are actively coding.
5. **Done:** Completed, tested, and merged features.

---

## 2. Labels (Epics & Categories)
Press `L` on your keyboard to create and apply these labels:
* 🔴 **Red:** `Core/Foundation` (Tasks 1, 2, 3)
* 🔵 **Blue:** `Epic 1: Onboarding`
* 🟢 **Green:** `Epic 2: Core Weather`
* 🟡 **Yellow:** `Epic 3: Location Mgmt`
* 🟣 **Purple:** `Epic 4: Settings`

---

## 3. Card Templates

### Template A: Foundational Tech Tasks
*Use this for broad architectural tasks (Tasks 1, 2, and 3) that don't fit a specific user story.*

**Title:** `[Task Number]: [Task Name]` (e.g., *Task 1: Project Setup & Foundation*)
**Label:** 🔴 `Core/Foundation`
**Description:**
> **Description:** [Paste the description from the task list]
> **Dependencies:** [List dependencies]
**Checklist (Action Items):**
* [ ] [Paste bulleted action items here as checkable tasks]

### Template B: User Story Cards
*Use this for all product features. The User Story is the Card; the Technical Tasks are the Checklist.*

**Title:** `[US Number]: [Feature Name]` (e.g., *US 1.1: Requesting Location Permission*)
**Label:** [Match to specific Epic color]
**Description:**
> **As a** [user type],
> **I want** [action/feature],
> **So that** [value/benefit].
> 
> **Interaction & Steps:**
> [Paste the steps and UI changes from the user story]
**Checklist (Dev Tasks):**
* [ ] [Extract and paste the relevant bulleted action items from the corresponding Technical Task (Tasks 4-10)]