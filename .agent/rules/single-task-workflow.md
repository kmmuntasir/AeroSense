---
trigger: always_on
---

When a task is given, follow this workflow:
- Gather the requirements from the relevant JIRA/Trello card description and comments.
- If the requirements are not clear or ambiguous, ask for clarification to the user.
- If the task involves a Figma frame (link may be found in the description or comments), use the Figma MCP to get the data for that frame.
- The task needs to be started in it's own branch. Follow the git guidelines for creating a new branch if necessary. If you are already in the branch, skip this step. Never start the task in the 'main' or 'dev' branch.
- After gathering all the necessary requirements, when in the correct branch, analyze the repository and codebase, think about the solution, and create a plan containing step by step todo list of items to complete. Write the plan in the ./docs folder and ask for user review and wait for confirmation. DO NOT IMMEDIATELY START TO IMPLEMENT WITHOUT AUTHORIZATION.
- If the user suggests changes, implement the changes in the plan.
- Finally when the user approves and gives you explicitly the permission to start the implementation, move the Jira Ticket/Trello Card to "In Progress" status/column, then create a todo list in your context for this plan, and start implementing step by step.
- When the implementation is complete, make sure that relevant unit/widget test and integration tests are written properly.
- After completion, verify the implmentation against the original plan file created at the beginning and make sure that all the steps are completed and the implementation is correct.
- After verification, remove the plan file from the ./docs folder, commit the changes according to the git guidelines, then push to remote.
- Finally, move the Jira Ticket/Trello Card to the "In Review" column, and summarize the changes to the user, then stop.
