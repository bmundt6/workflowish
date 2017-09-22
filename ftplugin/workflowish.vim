setlocal foldlevel=0
setlocal foldenable
setlocal sw=2 sts=2
setlocal expandtab

" foldした時に表示するtextを決める
setlocal foldtext=WorkflowishFoldText()

" foldする条件を決める
" v:lnumには行数がはいる
setlocal foldmethod=expr
setlocal foldexpr=WorkflowishCompactFoldLevel(v:lnum)

setlocal autoindent

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

"}}}
" Keybindings {{{

nnoremap <buffer> zq :call WorkflowishFocusToggle(line("."))<cr>
nnoremap <buffer> zp :call WorkflowishFocusPrevious()<cr>
" * set your terminal that send ✠ to vim when you push <C-Enter> 
noremap <buffer> ✠ :call TodoSwitcher()<cr>
" * set up your terminal that send ࿀ to vim when you push <S-Enter>
noremap <buffer> ࿀ :call AddNewLine()<cr>i
noremap <buffer> <c-t> <ESC>:call workflowish#InputTime()<cr>a 
inoremap <buffer> <c-t> <ESC>:call workflowish#InputTime()<cr>a 

noremap <buffer> <C-d> <ESC>:call workflowish#InputDate()<cr>a 
inoremap <buffer> <C-d> <ESC>:call workflowish#InputDate()<cr>a 

noremap <buffer> <C-o> <ESC>:call workflowish#addTask()<cr>a
inoremap <buffer> <C-o> <ESC>:call workflowish#addTask()<cr>a

" auto insert *
nmap <buffer> o o* 

" indent
nmap <buffer> <TAB> >>
" set up your terminal that send ࿁ to vim when you push <s-tab>
nmap <buffer> ࿁ <<

if g:workflowish_disable_zq_warning == 0
  nnoremap <buffer> ZQ :call WorkflowishZQWarningMessage()<cr>
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

function! s:WindowWidth()
  " TODO: signcolumn takes up 2 columns, hardcoded
  return winwidth(0) - &fdc - &number*&numberwidth - 2
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

function! s:PreviousIndent(lnum)
  let lastindent = indent(a:lnum)
  for line in range(a:lnum-1, 1, -1)
    if lastindent > indent(line)
      return line
    end
  endfor
  return 0
endfunction

"}}}
" Window attribute methods {{{
" Couldn't find any other 'sane' way to initialize window variables

" 現在フォーカスしている場所の先頭の行数を返す
" フォーカスしていない場合は0
function! s:GetFocusOn()
  if !exists("w:workflowish_focus_on")
    let w:workflowish_focus_on = 0
  endif
  return w:workflowish_focus_on
endfunction

" フォーカス機能を利用したときに実行される
" フォーカスしたとこの行数をセットする
function! s:SetFocusOn(lnum)
  let w:workflowish_focus_on = a:lnum
endfunction

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
  let focusOn = s:GetFocusOn()
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
function! WorkflowishFoldText()
  let focusOn = s:GetFocusOn()
  if l:focusOn > 0 && !(v:foldstart >= l:focusOn && v:foldstart <= s:RecomputeFocusOnEnd(l:focusOn))
  " フォーカス機能使ってるとき
    if v:foldstart ==# 1
      return WorkflowishBreadcrumbs(v:foldstart, v:foldend)
    else
      return repeat("- ", s:WindowWidth() / 2)
    endif
  else
  " 使ってないとき
    let lines = v:foldend - v:foldstart
    let firstline = getline(v:foldstart)
    let textend = '|' . lines . '| '

    if g:workflowish_experimental_horizontal_focus == 1 && s:GetFocusOn() > 0
      let firstline = substitute(firstline, "\\v^ {".w:workflowish_focus_indent."}", "", "")
    end

    return firstline . repeat(" ", s:WindowWidth()-s:StringWidth(firstline.textend)) . textend
  endif
endfunction

function! WorkflowishBreadcrumbs(lstart, lend)
  let breadtrace = ""
  let lastindent = indent(a:lend+1)
  for line in range(a:lend, a:lstart, -1)
    if lastindent > indent(line)
      let breadtrace = s:CleanLineForBreadcrumb(line) . " > " . breadtrace
      let lastindent = indent(line)
    end
  endfor
  let breadtrace = substitute(breadtrace, " > $", "", "")
  if breadtrace == ""
    let breadtrace = "Root"
  endif
  return breadtrace . repeat(" ", s:WindowWidth()-s:StringWidth(breadtrace))
endfunction

"}}}
" Feature : Focus {{{

function! WorkflowishFocusToggle(lnum)
  if a:lnum == s:GetFocusOn()
    call WorkflowishFocusOff()
  else
    call WorkflowishFocusOn(a:lnum)
  endif
endfunction

function! WorkflowishFocusOn(lnum)
  if a:lnum == 0
    return WorkflowishFocusOff()
  end
  call s:SetFocusOn(a:lnum)
  if g:workflowish_experimental_horizontal_focus == 1
    let w:workflowish_focus_indent = indent(a:lnum)
    " nowrap is needed to scroll horizontally
    setlocal nowrap
    normal! "0zs"
  endif
  " reparse folds, close top/line1 unless focused, close bottom, go back
  normal zx
  if a:lnum != 1
    normal 1Gzc
  endif
  if a:lnum != line('$')
    normal Gzc
  end
  execute "normal" a:lnum . "Gzv"
endfunction

function! WorkflowishFocusOff()
  call s:SetFocusOn(0)
  if g:workflowish_experimental_horizontal_focus == 1
    setlocal wrap
  end
  normal zx
endfunction

function! WorkflowishFocusPrevious()
  if s:GetFocusOn() > 0
    call WorkflowishFocusOn(s:PreviousIndent(s:GetFocusOn()))
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
  normal zo

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
    normal zc
  endif

endfunction
" }}}
" AddNewLine() : add new line without foldopen {{{
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

"{{{
function! workflowish#getTime()
  return "[" . strftime("%H:%M") . "]"
endfunction
function! workflowish#getDate()
  return "#" . strftime("%m%d")
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
" vim:set fdm=marker sw=2 sts=2 et:
