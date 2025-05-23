setlocal foldlevel=0
setlocal foldenable
setlocal sw=2 sts=2
setlocal expandtab
" so that #tags can be selected by <cword>
setlocal iskeyword+=#

" foldした時に表示するtextを決める
setlocal foldtext=WorkflowishFoldText()

" foldする条件を決める
" v:lnumには行数がはいる
setlocal foldmethod=expr
setlocal foldexpr=WorkflowishCompactFoldLevel(v:lnum)

setlocal autoindent
" never reveal concealed items so that horizontal focus using conceal allows natural editing
setlocal concealcursor=nvic

let w:workflowish_prev_wrap=&wrap

" Commands {{{
command! -buffer B Denite wo_tagLine:@B
command! -buffer C Denite wo_tagLine:@cheat
command! -buffer -nargs=* I call workflowish#addInbox(<f-args>)
command! -buffer H Denite wo_hierarchy
command! -buffer -nargs=? T call workflowish#T(<f-args>)
" }}}

" Settings {{{

" This will use horizontal scroll in focus mode
" The current problems is that the foldtext isn't scrolled auto
" and it's easy to 'lose' the horizontal scroll when using certain commands
" also, there seems to be quite a few bugs
if !exists("g:workflowish_experimental_horizontal_focus")
  let g:workflowish_experimental_horizontal_focus = 0
endif

if !exists("g:workflowish_disable_zq_warning")
  let g:workflowish_disable_zq_warning = 0
endif

if !exists("g:workflowish_inbox_line_marker")
  let g:workflowish_inbox_line_marker = "---inbox_end_line---"
endif

"}}}
" Keybindings {{{

nnoremap <silent> <plug>(workflowish-focus-toggle) :call WorkflowishFocusToggle(line("."))<cr>
nnoremap <silent> <plug>(workflowish-focus-line-horizontal) :call WorkflowishFocusLineHorizontal()<cr>
nnoremap <silent> <plug>(workflowish-unfold-line) :call WorkflowishUnfoldLine(0)<cr>
nnoremap <silent> <plug>(workflowish-unfold-line-todo) :call WorkflowishUnfoldLine(1)<cr>
nnoremap <silent> <plug>(workflowish-focus-prev) :call WorkflowishFocusPrevious()<cr>
noremap <silent> <plug>(workflowish-todo-toggle) :call TodoSwitcher()<cr>
noremap <silent> <plug>(workflowish-append-newline) :call AddNewLine()<cr>i
noremap <silent> <plug>(workflowish-insert-time) <ESC>:call workflowish#InputTime()<cr>a 
noremap <silent> <plug>(workflowish-jump-next-same-rank) <cmd>call workflowish#jumpSameRank('w')<cr>
noremap <silent> <plug>(workflowish-jump-prev-same-rank) <cmd>call workflowish#jumpSameRank('wb')<cr>
noremap <silent> <plug>(workflowish-move-subtree-up) <cmd>call workflowish#moveSubtreeUp(line('.'))<cr>
noremap <silent> <plug>(workflowish-move-subtree-down) <cmd>call workflowish#moveSubtreeDown(line('.'))<cr>

if !get(g:, 'workflowish_no_mappings', 0)

  nmap <buffer> zq <plug>(workflowish-focus-toggle)
  " use this mapping to open the focused line on drill-down
  " nmap <buffer> zq <plug>(workflowish-focus-toggle)<plug>(workflowish-unfold-line)<plug>(workflowish-focus-line-horizontal)
  nmap <buffer> zp <plug>(workflowish-focus-prev)
  map <buffer> [[ <plug>(workflowish-jump-prev-same-rank)
  map <buffer> ]] <plug>(workflowish-jump-next-same-rank)

  " auto insert *
  "TODO: use vim-endwise plugin to implement this behavior in insert mode
  nmap <buffer> o o* 
  nmap <buffer> <S-o> <S-o>* 

  " indent
  "TODO move the whole subtree
  "FIXME don't move more than one indent level to the right of the parent indent
  nmap <buffer> <TAB> >>
  nmap <buffer> <S-TAB> <<

  if g:workflowish_disable_zq_warning == 0
    nnoremap <buffer> ZQ :call WorkflowishZQWarningMessage()<cr>
  endif

endif

"}}}
" Missing framework functions {{{

