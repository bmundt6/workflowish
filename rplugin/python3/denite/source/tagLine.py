# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'tagLine'
        self.kind = 'jump'

    #def on_init(self, context):
        # TODO

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        args = context['sources'][0]['args']
        arg = args[0]
        line_list = self.vim.call('ShowTagList', arg)

        return list(map(
            lambda line: {
                'word': line['line'],
                'action__num': line['lnum'],
                'action__win': self.vim.current.window},
            line_list))
