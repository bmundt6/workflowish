# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.kind = 'hierarchy'

    # def on_init(self, context):
        # TODO

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        #context['is_interactive'] = True
        args = context['sources'][0]['args']
        if args:
            arg = int(args)
            denite_bufnr = self.vim.call('bufnr', '')
            self.vim.command('buffer ' + str(context['bufnr']))
            linenums = self.vim.call('workflowish#findSameRankLineList', arg)
            self.vim.command("sp " + str(linenums[0]))
            self.vim.command('buffer ' + str(denite_bufnr))

        else:
            linenums = self.vim.call('workflowish#findSameRankLineList')
        line_list = self.__get_line_list(context['bufnr'], linenums)
        return list(map(
            lambda line: {
                'word': line['li'],
                'action__num': line['lnum']},
            line_list))

    def __get_line_list(self, buf, lines):
        rets = []
        for line in lines:
            rets.append({'li': self.vim.call('workflowish#getbufline', buf, line),
                         'lnum': line})
        return rets
