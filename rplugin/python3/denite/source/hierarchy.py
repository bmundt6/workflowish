# FILE: hierarchy.py
# AUTHOR: tortuepin
# License: MIT license

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'hierarchy'
        self.kind = 'hierarchy'

    # def on_init(self, context):
        # TODO

    # def on_close(self, context):
        # TODO

    def gather_candidates(self, context):
        # TODO: Following code is a sample
        candidates = ['1', '3', '5']
        return list(map(
            lambda candidate: {
                'word': candidate,
                'action__num': "10"},
            candidates))
