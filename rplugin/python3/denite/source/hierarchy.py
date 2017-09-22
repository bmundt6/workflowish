# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.kind = 'hierarchy'

    def on_init(self, context):
        context['__fmt'] = '%' + str(len(
                    str(self.vim.call('line', '$')))) + 'd: %s'
        # TODO

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        args = context['sources'][0]['args']
        if args:
            arg = args[0]
            linenums = self.vim.call('workflowish#findSameRankLineList', arg)
        else:
            linenums = self.vim.call('workflowish#findSameRankLineList')

        line_list = self.__get_line_list(context['bufnr'], linenums)

        return list(map(
            lambda line: {
                'word': line['li'],
                'abbr': (context['__fmt'] % (line['lnum'], line['li'])),
                'action__win': self.vim.current.window,
                'action__num': line['lnum']},
            line_list))

    def __get_line_list(self, buf, lines):
        rets = []
        for line in lines:
            rets.append({'li': self.vim.call('workflowish#getbufline', buf, line),
                         'lnum': line})
        return rets
