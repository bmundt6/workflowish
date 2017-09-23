# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'tag'
        self.default_action = 'tag'
        self.denite_command = 'Denite'
        self.tagline_command = 'tagLine'

    def action_tag(self, context):
        arg = context['targets'][0]['word']
        cmd = " ".join([self.denite_command, ":".join([self.tagline_command, arg])])
        self.vim.command(cmd)

    def action_preview(self, context):
        pass
