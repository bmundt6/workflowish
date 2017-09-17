# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.default_action = 'sample'

    def action_sample(self, context):
        target = context['targets'][0]
        word = target['action__num']
        self.vim.command(word)
        return True

    def action_preview(self, context):
        print("Hige")
