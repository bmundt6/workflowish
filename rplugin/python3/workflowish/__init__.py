import neovim
import re

@neovim.plugin
class workflowishUtils(object):

    def __init__(self, vim):
        self.nvim = vim


    @neovim.function("CalculateTagSet", sync=True)
    def CalculateTagSet(self, args):
        lines = self.nvim.call('getbufline', '%', 1, '$')
        pat = re.compile('#[a-zA-Z0-9_-]*')
        tagset = set()
        for line in lines:
            ret = pat.findall(line)
            for r in ret:
                tagset.add(r)
        return list(tagset)

