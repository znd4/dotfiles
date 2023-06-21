from IPython.core.pylabtools import backends
from IPython.core.shellapp import backend_keys

c = get_config()
c.InteractiveShellApp.extensions = ["autoreload"]
# set autoreload to 2
c.InteractiveShellApp.exec_lines = [
    "%autoreload 2",
]
c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.editor = "nvim"


# iterm2 = "asyncio"
# breakpoint()
# backends[iterm2] = "module://matplotlib_iterm2.backend_iterm2"
# backend_keys.append(iterm2)
#
# c.TerminalIPythonApp.pylab = iterm2
