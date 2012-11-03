visual-mark-ring-mode, v0.1
===========================

An Emacs minor-mode to display the locations of markers on the mark-ring.

The mark-ring is a list of former marks of the current buffer. It
allows the user to quickly jump to previously visited locations. This
minor-mode displays the target locations of these jumps directly in
the buffer, as soon as the user initiates the first jump by typing

  C-u C-SPC

![Screenshot of visual-mark-ring-mode](https://raw.github.com/kleiba/visual-mark-ring-mode/master/visual-mark-ring-mode.png "Screenshot")

How to use
----------

Add the following lines to your ~/.emacs file:

  (add-to-list 'load-path "/path/to/file")
  (autoload 'visual-mark-ring-mode "visual-mark-ring-mode"
    "Displays the position of marks in the mark-ring" t)

where you replace /path/to/file with the absolute path to the
directory where you saved this file.

Restart Emacs.

Now you can activate the mode in a specific buffer by typing

  M-x visual-mark-ring-mode

in that buffer.
