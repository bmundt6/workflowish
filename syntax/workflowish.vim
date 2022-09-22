if exists("b:current_syntax")
  finish
endif

syn cluster WFBits contains=WFTag,WFPerson,WFFilePath
syn cluster WFRegions contains=WFToDo,WFDone,WFComment
syn cluster WFMarks contains=WFTodoMark,WFCommentMark,WFDoneMark

syn cluster WFToDo contains=@WFRegions,@WFBits,WFTodoMark
syn cluster WFDone contains=@WFBits,@WFMarks
syn cluster WFComment contains=@WFRegions,@WFBits,WFCommentMark

" if you don't like the look of names/tags/marks appearing highlighted within Done regions,
" place this in ~/.vim/after/syntax/workflowish.vim:
"
"   syn cluster WFDone remove=@WFBits,@WFMarks
"

syn region WFToDo start=/^\z(\s*\)[*]/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFTodo
syn region WFDone start=/^\z(\s*\)[-]/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFDone
syn region WFComment start=/^\z(\s*\)\\/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFComment

syn match WFTodoMark /^\s*\*/ contained
syn match WFDoneMark /^\s*-/ contained
syn match WFCommentMark /^\s*\\/ contained

syn match WFTag  /#[a-zA-Z0-9_-]*/ contained contains=@NoSpell
syn match WFPerson /@[[:ident:][:punct:]]*/ contained contains=@NoSpell
" borrowed from https://github.com/MTDL9/vim-log-highlighting.git
syn match WFFilePath '\<\w:\\[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell
syn match WFFilePath '[^a-zA-Z0-9"']\@<=\(\~\w*\)\?[/]\f[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell
syn match WFFilePath /\<\a\f*\.\a\+\>/ contained contains=@NoSpell

hi def link WFTodoMark Function
hi def link WFDone Comment
hi def link WFDoneMark WFDone
hi def link WFCommentMark Delimiter
hi def link WFComment Delimiter
hi def link WFPerson Function
hi def link WFTag String
hi def link WFFilePath Conditional

let b:current_syntax = "workflowish"
