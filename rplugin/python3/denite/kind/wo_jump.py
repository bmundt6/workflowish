# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'wo_jump'
        self.default_action = 'wo_jump'
        self.denite_command = 'Denite'

    def action_wo_jump(self, context):
        self._jump(context)

    def action_wo_split(self, context):
        arg = context['targets'][0]['action__num']
        com = 'split +' + str(arg)
        self.vim.command(com)
        self.vim.current.window = context['targets'][0]['action__win']

    def action_wo_vsplit(self, context):
        arg = context['targets'][0]['action__num']
        com = 'vsplit +' + str(arg)
        self.vim.command(com)
        self.vim.current.window = context['targets'][0]['action__win']

    def action_preview(self, context):
        pass

    def _jump(self, context):
        arg = context['targets'][0]['action__num']
        context['targets'][0]['action__win'].cursor = [int(arg), 0]
