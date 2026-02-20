# Relational Trello Board Structure: AeroSense MVP

## 1. The Lists (Columns)
Set up your board with these exact lists, reading left to right.

**Static Directories (These cards never move):**
1. **📁 Epics:** High-level product goals.
2. **📄 Stories:** User-focused features.

**Active Pipeline (Tasks flow through these):**
3. **📦 Backlog:** All technical tasks waiting to be picked up.
4. **🎯 To Do:** Tasks queued for the current coding session.
5. **🏗️ In Progress:** Tasks you are actively writing code for.
6. **👀 In Review:** Code is written, pending testing/refactoring.
7. **✅ Done:** Fully completed and tested tasks.

---

## 2. The Labels
Use labels to track categories and mark static cards as complete.
* 🔵 **Blue:** `Epic 1: Onboarding`
* 🟢 **Green:** `Epic 2: Core Weather`
* 🟡 **Yellow:** `Epic 3: Location Mgmt`
* 🟣 **Purple:** `Epic 4: Settings`
* 🔴 **Red:** `Core/Foundation`
* 🟩 **Bright Green:** `Status: Delivered` *(Apply this to Epic and Story cards only when all their child tasks hit the "Done" list).*

---

## 3. Card Templates & Linking Strategy
*Pro-tip: Instead of just pasting URLs into the text description, click the **"Attachment"** button on the card and paste the Trello URL there. It creates a clean, clickable visual widget.*

### Template A: The Epic Card
**List:** 📁 Epics
**Title:** `[Epic Number]: [Epic Name]` (e.g., *Epic 1: Onboarding & First Launch*)
**Label:** 🔵 `Epic 1: Onboarding`
**Description:**
> **Overview:** > [Brief description of the Epic's goal]
>
> **🔗 Child Stories:**
> * [Attach Trello URL for Story 1.1]
> * [Attach Trello URL for Story 1.2]

### Template B: The Story Card
**List:** 📄 Stories
**Title:** `[US Number]: [Feature Name]` (e.g., *US 1.1: Requesting Location Permission*)
**Label:** 🔵 `Epic 1: Onboarding`
**Description:**
> **⬆️ Parent Epic:** [Attach Trello URL for Epic 1]
> 
> **User Story:**
> **As a** new user launching the app,
> **I want** to be prompted to grant location access,
> **So that** the app can automatically fetch my local weather.
> 
> **Interaction & Steps:**
> 1. User opens the installed app.
> 2. App displays OS permission dialog.
> 3. Transition to Dashboard (if granted) or Search (if denied).
> 
> **🔗 Child Tasks:**
> * [Attach Trello URL for Task 4.1 - Permission Logic]
> * [Attach Trello URL for Task 4.2 - Routing]

### Template C: The Task Card
**List:** Starts in 📦 Backlog -> Moves to ✅ Done
**Title:** `[Task Number]: [Technical Task]` (e.g., *Task 4.1: Implement LocationController Permission Logic*)
**Label:** 🔵 `Epic 1: Onboarding`
**Description:**
> **⬆️ Parent Story:** [Attach Trello URL for US 1.1]
> 
> **Technical Details:**
> * Integrate the native location permission prompt flow managed by `LocationController`.
> * Verify permissions using `geolocator`.
> * Handle exceptions if the user permanently denies access.