" unicode length, from https://github.com/gregsexton/gitv/pull/14
if exists("*strwidth")
  "introduced in Vim 7.3
  fu! s:StringWidth(string)
    return strwidth(a:string)
  endfu
else
  fu! s:StringWidth(string)
    return len(split(a:string,'\zs'))
  endfu
end

function! s:SignColumnWidth()
  " signcolumn takes up 2 columns, hardcoded
  "TODO figure out whether or not it is active
  " for now, just append two spaces to every foldtext
  return 2
endfunction

function! s:WindowWidth()
  return winwidth(0) - &fdc - &number*&numberwidth - s:SignColumnWidth()
endfunction

function! s:StripEnd(str)
  return substitute(a:str, " *$", "", "")
endfunction

"}}}
" Workflowish utility functions {{{

function! WorkflowishZQWarningMessage()
  echohl WarningMsg
  echo "ZQ is not zq. Did you leave caps lock on? Put this in config to disable this message: let g:workflowish_disable_zq_warning = 1"
  echohl None
endfunction

function! s:CleanLineForBreadcrumb(lnum)
  return s:StripEnd(substitute(getline(a:lnum), "\\v^( *)(\\\\|\\*|\\-) ", "", ""))
endfunction

" returns the first line number above current which has a greater indent than current
function! s:PreviousIndent(lnum)
  let lastindent = indent(a:lnum)
  for line in range(a:lnum-1, 1, -1)
    if lastindent > indent(line)
      return line
    end
  endfor
  return 0
endfunction

" Recursively unfold the current line even if it is open
function! WorkflowishUnfoldLine(todo_only)
  let l:pos = getpos('.')
  let l:line = l:pos[1]
  " minimal-unfold the current line
  " then, non-recursively _fold_ the current line if it is a fold parent,
  silent! normal! zvzc
  " if we're not actually on a fold parent, then we're done now, just unfold and exit
  if foldclosed('.') == l:line
    " okay, this is a fold parent
    " select the folded tree and recursively unfold
    silent! normal! VzO
    if a:todo_only
      " fold completed children back up
      "TODO make a command for properly folding nodes
      " e.g. want to be able to do g/#tag/close to hide all nodes with #tag
      " (g/#tag/normal! zvzc would work if we could do :g from bottom-to-top of file)
      '<,'>folddoopen let prev_line = s:PreviousIndent(line('.')) | if prev_line > l:line && foldclosed(prev_line) < 0 && getline(prev_line) =~ '^\s*-' | exe prev_line . 'foldclose' | endif
    endif
    call setpos('.', l:pos)
  endif
  " unfold again in case current line is a "done" line
  silent! normal! zv
endfunction

"TODO command/mapping for searching/operating on hierarchy
" e.g. something like
"   :wfg/*-/-/zv
" might unfold all completed children of children of the root node;
"   :wfg/**/-/d
" might recursively delete all completed nodes;
"   :wfg/**/-/**/#todo/p
" might print all nodes with the #todo tag under a completed node

"}}}
" Window attribute methods {{{
" Couldn't find any other 'sane' way to initialize window variables

" Yes it looks horrible, and it is.
" This will be checked row for row, i.e. 1,2,3,4,5,6,7,8 and then maybe 4,5,6,7,8 and
" 4,5 which will trigger a recompute 3 times for row 1, 4 and 4 again using
" the cache the other times.
function! s:GetFocusOnEnd(lnum, focusOn)
  if !exists("w:workflowish_focus_on_end")
    let w:workflowish_focus_on_end = 0
  endif
  if !exists("w:workflowish_focus_on_end_last_accessed_row")
    let w:workflowish_focus_on_end_last_accessed_row = 0
  endif
  if a:focusOn > 0
    if w:workflowish_focus_on_end_last_accessed_row == a:lnum
      " take it easy
    elseif w:workflowish_focus_on_end_last_accessed_row == a:lnum-1
      let w:workflowish_focus_on_end_last_accessed_row = a:lnum
    else
      let w:workflowish_focus_on_end_last_accessed_row = a:lnum
      call s:RecomputeFocusOnEnd(a:focusOn)
    end
  else
    let w:workflowish_focus_on_end = 0
  end
  return w:workflowish_focus_on_end
endfunction

