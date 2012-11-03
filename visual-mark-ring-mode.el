;; Visual Mark-Ring Mode, v0.1
;; ---------------------------
;;
;; Copyright 2012 Thomas Kleinbauer
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.
;;
;; How to use
;; ----------
;;
;; Add the following lines to your ~/.emacs file:
;;
;;   (add-to-list 'load-path "/path/to/file")
;;   (autoload 'visual-mark-ring-mode "visual-mark-ring-mode"
;;     "Displays the position of marks in the mark-ring" t)
;;
;; where you replace /path/to/file with the absolute path to the
;; directory where you saved this file.
;;
;; Restart Emacs.
;;
;; Now you can activate the mode in a specific buffer by typing
;;
;;   M-x visual-mark-ring-mode
;;
;; in that buffer. Then, typing
;;
;;   C-u C-SPC
;;
;; to jump to the locations of the mark-ring will display these
;; locations directly in the buffer.

(define-minor-mode visual-mark-ring-mode
  "Displays the position of marks in the mark-ring."
  :init-value nil 
  :lighter " vmr"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-SPC")
              '(lambda (arg)
                 (interactive "P")
                 (when arg (visual-mark-ring-activate))
                 (set-mark-command arg)))
            map)
  (make-variable-buffer-local 'visual-mark-ring-overlays))

(defcustom visual-mark-ring-face '(:foreground "black" :background "yellow" :box t)
  "Display style for markers."
  :group 'visual-mark
  :type '(choice (face) (plist)))

(defcustom visual-mark-mode-num-markers 100
  "The maximum number of markers displayed."
  :group 'visual-mark
  :type '(integer))

(defconst visual-mark-ring-overriding-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-SPC") 'set-mark-command)
    (define-key map (kbd "C-u") 'universal-argument)
    (define-key map [t] '(lambda () (interactive) (visual-mark-ring-deactivate)))
    map))

(defun visual-mark-ring-activate ()
  ;; this function sets `overriding-local-map' but only if it is
  ;; currently `nil'.
  (unless overriding-local-map
    (visual-mark-ring-show)
    (setq overriding-local-map visual-mark-ring-overriding-map)))

(defun visual-mark-ring-deactivate ()
  (setq overriding-local-map nil)
  (visual-mark-ring-hide)
  (let ((command (key-binding (this-command-keys-vector))))
    (when command
      (call-interactively command))))

(defun visual-mark-ring-show ()
  "Displays the position of all marks currently in this buffer's
`mark-ring'."
  ;; remove existing marker highlights, if any
  (visual-mark-ring-hide)

  (let (pos-index-pairs overlay)
    (let ((markers (cons (mark-marker) mark-ring))
          (marker-index 0)
          (count -1)
          marker)
      ;; iterate through this buffer's mark-ring to find all positions
      ;; that need to be highlighted
      (while (and markers (< (setq count (1+ count)) visual-mark-mode-num-markers))
        (setq marker (car markers) markers (cdr markers))
        (if (marker-position marker)
            (setq pos-index-pairs (cons (cons (marker-position marker)
                                              (setq marker-index (1+ marker-index)))
                                        pos-index-pairs)))))
    ;; we sort the marker entries so we can combine multiple marks at
    ;; the same location into one overlay
    (setq pos-index-pairs
          (sort pos-index-pairs '(lambda (x y) (let ((posx (car x)) (posy (car y)))
                                                 (if (= posx posy)
                                                     (< (cdr x) (cdr y))
                                                   (< posx posy))))))
    ;; create overlays
    (while pos-index-pairs
      (setq marker (car pos-index-pairs)
            pos-index-pairs (cdr pos-index-pairs)
            display-string (number-to-string (cdr marker)))
      ;; check if there are multiple markers at the same location
      (while (and pos-index-pairs (= (caar pos-index-pairs) (car marker)))
        (setq display-string (format "%s,%i" display-string (cdar pos-index-pairs)) 
              pos-index-pairs (cdr pos-index-pairs)))
      ;; make an overlay to display the marker
      (setq overlay (make-overlay (car marker) (1+ (car marker)))
            visual-mark-ring-overlays (cons overlay visual-mark-ring-overlays))
      ;; format the display string for the marker
      (overlay-put overlay 'before-string display-string)
      (put-text-property 0 (length display-string) 
                         'face visual-mark-ring-face display-string))))

(defun visual-mark-ring-hide ()
  "Remove the visualizations of the mark-ring entries from the
current buffer."
  (let (overlay)
    (while visual-mark-ring-overlays
      (delete-overlay (car visual-mark-ring-overlays))
      (setq visual-mark-ring-overlays (cdr visual-mark-ring-overlays)))))
