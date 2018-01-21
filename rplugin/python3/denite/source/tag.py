# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'wo_tag'
        self.kind = 'wo_tag'

    #def on_init(self, context):
        # TODO

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        args = context['sources'][0]['args']
        if args:
            line_list = self.vim.call('CalculateTagSet', int(args[0]))
        else:
            line_list = self.vim.call('CalculateTagSet', 2)

        return list(map(
            lambda line: {
                'word': line},
            line_list))
