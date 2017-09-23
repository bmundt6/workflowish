import neovim
import re

@neovim.plugin
class workflowishUtils(object):

    def __init__(self, vim):
        self.nvim = vim


    @neovim.function("CalculateTagSet", sync=True)
    def CalculateTagSet(self, args):
        '''
        if arg is 0 or nothing return # tags.
        if 1 return @ tags.
        if 2 return # and @ tags.
        '''
        lines = self.nvim.call('getbufline', '%', 1, '$')
        pat = self._patChecker(args)
        regexp = re.compile(pat)
        tagset = set()
        for line in lines:
            ret = regexp.findall(line)
            for r in ret:
                tagset.add(r)
        return list(tagset)

    @neovim.function("ShowTagList", sync=True)
    def ShowTagList(self, args):
        '''
        args[0] : tag
        return : line list 
        this function operate like grep
        '''
        lines = self.nvim.call('getbufline', '%', 1, '$')
        pattern = args[0]
        retlines = []
        lnum = 0
        for line in lines:
            lnum = lnum+1
            if pattern in line:
                prettyLine = self.nvim.call('workflowish#prettyPrinter', line)
                retlines.append({'lnum':lnum, 'line':prettyLine})

        return retlines

    def _patChecker(self, args):
        sharppat = '#[a-zA-Z0-9_-]*'
        atpat = '@[a-zA-Z0-9_-]*'
        bothpat = '#[a-zA-Z0-9_-]*|@[a-zA-Z0-9_-]*'
        if len(args) <= 0 or args[0] == 0:
            return sharppat
        elif args[0] == 1:
            return atpat
        return bothpat
