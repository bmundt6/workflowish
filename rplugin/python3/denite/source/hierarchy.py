# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.kind = 'hierarchy'
        self.__wo = ""

    def on_init(self, context):
        context['__wo'] = 'hoho'

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        context['is_interactive'] = True
        now_lnum = self.vim.call('line', '.')
        args = ''
        #if 'wo' in context['sources'][0].keys():
        #    args = context['sources'][0]['args']
        args = context['sources'][0]['args']
        context['__wo'] = 'wooo'
        if args:
            arg = int(args[0])
            denite_bufnr = self.vim.call('bufnr', '')
            self.vim.command('buffer ' + str(context['bufnr']))
            line_list = self.vim.call('workflowish#findSameRankLineList', 3)
            self.vim.command('buffer ' + str(denite_bufnr))
        else:
            line_list = self.vim.call('workflowish#findSameRankLineList')
            #line_list = self.vim.call('getwininfo')
        
        #win_id = self.vim.call('bufwinid', '%')
        context['source'] = {"huga": "huga"}
        line_list = context['source']
        #line_list = context.keys()
        #line_list = [context['prev_winid'], context['bufnr']]
        #line_list.append("hgoe")
        return list(map(
            lambda line: {
                'word': str(line),
                'action__hoge': "huhuhu"},
            line_list))
        #return list(map(
        #    lambda line: {
        #        'word': self.vim.call("workflowish#getline", int(line)),
        #        'action__num': str(line)},
        #    line_list))
