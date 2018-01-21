# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'wo_hierarchy'
        self.default_action = 'wo_hierarchy'
        self.denite_command = 'Denite'

    def action_wo_hierarchy(self, context):
        arg = context['targets'][0]['action__num']
        if self.vim.call('workflowish#checkBottomRank', arg) == 1:
            context['targets'][0]['action__win'].cursor = [int(arg), 0]
        else:
            arg = self._adjust_arg(arg)
            arg = self._validate_arg(arg)
            cmd = " ".join([self.denite_command, ":".join([self.name, arg])])
            self.vim.command(cmd)

    def action_preview(self, context):
        pass

    def action_jump(self, context):
        self._jump(context)


    def _validate_arg(self, arg):
        if type(arg) != str:
            #TODO error handring
            return 'error'
        return arg

    def _adjust_arg(self, arg):
        return str(arg + 1)

    def _jump(self, context):
        arg = context['targets'][0]['action__num']
        context['targets'][0]['action__win'].cursor = [int(arg), 0]
