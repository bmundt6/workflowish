# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'jump'
        self.default_action = 'jump'
        self.denite_command = 'Denite'

    def action_jump(self, context):
        self._jump(context)

    def action_preview(self, context):
        pass

    def _jump(self, context):
        arg = context['targets'][0]['action__num']
        context['targets'][0]['action__win'].cursor = [int(arg), 0]