" This method is quite slow in big files
" 現在のインデントの終わりを見つける
" Find the end of the current indentation
function! s:RecomputeFocusOnEnd(lfrom)
  let lend = line('$') " 一番下の行
  if a:lfrom > 0
    let foldindent = indent(a:lfrom) " インデントの階数

    let w:workflowish_focus_on_end = lend
    let lnum = a:lfrom+1
    while lnum < lend
      if indent(lnum) <= foldindent && getline(lnum) !~ "^\\s*$"
        let w:workflowish_focus_on_end = lnum-1
        break
      endif
      let lnum = lnum + 1
    endwhile
  else
    let w:workflowish_focus_on_end = 0
  endif
  return w:workflowish_focus_on_end
endfunction

"}}}
" Feature : Folds {{{

" This feature hides all nested lines under the main one, like workflowy.
function! WorkflowishCompactFoldLevel(lnum)
  let l:focusOn = get(w:, 'workflowish_focus_on', 0)
  if l:focusOn > 0
    if a:lnum == 1
      call s:RecomputeFocusOnEnd(l:focusOn)
    end
    if a:lnum ==# 1 || a:lnum ==# s:GetFocusOnEnd(a:lnum, l:focusOn) + 1
      return '>1'
    elseif (a:lnum ># 1 && a:lnum <# l:focusOn) || a:lnum > s:GetFocusOnEnd(a:lnum, l:focusOn) + 1
      return 1
    else
      return s:ComputeFoldLevel(a:lnum, indent(l:focusOn) * -1)
    endif
  else
    return s:ComputeFoldLevel(a:lnum, 0)
  endif
endfunction

function! s:ComputeFoldLevel(lnum, indent_offset)
  " TODO: check why vspec can't handle options like &shiftwidth instead of
  " hardcoded 2
  let this_indent = (indent(a:lnum) + a:indent_offset) / 2
  let next_indent = (indent(a:lnum + 1) + a:indent_offset) / 2

  if next_indent > this_indent
    return '>' . next_indent
  else
    return this_indent
  endif
endfunction

" foldしたときのテキストを決める
" Determine the text when folded
function! WorkflowishFoldText()
  let l:focusOn = get(w:, 'workflowish_focus_on', 0)
  if l:focusOn > 0 && !(v:foldstart >= l:focusOn && v:foldstart <= s:RecomputeFocusOnEnd(l:focusOn))
  " フォーカス機能使ってるとき
  " when focus mode is active
    if v:foldstart ==# 1
      return WorkflowishBreadcrumbs(v:foldstart, v:foldend)
    else
      " let fill_str = get(g:, 'workflowish_unfocused_fill_str', '- ')
      let fill_str = get(g:, 'workflowish_unfocused_fill_str', ' ')
      return repeat(fill_str, (s:WindowWidth() + 2) / strdisplaywidth(fill_str))
    endif
  else
  " 使ってないとき
  " when focus mode is inactive
    let lines = v:foldend - v:foldstart
    let firstline = getline(v:foldstart)
    if (&encoding ==# 'utf-8')
      " display the line with strikethroughs if it is a done line
      let synID = synID(v:foldstart, 1, 1)
      let synName = synIDattr(synID, 'name')
      if (synName ==# 'WFDone')
        let firstline = substitute(firstline, '[^[:space:]]', '&̶', 'g')
      endif
    endif
    let textend = '|' . lines . '| '

    if g:workflowish_experimental_horizontal_focus == 1 && l:focusOn > 0
      let firstline = substitute(firstline, "\\v^ {".indent(l:focusOn)."}", "", "")
    end

    return firstline . repeat(" ", s:WindowWidth()-s:StringWidth(firstline.textend)) . textend . "  "
  endif
endfunction

function! WorkflowishBreadcrumbs(lstart, lend)
  let divider = get(g:, 'workflowish_breadcrumb_divider', get(g:, 'airline_left_alt_sep', get(g:, 'airline_left_sep', '>')))
  let breadtrace = ""
  let lastindent = indent(a:lend+1)
  for line in range(a:lend, a:lstart, -1)
    if lastindent > indent(line)
      if "" == breadtrace
        let breadtrace = s:CleanLineForBreadcrumb(line)
      else
        let breadtrace = s:CleanLineForBreadcrumb(line) . ' '.divider.' ' . breadtrace
      endif
      let lastindent = indent(line)
    end
  endfor
  let breadtrace = divider . ' ' . breadtrace
  return breadtrace . repeat(" ", s:WindowWidth() - s:StringWidth(breadtrace) + 2)
endfunction

"}}}
" Feature : Focus {{{

function! WorkflowishFocusLineHorizontal()
  if &list && &listchars =~ 'precedes'
    " if there is a 'precedes' listchar in &listchars, scroll once to the right
    normal! ^hzs
  else
    " scroll the first non-blank char over to the left
    normal! ^zs
  endif
endfunction

function! WorkflowishFocusToggle(lnum)
  "TODO when horizontal focus is enabled,
  "     toggle on if the screen is scrolled to the wrong column
  "     regardless of the line number
  if a:lnum == get(w:, 'workflowish_focus_on', 0)
    call WorkflowishFocusOff()
  else
    call WorkflowishFocusOn(a:lnum)
  endif
endfunction

function! WorkflowishFocusOn(lnum)
  if a:lnum == 0
    return WorkflowishFocusOff()
  end
  if !exists('w:workflowish_prev_wrap')
    let w:workflowish_prev_wrap=&wrap
  endif
  let w:workflowish_focus_on = a:lnum
  " save initial cursor position
  let pos = getpos('.')
  " jump to lnum, reparse folds and open fold at cursor
  exe 'normal! '.a:lnum.'Gzx'
  if g:workflowish_experimental_horizontal_focus == 1
    "TODO alternate implementation using matchadd:
    " matchadd('Conceal', '^  ')

    " nowrap is needed to scroll horizontally
    setlocal nowrap
    call WorkflowishFocusLineHorizontal()
  endif
  " close top/line1 unless focused
  if a:lnum != 1
    silent! normal! 1Gzc
  endif
  " close bottom
  if a:lnum != line('$')
    silent! normal! Gzc
  end
  " jump to focus line and unfold
  exe 'normal!' a:lnum . 'G'
  normal! zv
  " unfold the entire focus region
  " silent! normal! zczO
  if g:workflowish_experimental_horizontal_focus
    " don't move cursor to the previous column when using experimental horizontal focus
    let curpos = getpos('.')
    let pos[2] = curpos[2]
    let pos[3] = curpos[3]
  endif
  "jump to original position
  call setpos('.', pos)
  " unfold original position
  normal! zv
endfunction

function! WorkflowishFocusOff()
  let w:workflowish_focus_on = 0
  if exists('w:workflowish_prev_wrap') && w:workflowish_prev_wrap
    unlet w:workflowish_prev_wrap
    setlocal wrap
  endif
  normal! zx
endfunction

function! WorkflowishFocusPrevious()
  let w:workflowish_focus_on = get(w:, 'workflowish_focus_on', 0)
  if w:workflowish_focus_on > 0
    call WorkflowishFocusOn(s:PreviousIndent(w:workflowish_focus_on))
  end
endfunction

"}}}
" Feature : Convert {{{

function! workflowish#convert_from_workflowy()
  " Replace all - with *
  silent %s/\v^( *)- /\1* /e

  " Fix notes under other notes or items (whitespace hack, copies the number of spaces in submatch \1 from last row), max 1000 rows in one comment block
  " The try will catch nomatch early and stop
  try
    let c = 1
    while c < 1000
      silent %s/\v^( *)(  \\|\*)( .*\n)\1  ( *)([^\-\* ]|$)/\1\2\3\1  \\\4 \5/
      let c += 1
    endwhile
  catch /^Vim(substitute):E486:/
  endtry
  " Change completed items to -
  silent %s/\v^( *)\* \[COMPLETE\] /\1- /e
endfunction

"}}}

" Feature : Added {{{

" TodoSwitcher() : switch *todo and -done {{{
function! TodoSwitcher()
  let l:l = line(".")
  let l:isfolded = foldclosed(l)
  " if l:l is in closed fold, assign l:l the number of first line in that fold.
  if l:isfolded != -1 && l:isfolded != l
    let l:l = l:isfolded
  endif
  let l:line = getline(l:l)
  let l:sp = split(l:line, ' ')
  foldopen

  if l:sp[0] == '*'
    call remove(l:sp, 0)
    call insert(l:sp, '-', 0)
    if l:sp[1] == '@T'
      call remove(l:sp, 1)
      call insert(l:sp, '@D', 1)
    endif
  elseif l:sp[0] == '-'
    call remove(l:sp, 0)
    call insert(l:sp, '*', 0)
    if l:sp[1] == '@D'
      call remove(l:sp, 1)
      call insert(l:sp, '@T', 1)
    endif
  endif

  call setline(l:l, repeat(' ', indent(l:l)) . join(l:sp))

  " If line s:l was in closed fold, close fold
  if l:isfolded > 0
    foldclose
  endif

endfunction
" }}}
" AddNewLine() : add new line without a leading bullet {{{
function! AddNewLine()
  let last = s:RecomputeFocusOnEnd(line('.'))
  call append(last, '')
  call cursor(last+1, 1)
endfunction
"}}}

" InputTime() : input the time formatted like [04:56] {{{
function! workflowish#InputTime()
  let t = "[" . strftime("%H:%M") . "]"
  execute "normal a" . t
endfunction
" }}}
" InputDate() : input the date formatted as #0412 {{{
function! workflowish#InputDate()
  let d = "#" . strftime("%m%d")
  execute "normal a" . d
endfunction
" }}}
" addTask() : input the task template as * @T #0412 {{{
function! workflowish#addTask()
  execute "normal o@T " . workflowish#getDate() . " "
endfunction
" }}}

" indent() : return indent()/2 {{{
function! workflowish#indent(lnum)
  return indent(a:lnum)/2
endfunction
"}}}
" line() : return current line number considering folds {{{
function! workflowish#line()
  let fnum = foldclosed(line("."))
  if fnum == -1
    return line(".")
  endif
  return fnum
endfunction
"}}}
" getline(lnum) : return current line buffer {{{
function! workflowish#getline(lnum)
  let line = getline(a:lnum)
  let pos = match(line, "[*|-]")
  return line[pos+2:]
endfunction
" }}}
" getbufline(lnum, buf) : return current line buffer {{{
function! workflowish#getbufline(expr, lnum)
  let line = getbufline(a:expr, a:lnum)[0]
  let pos = match(line, "[*|-]")
  return line[pos:]
endfunction
" }}}
" findParent(){{{
function! workflowish#findParent(lnum)
  let lnum = a:lnum
  let indent = workflowish#indent(lnum)
  if indent == 0
    return -1
  endif
  while workflowish#indent(lnum) != indent-1
    let lnum = lnum - 1
  endwhile
  return lnum
endfunction
"}}}
" getParents() {{{ return parents list
function! workflowish#getParents()
  let parentList = []
  let parent = workflowish#findParent(workflowish#line())
  while parent != -1
    call add(parentList, parent)
    let parent = workflowish#findParent(parent)
  endwhile
  return parentList
endfunction
"}}}
" viewParentLineList()  {{{
function! workflowish#getParentLineList()
  let parentsList = workflowish#getParents()
  let lineList = []
  call reverse(parentsList)
  for lnum in parentsList
    call add(lineList, "{" . workflowish#getline(lnum). "}")
  endfor
  return join(lineList, "/")
endfunction
"}}}
" getSubtree() {{{ return range of lines below this node
"                  (equivalently, range starts at lnum and ends at return value)
"FIXME: add a hook to skip lines by regexp to support custom syntax regions
function! workflowish#getSubtree(lnum)
  let l:last_line = line("$")
  let l:indent = workflowish#indent(a:lnum)
  let l:cur_lnum = a:lnum + 1

  " search for the next line with indent less than or equal to start
  while l:cur_lnum < l:last_line
    let l:is_blank = (getline(l:cur_lnum) =~ '^\s*$')
    let l:blank_is_outdent = get(g:, 'workflowish_blank_is_outdent', 0)
    if l:is_blank && !l:blank_is_outdent
      " skip
    elseif workflowish#indent(l:cur_lnum) <= l:indent
      return l:cur_lnum - 1
    endif
    let l:cur_lnum = l:cur_lnum + 1
  endwhile

  " if all lines have been exhausted and none had an outdent,
  " then the last line of the file is the end of the subtree
  return l:cur_lnum
endfunction
" }}}
" moveSubtreeDown() {{{ swap subtree with the one below it
function! workflowish#moveSubtreeDown(lnum)
  let l:last_line = line('$')
  let l:treeA_start = a:lnum
  let l:folded = (l:treeA_start == foldclosed(l:treeA_start)) " check whether the root of top subtree is a closed fold
  let l:treeA_end = workflowish#getSubtree(l:treeA_start)
  let l:treeB_start = l:treeA_end + 1
  if l:treeB_start > l:last_line || workflowish#indent(l:treeB_start) !=# workflowish#indent(l:treeA_start)
    "TODO: optionally move tree A to the start of the next list at the same level
    return
  endif
  let l:treeB_end = workflowish#getSubtree(l:treeB_start)
  " swap the two regions
  " (yank all lines of treeA, jump to end of treeB and paste)
  let l:treeA_length = l:treeA_end - l:treeA_start + 1
  let l:insertion_point = l:treeB_end - l:treeA_length
  exe ''.l:treeA_start.','.l:treeA_end.'d'
  exe string(l:insertion_point)
  normal! p
  if l:folded
    " close fold if there was already a closed fold at the subtree root
    foldclose
  endif
endfunction
" }}}
" moveSubtreeUp() {{{ swap subtree with the one above it
"                     (implemented by finding subtree above and pasting it below current subtree)
function! workflowish#moveSubtreeUp(lnum)
  let l:treeB_start = a:lnum
  let l:treeA_end = l:treeB_start - 1
  if l:treeA_end < 1
    return
  endif
  let l:treeA_start = workflowish#findPrevSameRank(l:treeB_start)
  if l:treeA_start == l:treeB_start
    "TODO: optionally tree B to the end of the previous list at the same level
    return
  endif
  let l:folded = (l:treeA_start == foldclosed(l:treeA_start)) " check whether the root of top subtree is a closed fold
  let l:treeB_end = workflowish#getSubtree(l:treeB_start)
  " swap the two regions
  " (yank all lines of treeA, jump to end of treeB and paste)
  let l:treeA_length = l:treeA_end - l:treeA_start + 1
  let l:insertion_point = l:treeB_end - l:treeA_length
  exe ''.l:treeA_start.','.l:treeA_end.'d'
  exe string(l:insertion_point)
  normal! p
  if l:folded
    " close fold if there was already a closed fold at the subtree root
    foldclose
  endif
  exe string(l:treeA_start)
endfunction
" }}}
"TODO: add a function (or shell script) for swapping the order of any pair of lines in a file (this could enable swapping lines from within a FZF search)
"      - if lines are siblings (same rank with same parent), then the above functions will work
"      - otherwise, find the closest mutual parent of the two lines and swap those instead
" checkBottomRank(lnum) : if Bottom, return 1. else return -1 {{{
function! workflowish#checkBottomRank(lnum)
  let current_line = workflowish#indent(a:lnum)
  let next_line = workflowish#indent(a:lnum + 1)
  if next_line <= 0
    return 1
  endif
  if l:current_line >= l:next_line
    return 1
  endif
  return -1
endfunction
"}}}
"addInbox : addInbox using g:workflowish_inbox_line_marker {{{
function! workflowish#addInbox(...)
  if len(a:000) == 0
    "call search(g:workflowish_inbox_line_marker)
    "normal! zoO
    call workflowish#jumpInbox()
  else
    let l:pos = search(g:workflowish_inbox_line_marker, 'n')
    if l:pos > 0
      call append(l:pos-1, "  * ".a:1)
      "TODO リスト対応
      "TODO list support
    endif
  endif
endfunction
"}}}
"jumpInbox : jump to g:workflowish_inbox_line_marker {{{
function! workflowish#jumpInbox()
  let l:pos = search(g:workflowish_inbox_line_marker, 'n')
  call cursor(l:pos, 0)
  foldopen
endfunction
"{{{
function! workflowish#getTime()
  return "[" . strftime("%H:%M") . "]"
endfunction
function! workflowish#getDate()
  return "#" . strftime("%m%d")
endfunction
"}}}

" prettyPrinter(line) : return reshape line {{{
function! workflowish#prettyPrinter(line)
  let pos = match(a:line, "[*|-]")
  return a:line[pos:]
endfunction
"}}}
  


" }}}
" findSameRankLineList(...) return same rank line list {{{
function! workflowish#findSameRankLineList(...)
  echo "Rank"
  let l:last_line = line("$")
  " find start position
  if a:0 == 0
    let l:start_lnum = 1
  else
    " find parent
    let l:start_lnum = workflowish#findParent(a:1) + 1
    if l:start_lnum == 0
      let l:start_lnum = 1
    endif
  endif
  let l:target_indent = workflowish#indent(l:start_lnum)

  " search same rank line from start_lnum
  let l:lnum = l:start_lnum
  let l:line_list = []
  let l:indent = workflowish#indent(l:lnum)

  while l:target_indent <= l:indent && l:lnum <= l:last_line
    if l:indent == l:target_indent
      call add(l:line_list, l:lnum)
    endif
    let l:lnum = l:lnum + 1
    let l:indent = workflowish#indent(l:lnum)
  endwhile

  return l:line_list
endfunction "}}}
" findPrevSameRank() {{{ find the previous line of the same rank as current
"                        (if none found, return lnum)
function! workflowish#findPrevSameRank(lnum)
  if a:lnum < 2
    return a:lnum
  endif
  let l:rank_indent = workflowish#indent(a:lnum)
  let l:cur = a:lnum - 1
  while l:cur > 0
    let l:cur_indent = workflowish#indent(l:cur)
    if l:cur_indent == l:rank_indent
      return l:cur
    endif
    if l:cur_indent < l:rank_indent
      return a:lnum
    endif
    let l:cur = l:cur - 1
  endwhile
  return a:lnum
endfunction
" }}}
" jumpSameRank() jump to the next line of the same rank as current {{{
function! workflowish#jumpSameRank(flags)
  let l:backward = (a:flags =~ 'b')
  let l:wrap = (a:flags =~ 'w')
  let l:last_line = line("$")
  let l:cur_lnum = line('.') " line the cursor is on
  let l:start_lnum = workflowish#findParent(l:cur_lnum) + 1 " first line of the current fold
  if l:start_lnum == 0
    let l:start_lnum = 1
  endif
  let l:target_indent = workflowish#indent(l:start_lnum)

  " initial search:
  " - forward from l:cur_lnum for next line with same rank, OR
  " - backward from l:cur_lnum for previous line with same rank
  let l:step = (l:backward) ? -1 : 1
  let l:lnum = l:cur_lnum + l:step
  let l:indent = workflowish#indent(l:lnum)
  while l:target_indent <= l:indent && l:lnum <= l:last_line && (l:lnum >= l:start_lnum || !l:backward)
    if l:indent == l:target_indent
      exe string(l:lnum)
      return
    endif
    let l:lnum = l:lnum + l:step
    let l:indent = workflowish#indent(l:lnum)
  endwhile

  " secondary search:
  " - forward from l:start_lnum to l:cur_lnum, OR
  " - 'backward' from end line (i.e. scan forward to final target_indent)
  if (l:wrap)
    if (l:backward)
      let l:lnum = l:cur_lnum + 1
      let l:indent = workflowish#indent(l:lnum)
      while l:target_indent <= l:indent && l:lnum <= l:last_line
        if l:indent == l:target_indent
          exe string(l:lnum)
        endif
        let l:lnum = l:lnum + 1
        let l:indent = workflowish#indent(l:lnum)
      endwhile
    else
      let l:lnum = l:start_lnum
      let l:indent = workflowish#indent(l:lnum)
      while l:target_indent <= l:indent && l:lnum <= l:cur_lnum
        if l:indent == l:target_indent
          exe string(l:lnum)
          return
        endif
        let l:lnum = l:lnum + 1
        let l:indent = workflowish#indent(l:lnum)
      endwhile
    endif
  endif
endfunction "}}}

" T() for 'T' command {{{
function! workflowish#T(...)
  if len(a:000) == 0
    Denite wo_tag
  else
    let l:command = 'Denite wo_tagLine:' . a:1
    "Denite wo_tagLine:a:1
    execute l:command
  endif
endfunction
"}}}

"TODO command for tag searches like Github, e.g.
" :#s label1 -notlabel2 andlabel3
"NOTE: you can probably make do using :BLines from https://github.com/junegunn/fzf.vim
" e.g. if I want to look for items due today that aren't waiting on somebody else for input, I would do:
"   :BLines
"   BLines> '#today !'#waiting

"}}}
" Plugin Integrations {{{

" vim-commentary: provides comment/uncomment mappings {{{
" use workflowish-style backslash comments
let b:commentary_format = '\ %s'
" use markdown-style backtick inline-code quotes
" let b:commentary_format = '`%s`'
" use markdown-style backtick code block quotes
" (commentary does not support newlines)
" let b:commentary_format = "```%s```"
" }}}

" }}}
" vim:set fdm=marker sw=2 sts=2 et:
