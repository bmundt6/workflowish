if exists("b:current_syntax")
  finish
endif

syn cluster WFBits contains=WFTag,WFPerson,WFFilePath
syn cluster WFRegions contains=WFToDo,WFDone,WFComment

syn region WFToDo start=/^\s*[*]/ skip=/\_[^*\-]*/ end=/^\s*[*\-]/ contains=WFTodoMark,@WFRegions,@WFBits
syn region WFDone start=/^\s*[-]/ skip=/\_[^*\-]*/ end=/^\s*[*\-]/ contains=@WFRegions,@WFBits
syn region WFComment start=/^\s*\\/ skip=/\_[^*\-]*/ end=/^\s*[*\-]/ contains=@WFRegions,@WFBits
syn match WFTodoMark /^\s*\*/ contained

syn match WFTag  /#[a-zA-Z0-9_-]*/ contained
syn match WFPerson /@[[:ident:][:punct:]]*/ contained contains=@NoSpell
" borrowed from https://github.com/MTDL9/vim-log-highlighting.git
syn match WFFilePath '\<\w:\\[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell
syn match WFFilePath '[^a-zA-Z0-9"']\@<=\(\~\w*\)\?[/]\w[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell

hi def link WFTodoMark Function
hi def link WFDone Comment
hi def link WFComment Delimiter
hi def link WFPerson Function
hi def link WFTag String
hi def link WFFilePath Conditional

let b:current_syntax = "workflowish"
