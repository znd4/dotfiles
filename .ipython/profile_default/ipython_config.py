c.InteractiveShellApp.extensions = [
    'autoreload'
]
# set autoreload to 2
c.InteractiveShellApp.exec_lines = [
    '%autoreload 2',
]
c.TerminalInteractiveShell.editing_mode = 'vi'
c.TerminalInteractiveShell.editor='nvim'
