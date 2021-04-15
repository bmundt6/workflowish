" AutoComplPop integration
let g:acp_behavior = get(g:, 'acp_behavior', {})
let g:acp_behavior.workflowish = [
  \{'meets': 'acp#meetsForSnipmate', 'completefunc': 'acp#completeSnipmate', 'onPopupClose': 'acp#onPopupCloseSnipmate', 'repeat': 0, 'command': "\<C-x>\<C-u>"},
  \{'meets': 'acp#meetsForKeyword', 'repeat': 0, 'command': "\<C-n>"},
  \{'meets': 'acp#meetsForFile', 'repeat': 1, 'command': "\<C-x>\<C-f>"},
  \{
    \'meets': 'workflowish#acp#meetsForWorkflowishTag',
    \'command': "\<C-x>\<C-u>",
    \'completefunc': "workflowish#acp#completeWorkflowishTag",
    \'repeat': 0,
  \},
\]
