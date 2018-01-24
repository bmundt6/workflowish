# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base
from .wo_jump import Kind as Jump


class Kind(Jump):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'wo_hierarchy'
        self.default_action = 'wo_hierarchy'
        self.denite_command = 'Denite'

    def action_wo_hierarchy(self, context):
        arg = context['targets'][0]['action__num']
        if self.vim.call('workflowish#checkBottomRank', arg) == 1:
            super()._jump(context)
        else:
            arg = self._adjust_arg(arg)
            arg = self._validate_arg(arg)
            cmd = " ".join([self.denite_command, ":".join([self.name, arg])])
            self.vim.command(cmd)

    def action_preview(self, context):
        pass

    def _validate_arg(self, arg):
        if type(arg) != str:
            #TODO error handring
            return 'error'
        return arg

    def _adjust_arg(self, arg):
        return str(arg + 1)
