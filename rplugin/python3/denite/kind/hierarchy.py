# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.default_action = 'sample'
        self.redraw_actions += ['sample']
        self.persist_actions += ['sample']

    def action_sample(self, context):
        target = context['targets'][0]
        #self.vim.call('win_gotoid', target['word'])
        #self.vim.call('cursor', [5, 5])
        #self.vim.command('5')
        #context['input'] = str(context['sources'][0]['args'])
        #context['source']['wo'] = [2]
        #context['input'] = ''
        #context['input'] = str(context.keys())
        lnum = target['action__num']
        #winid = target['action__winid']
        #denite_winnr = self.vim.call('bufwinid', '%')
        #self.vim.call('win_gotoid', winid)
        #self.vim.call('cursor', [0, lnum])
        ##self.vim.call('win_gotoid', str(denite_winnr))

    def action_preview(self, context):
        pass
