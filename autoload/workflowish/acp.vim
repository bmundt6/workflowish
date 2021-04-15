" complete tags
fun! workflowish#acp#meetsForWorkflowishTag(context)
  let g:acp_behaviorWorkflowishTagLength = get(g:, 'acp_behaviorWorkflowishTagLength', 0)
  if g:acp_behaviorWorkflowishTagLength < 0
    return 0
  endif
  let matches = matchlist(a:context, '#\(\k\{' . g:acp_behaviorWorkflowishTagLength . ',}\)$')
  return !empty(matches)
endfun

fun! workflowish#acp#completeWorkflowishTag(findstart, base)
  if a:findstart
    let current_text = strpart(getline('.'), 0, col('.') - 1)
    return match(current_text, '#\k*$')
  endif
  let tags = []
  let len = len(tags)
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 1)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 2)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 3)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 4)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 5)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 6)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 7)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 8)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 9)]
  g/#\k\+/let tags += [matchstr(getline('.'), '#\k\+', 0, 10)]
  "TODO filter only matching tags
  return tags
endfun
