if exists("b:current_syntax")
  finish
endif

syn cluster WFBits contains=WFTag,WFPerson,WFFilePath

"FIXME use regions that include newline
syn match WFToDoMark /^\s*\*/ nextgroup=WFToDo
syn match WFDoneMark /^\s*-/ nextgroup=WFDone
syn match WFCommentMark /^\s*\\/ nextgroup=WFComment

syn match WFToDo /.*/ contained contains=@WFBits
syn match WFDone /.*/ contained contains=@WFBits
syn match WFComment /.*/ contained contains=@WFBits

syn match WFTag  /#[a-zA-Z0-9_-]*/ contained
syn match WFPerson /@[[:ident:][:punct:]]*/ contained contains=@NoSpell
" borrowed from https://github.com/MTDL9/vim-log-highlighting.git
syn match WFFilePath '\<\w:\\[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell
syn match WFFilePath '[^a-zA-Z0-9"']\@<=\(\~\w*\)\?[/]\w[^\n|,; ()'"\]{}]\+' contained contains=@NoSpell

hi def link WFToDoMark Function
hi def link WFDone Comment
hi def link WFDoneMark WFDone
hi def link WFComment Delimiter
hi def link WFCommentMark WFComment
hi def link WFPerson Function
hi def link WFTag String
hi def link WFFilePath Conditional

let b:current_syntax = "workflowish"
