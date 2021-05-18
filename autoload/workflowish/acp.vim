" this file defines functions for AutoComplPop integration

fun! s:WordMeetsByPrefix(context, lengthvar, prefix)
  " echomsg 'WordMeetsByPrefix'
  " echomsg 'context = ' . a:context
  " echomsg 'lengthvar = ' . a:lengthvar
  " echomsg 'prefix = ' . a:prefix
  let minlength = get(g:, a:lengthvar, 0)
  " echomsg 'minlength = ' . string(minlength)
  if minlength < 0
    return 0
  endif
  let expr = a:prefix . '\(\k\{' . minlength . ',}\)$'
  " echomsg 'expr = ' . expr
  let matches = matchlist(a:context, expr)
  " echomsg 'matches = ' . string(matches)
  " echomsg 'empty(matches) = ' . string(empty(matches))
  return !empty(matches)
endfun

" complete tags
fun! workflowish#acp#meetsForWorkflowishTag(context)
  " echomsg 'meetsForWorkflowishTag'
  " echomsg 'context = ' . a:context
  return s:WordMeetsByPrefix(a:context, 'acp_behaviorWorkflowishTagLength', '#')
endfun

" complete people (@-mentions)
fun! workflowish#acp#meetsForWorkflowishPerson(context)
  return s:WordMeetsByPrefix(a:context, 'acp_behaviorWorkflowishPersonLength', '@')
endfun

fun! s:CompleteWordByPrefix(findstart, base, prefix)
  " echomsg 'CompleteWordByPrefix'
  " echomsg 'findstart = ' . string(a:findstart)
  " echomsg 'base = ' . string(a:base)
  " echomsg 'prefix = ' . string(a:prefix)
  if a:findstart
    let current_text = strpart(getline('.'), 0, col('.') - 1)
    return match(current_text, a:prefix . '\k*$')
  endif
  let lines = filter(getline(1, '$'), 'v:val =~ "'.a:base.'"')
  let res = {}
  for line in lines
    for i in range(11)
      let m = matchstr(line, a:base.'\k*', 0, i)
      let res[m] = 1
    endfor
  endfor
  let compwords = keys(res)
  return compwords
endfun

fun! workflowish#acp#completeWorkflowishTag(findstart, base)
  return s:CompleteWordByPrefix(a:findstart, a:base, '#')
endfun

fun! workflowish#acp#completeWorkflowishPerson(findstart, base)
  return s:CompleteWordByPrefix(a:findstart, a:base, '@')
endfun
