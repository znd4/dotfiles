import os
import subprocess
import tempfile
from pathlib import Path

from IPython import get_ipython
from prompt_toolkit.enums import DEFAULT_BUFFER
from prompt_toolkit.filters import (
    EmacsInsertMode,
    HasFocus,
    HasSelection,
    ViInsertMode,
    ViNavigationMode,
    ViSelectionMode,
)
from prompt_toolkit.keys import Keys

ip = get_ipython()
insert_mode = ViInsertMode() | EmacsInsertMode()


def open_editor(event):
    # Get the current input buffer.
    buf = event.current_buffer
    input_text = buf.text

    # Write the current input to a file.
    with tempfile.TemporaryDirectory() as td:
        f = Path(td) / "prompt.py"
        f.write_text(input_text)
        editor = os.getenv("EDITOR", "vim")
        subprocess.call([editor, f])

        new_input_text = f.read_text()

    # Clear the current buffer.
    buf.text = ""

    # Insert the new input.
    buf.insert_text(new_input_text)


# Register the shortcut if IPython is using prompt_toolkit.
if getattr(ip, "pt_app", None):
    print("Registering keyboard shortcut")
    registry = ip.pt_app.key_bindings
    registry.add_binding(
        "c-e",  # Change the key binding as needed.
        # filter=ViNavigationMode(),
        filter=(HasFocus(DEFAULT_BUFFER) & ~HasSelection()),
    )(open_editor)
