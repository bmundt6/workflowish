if exists("b:current_syntax")
  finish
endif

syn cluster WFBits contains=WFTag,WFPerson,WFFilePath
syn cluster WFRegions contains=WFToDo,WFDone,WFComment
syn cluster WFMarks contains=WFTodoMark,WFCommentMark

syn region WFToDo start=/^\z(\s*\)[*]/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFRegions,@WFBits,WFTodoMark
syn region WFDone start=/^\z(\s*\)[-]/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFBits,@WFMarks
syn region WFComment start=/^\z(\s*\)\\/ skip=/^\z1\s\+.*/ end=/^\(\s*[*\\-]\)\@=/ contains=@WFRegions,@WFBits,WFCommentMark

syn match WFTodoMark /^\s*\*/ contained
syn match WFCommentMark /^\s*\\/ contained

syn match WFTag  /#[a-zA-Z0-9_-]*/ contained
syn match WFPerson /@[[:ident:][:punct:]]*/ contained contains=@NoSpell
" borrowed from https://github.com/MTDL9/vim-log-highlighting.git
syn match WFFilePath '\<\w:\\[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell
syn match WFFilePath '[^a-zA-Z0-9"']\@<=\(\~\w*\)\?[/]\w[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell

hi def link WFTodoMark Function
hi def link WFDone Comment
hi def link WFCommentMark Delimiter
hi def link WFComment Delimiter
hi def link WFPerson Function
hi def link WFTag String
hi def link WFFilePath Conditional

let b:current_syntax = "workflowish"
