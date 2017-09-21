# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.default_action = 'sample'
        #self.redraw_actions += ['sample']
        #self.persist_actions += ['sample']

    def action_sample(self, context):
        target = context['targets'][0]
        context['sources'][0]['args'] = target['action__num']
        context['input'] = str(context.keys())

    def action_preview(self, context):
        pass
