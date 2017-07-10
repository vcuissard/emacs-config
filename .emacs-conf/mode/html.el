;;
;; html.el
;; 
;; Made by (thierry faucille)
;; Login   <faucil_t@epita.fr>
;; 
;; Started on  Tue Apr 23 09:20:08 1996 thierry faucille
;; Last update Sat May 11 14:46:07 1996 thierry faucille
;;
;;; ---------------------------- emacs variations ----------------------------

(defvar html-running-lemacs (if (string-match "Lucid" emacs-version) t nil)
  "Non-nil if running Lucid Emacs.")

(defvar html-running-epoch (boundp 'epoch::version)
  "Non-nil if running Epoch.")

;;; ------------------------------- variables --------------------------------

(defvar html-quotify-hrefs-on-find t
  "*If non-nil, all HREF's (and NAME's) in a file will be automatically 
quotified when the file is loaded.  This is useful for converting ancient 
HTML documents to SGML-compatible syntax, which mandates quoted HREF's.
This should always be T.")

(defvar html-use-highlighting html-running-epoch
  "*Flag to use highlighting for HTML directives in Epoch or Lucid Emacs; 
if non-NIL, highlighting will be used.  Default is T if you are running
Epoch; nil otherwise (for Lucid Emacs, font-lock is better; see 
html-use-font-lock instead).")

(defvar html-use-font-lock html-running-lemacs
  "*Flag to use font-lock for HTML directives in Lucid Emacs.  If non-NIL,
font-lock will be used.  Default is T if you are running with Lucid Emacs;
NIL otherwise.  This doesn't currently seem to work.  Bummer.  Ten points
to the first person who tells me why not.")

(defvar html-deemphasize-color "grey80"
  "*Color for de-highlighting HTML directives in Epoch or Lucid Emacs.")

(defvar html-emphasize-color "yellow"
  "*Color for highlighting HTML something-or-others in Epoch or Lucid Emacs.")

(defvar html-document-previewer "/usr/local/bin/xmosaic"
  "*Program to be used to preview HTML documents.  Program is assumed
to accept a single argument, a filename containing a file to view; program
is also assumed to follow the Mosaic convention of handling SIGUSR1 as
a remote-control mechanism.")

(defvar html-document-previewer-args "-ngh"
  "*Arguments to be given to the program named by html-document-previewer;
NIL if none should be given.")

(defvar html-sigusr1-signal-value 16
  "*Value for the SIGUSR1 signal on your system.  See, usually,
/usr/include/sys/signal.h.")

;;; --------------------------------- setup ----------------------------------

(defvar html-mode-syntax-table nil
  "Syntax table used while in html mode.")

(defvar html-mode-abbrev-table nil
  "Abbrev table used while in html mode.")
(define-abbrev-table 'html-mode-abbrev-table ())

(if html-mode-syntax-table
    ()
  (setq html-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\" ".   " html-mode-syntax-table)
  (modify-syntax-entry ?\\ ".   " html-mode-syntax-table)
  (modify-syntax-entry ?' "w   " html-mode-syntax-table))

(defvar html-mode-map nil "")
(if html-mode-map
    ()
  (setq html-mode-map (make-sparse-keymap))
  (define-key html-mode-map "\t" 'tab-to-tab-stop)
  (define-key html-mode-map "\C-ca" 'html-add-address)
  (define-key html-mode-map "\C-cb" 'html-add-blockquote)
  (define-key html-mode-map "\C-cc" 'html-add-code)
  (define-key html-mode-map "\C-cd" 'html-add-description-list)
  (define-key html-mode-map "\C-ce" 'html-add-description-entry)
  (define-key html-mode-map "\C-cg" 'html-add-img)
  (define-key html-mode-map "\C-ch" 'html-add-header)
  (define-key html-mode-map "\C-ci" 'html-add-list-or-menu-item)
  (define-key html-mode-map "\C-cl" 'html-add-normal-link)
  (define-key html-mode-map "\C-cm" 'html-add-menu)
  (define-key html-mode-map "\C-cn" 'html-add-numbered-list)
  (define-key html-mode-map "\C-cp" 'html-add-paragraph-separator)
  (define-key html-mode-map "\C-cr" 'html-add-normal-reference)
  (define-key html-mode-map "\C-cs" 'html-add-list)
  (define-key html-mode-map "\C-ct" 'html-add-title)
  (define-key html-mode-map "\C-cx" 'html-add-plaintext)
  ;; html-preview-document currently requires the primitive
  ;; signal-process, which is only in v19 (is it in gnu 19? dunno).
  (and html-running-lemacs
       (define-key html-mode-map "\C-cz" 'html-preview-document))
  (define-key html-mode-map "\C-c\C-b" 'html-add-bold)
  (define-key html-mode-map "\C-c\C-c" 'html-add-citation)
  (define-key html-mode-map "\C-c\C-e" 'html-add-emphasized)
  (define-key html-mode-map "\C-c\C-f" 'html-add-fixed)
  (define-key html-mode-map "\C-c\C-i" 'html-add-italic)
  (define-key html-mode-map "\C-c\C-k" 'html-add-keyboard)
  (define-key html-mode-map "\C-c\C-l" 'html-add-listing)
  (define-key html-mode-map "\C-c\C-m" 'html-add-sample)
  (define-key html-mode-map "\C-c\C-p" 'html-add-preformatted)
  (define-key html-mode-map "\C-c\C-s" 'html-add-strong)
  (define-key html-mode-map "\C-c\C-v" 'html-add-variable)
  (define-key html-mode-map "\M-\C-g"  'html-add-grave)
  (define-key html-mode-map "\M-\C-a"  'html-add-acute)
  (define-key html-mode-map "\M-\C-u"  'html-add-uml)
  (define-key html-mode-map "\M-\C-c"  'html-add-circ)
  (define-key html-mode-map "\M-\C-d"  'html-add-cedil)
  (define-key html-mode-map "\M-\C-t"  'html-add-tilde)
  
  ;;  (define-key html-mode-map ">" 'html-real-less-than)
  ;;  (define-key html-mode-map "&" 'html-real-greater-than)
  (define-key html-mode-map "\C-c>" 'html-greater-than)
  (define-key html-mode-map "\C-c<" 'html-less-than)
  (define-key html-mode-map "\C-c&" 'html-ampersand)
  (define-key html-mode-map "\C-c\C-rl" 'html-add-normal-link-to-region)
  (define-key html-mode-map "\C-c\C-rr" 'html-add-reference-to-region)
  )

;;; ------------------------------ highlighting ------------------------------

(if (and html-running-epoch html-use-highlighting)
    (progn
      (defvar html-deemphasize-style (make-style))
      (set-style-foreground html-deemphasize-style html-deemphasize-color)
      (defvar html-emphasize-style (make-style))
      (set-style-foreground html-emphasize-style html-emphasize-color)))

(if (and html-running-lemacs html-use-highlighting)
    (progn
      (defvar html-deemphasize-style (make-face 'html-deemphasize-face))
      (set-face-foreground html-deemphasize-style html-deemphasize-color)
      (defvar html-emphasize-style (make-face 'html-emphasize-face))
      (set-face-foreground html-emphasize-style html-emphasize-color)))

(if html-use-highlighting
    (progn
      (if html-running-lemacs
          (defun html-add-zone (start end style)
            "Add a Lucid Emacs extent from START to END with STYLE."
            (let ((extent (make-extent start end)))
              (set-extent-face extent style)
              (set-extent-data extent 'html-mode))))
      (if html-running-epoch
          (defun html-add-zone (start end style)
            "Add an Epoch zone from START to END with STYLE."
            (let ((zone (add-zone start end style)))
              (epoch::set-zone-data zone 'html-mode))))))

(defun html-maybe-deemphasize-region (start end)
  "Maybe deemphasize a region of text.  Region is from START to END."
  (and (or html-running-epoch html-running-lemacs)
       html-use-highlighting
       (html-add-zone start end html-deemphasize-style)))

;;; --------------------------------------------------------------------------
;;; ------------------------ command support routines ------------------------
;;; --------------------------------------------------------------------------

(defun html-add-link (link-object)
  "Add a link.  Single argument LINK-OBJECT is value of HREF in the
new anchor.  Mark is set after anchor."
  (let ((start (point)))
    (insert "<a")
    (insert " href=\"" link-object "\">")
    (html-maybe-deemphasize-region start (1- (point)))
    (insert "</a>")
    (push-mark)
    (forward-char -4)
    (html-maybe-deemphasize-region (1+ (point)) (+ (point) 4))))

(defun html-add-reference (ref-object)
  "Add a reference.  Single argument REF-OBJECT is value of NAME in the
new anchor.  Mark is set after anchor."
  (let ((start (point)))
    (insert "<A")
    (insert " NAME=\"" ref-object "\">")
    (html-maybe-deemphasize-region start (1- (point)))
    (insert "</A>")
    (push-mark)
    (forward-char -4)
    (html-maybe-deemphasize-region (1+ (point)) (+ (point) 4))))

(defun html-add-list-internal (type)
  "Set up a given type of list by opening the list start/end pair
and creating an initial element.  Single argument TYPE is a string,
assumed to be a valid HTML list type (e.g. \"UL\" or \"OL\").
Mark is set after list."
  (let ((start (point)))
    (insert "<" type ">\n")
    (html-maybe-deemphasize-region start (1- (point)))
    (insert "<LI> ")
    ;; Point goes right there.
    (save-excursion
      (insert "\n")
      (setq start (point))
      (insert "</" type ">\n")
      (html-maybe-deemphasize-region start (1- (point)))
      ;; Reuse start to set mark.
      (setq start (point)))
    (push-mark start t)))

(defun html-open-area (tag)
  "Open an area for entering text such as PRE, XMP, or LISTING."
  (let ((start (point)))
    (insert "<" tag ">\n")
    (html-maybe-deemphasize-region start (1- (point)))
    (save-excursion
      (insert "\n")
      (setq start (point))
      (insert "</" tag ">\n")
      (html-maybe-deemphasize-region start (1- (point)))
      ;; Reuse start to set mark.
      (setq start (point)))
    (push-mark start t)))

(defun html-open-field (tag)
  (let ((start (point)))
    (insert "<" tag ">")
    (html-maybe-deemphasize-region start (1- (point)))
    (setq start (point))
    (insert "</" tag ">")
    (html-maybe-deemphasize-region (1+ start) (point))
    (push-mark)
    (goto-char start)))
(defun html-open-line (tag)
  (let ((start (point)))
    (insert "<" tag ">")
    (html-maybe-deemphasize-region start (1- (point)))
    (setq start (point))
    (end-of-line 1)
    (insert "</" tag ">")
    (html-maybe-deemphasize-region (1+ start) (point))
    (push-mark)
    (goto-char start)))

;;; --------------------------------------------------------------------------
;;; -------------------------------- commands --------------------------------
;;; --------------------------------------------------------------------------

;; C-c a
(defun html-add-address ()
  "Add an address."
  (interactive)
  (html-open-field "ADDRESS"))

;; C-c b
(defun html-add-blockquote ()
  (interactive)
  (html-open-area "BLOCKQUOTE"))

;; C-c C-b
(defun html-add-bold ()
  (interactive)
  (html-open-line "B"))

;; C-c c
(defun html-add-code ()
  (interactive)
  (html-open-field "CODE"))

;; C-c C-c
(defun html-add-citation ()
  (interactive)
  (html-open-field "CITE"))

;; C-c d
(defun html-add-description-list ()
  "Add a definition list.  Blah blah."
  (interactive)
  (let ((start (point)))
    (insert "<DL>\n")
    (html-maybe-deemphasize-region start (1- (point)))
    (insert "<DT> ")
    ;; Point goes right there.
    (save-excursion
      (insert "\n<DD> \n")
      (setq start (point))
      (insert "</DL>\n")
      (html-maybe-deemphasize-region start (1- (point)))
      ;; Reuse start to set mark.
      (setq start (point)))
    (push-mark start t)))

;; C-c e
(defun html-add-description-entry ()
  "Add a definition entry.  Assume we're at the end of a previous
entry."
  (interactive)
  (let ((start (point)))
    (insert "\n<DT> ")
    (save-excursion
      (insert "\n<DD> "))))

;; C-c C-e
(defun html-add-emphasized ()
  (interactive)
  (html-open-field "EM"))

;; C-c C-f
(defun html-add-fixed ()
  (interactive)
  (html-open-field "TT"))

;; C-c g
(defun html-add-img (href)
  "Add an img."
  (interactive "sImage URL: ")
  (let ((start (point)))
    (insert "<IMG SRC=\"" href "\">")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))

;; C-c h
(defun html-add-header (size header)
  "Add a header."
  (interactive "sSize (1-6; 1 biggest): \nsHeader: ")
  (let ((start (point)))
    (insert "<H" size ">")
    (html-maybe-deemphasize-region start (1- (point)))
    (insert header)
    (setq start (point))
    (insert "</H" size ">\n")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))

;; C-c i
(defun html-add-list-or-menu-item ()
  "Add a list or menu item.  Assume we're at the end of the
last item."
  (interactive)
  (let ((start (point)))
    (insert "\n<LI> ")))

;; C-c C-i
(defun html-add-italic ()
  (interactive)
  (html-open-field "I"))

;; C-c C-k
(defun html-add-keyboard ()
  (interactive)
  (html-open-field "KBD"))

;; C-c l
(defun html-add-normal-link (link)
  "Make a link"
  (interactive "sLink to: ")
  (html-add-link link))

;; C-c C-l
(defun html-add-listing ()
  (interactive)
  (html-open-area "LISTING"))

;; C-c m
(defun html-add-menu ()
  "Add a menu."
  (interactive)
  (html-add-list-internal "MENU"))

;; C-c C-m
(defun html-add-sample ()
  (interactive)
  (html-open-field "SAMP"))

;; C-c n
(defun html-add-numbered-list ()
  "Add a numbered list."
  (interactive)
  (html-add-list-internal "OL"))

;; C-c p
(defun html-add-paragraph-separator ()
  "Add a paragraph separator."
  (interactive)
  (let ((start (point)))
    (insert " <P>")
    (html-maybe-deemphasize-region (+ start 1) (point))))

;; C-c C-p
(defun html-add-preformatted ()
  (interactive)
  (html-open-area "PRE"))

;; C-c r
(defun html-add-normal-reference (reference)
  "Add a reference (named anchor)."
  (interactive "sReference name: ")
  (html-add-reference reference))

;; C-c s
(defun html-add-list ()
  "Add a list."
  (interactive)
  (html-add-list-internal "UL"))

;; C-c C-s
(defun html-add-strong ()
  (interactive)
  (html-open-field "STRONG"))

;; C-c t
(defun html-add-title (title)
  "Add or modify a title."
  (interactive "sTitle: ")
  (save-excursion
    (goto-char (point-min))
    (if (and (looking-at "<TITLE>")
             (save-excursion
               (forward-char 7)
               (re-search-forward "[^<]*" 
                                  (save-excursion (end-of-line) (point)) 
                                  t)))
        ;; Plop the new title in its place.
        (replace-match title t)
      (insert "<TITLE>")
      (html-maybe-deemphasize-region (point-min) (1- (point)))
      (insert title)
      (insert "</TITLE>")
      (html-maybe-deemphasize-region (- (point) 7) (point))
      (insert "\n"))))

;; C-c C-v
(defun html-add-variable ()
  (interactive)
  (html-open-field "VAR"))

;; C-c x
(defun html-add-plaintext ()
  "Add plaintext."
  (interactive)
  (html-open-area "XMP"))

;;; --------------------------------------------------------------------------
;;; ---------------------------- region commands -----------------------------
;;; --------------------------------------------------------------------------

;; C-c C-r l
(defun html-add-normal-link-to-region (link start end)
  "Make a link that applies to the current region.  Again,
no completion."
  (interactive "sLink to: \nr")
  (save-excursion
    (goto-char end)
    (save-excursion
      (goto-char start)
      (insert "<A")
      (insert " HREF=\"" link "\">")
      (html-maybe-deemphasize-region start (1- (point))))
    (insert "</A>")
    (html-maybe-deemphasize-region (- (point) 3) (point))))

;; C-c C-r r
(defun html-add-reference-to-region (name start end)
  "Add a reference point (a link with no reference of its own) to
the current region."
  (interactive "sName: ")
  (or (string= name "")
      (save-excursion
        (goto-char end)
        (save-excursion
          (goto-char start)
          (insert "<A NAME=\"" name "\">")
          (html-maybe-deemphasize-region start (1- (point))))
        (insert "</A>")
        (html-maybe-deemphasize-region (- (point) 3) (point)))))

;;; --------------------------------------------------------------------------
;;; ---------------------------- special commands ----------------------------
;;; --------------------------------------------------------------------------
(defun html-add-grave (name)
  "Add a grave accent to char ."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "grave;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))
(defun html-add-acute (name)
  "Add an acute accent to char."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "acute;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))
(defun html-add-circ (name)
  "Add a circ accent to char ."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "circ;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))
(defun html-add-cedil (name)
  "Add a cedil to char ."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "cedil;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))
(defun html-add-uml (name)
  "Add a umlaut to char ."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "uml;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))
(defun html-add-tilde (name)
  "Add a tilde to char ."
  (interactive "sChar: ")
  (let ((start (point)))
    (insert "&" name "tilde;")
    (html-maybe-deemphasize-region (1+ start) (1- (point)))))

(defun html-less-than ()
  (interactive)
  (insert "&lt;"))

(defun html-greater-than ()
  (interactive)
  (insert "&gt;"))

(defun html-ampersand ()
  (interactive)
  (insert "&amp;"))

(defun html-real-less-than ()
  (interactive)
  (insert "<"))

(defun html-real-greater-than ()
  (interactive)
  (insert ">"))

(defun html-real-ampersand ()
  (interactive)
  (insert "&"))

;;; --------------------------------------------------------------------------
;;; --------------------------- Mosaic previewing ----------------------------
;;; --------------------------------------------------------------------------

;; OK, we work like this: We have a variable html-previewer-process.
;; When we start, it's nil.  First time html-preview-document is
;; called, we write the current document into a tmp file and call
;; Mosaic on it.  Second time html-preview-document is called, we
;; write the current document into a tmp file, write out a tmp config
;; file, and send Mosaic SIGUSR1.

;; This feature REQUIRES the Lisp command signal-process, which seems
;; to be a Lucid Emacs v19 feature.  It might be in GNU Emacs v19 too;
;; I dunno.

(defvar html-previewer-process nil
  "Variable used to track live viewer process.")

(defun html-write-buffer-to-tmp-file ()
  "Write the current buffer to a temp file and return the name
of the tmp file."
  (let ((filename (concat "/tmp/" (make-temp-name "html") ".html")))
    (write-region (point-min) (point-max) filename nil 'foo)
    filename))

(defun html-preview-document ()
  "Preview the current buffer's HTML document by spawning off a
previewing process (assumed to be Mosaic, basically) and controlling
it with signals as long as it's alive."
  (interactive)
  (let ((tmp-file (html-write-buffer-to-tmp-file)))
    ;; If html-previewer-process is nil, we start a process.
    ;; OR if the process status is not equal to 'run.
    (if (or (eq html-previewer-process nil)
            (not (eq (process-status html-previewer-process) 'run)))
        (progn
          (message "Starting previewer...")
          (setq html-previewer-process
                (if html-document-previewer-args
                    (start-process "html-previewer" "html-previewer"
                                   html-document-previewer 
                                   html-document-previewer-args 
                                   tmp-file)
                  (start-process "html-previewer" "html-previewer"
                                 html-document-previewer 
                                 tmp-file))))
      ;; We've got a running previewer; use it via SIGUSR1.
      (save-excursion
        (let ((config-file (format "/tmp/xmosaic.%d" 
                                   (process-id html-previewer-process))))
          (set-buffer (generate-new-buffer "*html-preview-tmp*"))
          (insert "goto\nfile:" tmp-file "\n")
          (write-region (point-min) (point-max)
                        config-file nil 'foo)
          ;; This is a v19 routine only.
          (signal-process (process-id html-previewer-process)
                          html-sigusr1-signal-value)
          (delete-file config-file)
          (delete-file tmp-file)
          (kill-buffer (current-buffer)))))))

;;; --------------------------------------------------------------------------
;;; --------------------------------------------------------------------------
;;; --------------------------------------------------------------------------

(defun html-replace-string-in-buffer (start end newstring)
  (save-excursion
    (goto-char start)
    (delete-char (1+ (- end start)))
    (insert newstring)))

;;; --------------------------- html-quotify-hrefs ---------------------------

(defun html-quotify-hrefs ()
  "Insert quotes around all HREF and NAME attribute value literals.

This remedies the problem with old HTML files that can't be processed
by SGML parsers. That is, changes <A HREF=foo> to <A HREF=\"foo\">."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while 
        (re-search-forward
         "<[aA][ \t\n]+\\([nN][aA][mM][eE]=[a-zA-Z0-9]+[ \t\n]+\\)?[hH][rR][eE][fF]="
         (point-max)
         t)
      (cond
       ((null (looking-at "\""))
        (insert "\"")
        (re-search-forward "[ \t\n>]" (point-max) t)
        (forward-char -1)
        (insert "\""))))))

;;; ------------------------------- html-mode --------------------------------

(defun html-mode ()
  "Major mode for editing HTML hypertext documents.  Special commands:\\{html-mode-map}
Turning on html-mode calls the value of the variable html-mode-hook,
if that value is non-nil.

More extensive documentation is available in the file 'html-mode.el'.
The latest (possibly unstable) version of this file will always be available
on anonymous FTP server ftp.ncsa.uiuc.edu in /Mosaic/elisp."
  (interactive)
  (kill-all-local-variables)
  (use-local-map html-mode-map)
  (setq mode-name "HTML")
  (setq major-mode 'html-mode)
  (setq local-abbrev-table html-mode-abbrev-table)
  (set-syntax-table html-mode-syntax-table)
  (run-hooks 'html-mode-hook)
  (and html-use-font-lock
       (html-fontify)))

;;; ------------------------------- our hooks --------------------------------

(defun html-html-mode-hook ()
  "Hook called from html-mode-hook.  
Run htlm-quotify-hrefs if html-quotify-hrefs-on-find is non-nil."
  ;; Quotify existing HREF's if html-quotify-hrefs-on-find is non-nil.
  (and html-quotify-hrefs-on-find (html-quotify-hrefs)))

;;; ------------------------------- hook setup -------------------------------

;; Author: Daniel LaLiberte (liberte@cs.uiuc.edu).
(defun html-postpend-unique-hook (hook-var hook-function)
  "Postpend HOOK-VAR with HOOK-FUNCTION, if it is not already an element.
hook-var's value may be a single function or a list of functions."
  (if (boundp hook-var)
      (let ((value (symbol-value hook-var)))
        (if (and (listp value) (not (eq (car value) 'lambda)))
            (and (not (memq hook-function value))
                 (set hook-var (append value (list hook-function))))
          (and (not (eq hook-function value))
               (set hook-var (append value (list hook-function))))))
    (set hook-var (list hook-function))))

(html-postpend-unique-hook 'html-mode-hook 'html-html-mode-hook)

;;; -------------------------- lucid menubar setup ---------------------------

(if html-running-lemacs
    (progn
      (defvar html-menu
        '("HTML Mode"
          ["Open Address"         html-add-address      t]
          ["Open Blockquote"      html-add-blockquote   t]
          ["Open Header"          html-add-header       t]
          ["Open Hyperlink"       html-add-normal-link  t]
          ["Open Listing"         html-add-listing      t]
          ["Open Plaintext"       html-add-plaintext    t]
          ["Open Preformatted"    html-add-preformatted t]
          ["Open Reference"       html-add-normal-reference    t]
          ["Open Title"           html-add-title        t]
          "----"
          ["Open Bold"            html-add-bold         t]
          ["Open Citation"        html-add-citation     t]
          ["Open Code"            html-add-code         t]
          ["Open Emphasized"      html-add-emphasized   t]
          ["Open Fixed"           html-add-fixed        t]
          ["Open Keyboard"        html-add-keyboard     t]
          ["Open Sample"          html-add-sample       t]
          ["Open Strong"          html-add-strong       t]
          ["Open Variable"        html-add-variable     t]
          "----"
          ["Add Inlined Image"    html-add-img          t]
          ["End Paragraph"        html-add-paragraph-separator t]
          ["Preview Document"     html-preview-document t]
          "----"
          ("Definition List ..."
           ["Open Definition List"    html-add-description-list  t]
           ["Add Definition Entry"    html-add-description-entry t]
           )
          ("Other Lists ..."
           ["Open Unnumbered List"    html-add-list          t]
           ["Open Numbered List"      html-add-numbered-list t]
           ["Open Menu"               html-add-menu          t]
           "----"
           ["Add List Or Menu Item"   html-add-list-or-menu-item   t]
           )           
          ("Operations On Region ..."
           ["Add Hyperlink To Region" html-add-normal-link-to-region  t]
           ["Add Reference To Region" html-add-reference-to-region    t]
           )
          ("Reserved Characters ..."
           ["Less Than (<)"           html-real-less-than      t]
           ["Greater Than (>)"        html-real-greater-than   t]
           ["Ampersand (&)"           html-real-ampersand      t]
           )
          )
        )

      (defun html-menu (e)
        (interactive "e")
        (mouse-set-point e)
        (beginning-of-line)
        (popup-menu html-menu))
      (define-key html-mode-map 'button3 'html-menu)

      (defun html-install-menubar ()
        (if (and current-menubar (not (assoc "HTML" current-menubar)))
            (progn
              (set-buffer-menubar (copy-sequence current-menubar))
              (add-menu nil "HTML" (cdr html-menu)))))
      (html-postpend-unique-hook 'html-mode-hook 'html-install-menubar)

      (defconst html-font-lock-keywords
        (list
         '("\\(<[^>]*>\\)+" . font-lock-comment-face)
         '("[Hh][Rr][Ee][Ff]=\"\\([^\"]*\\)\"" 1 font-lock-string-face t)
         '("[Ss][Rr][Cc]=\"\\([^\"]*\\)\"" 1 font-lock-string-face t))
        "Patterns to highlight in HTML buffers.")

      (defun html-fontify ()
        (font-lock-mode 1)
        (make-local-variable 'font-lock-keywords) 
        (setq font-lock-keywords html-font-lock-keywords)
        (font-lock-hack-keywords (point-min) (point-max))
        (message "Hey boss, we been through html-fontify."))
      )
  )

;;; ------------------------------ final setup -------------------------------

(or (assoc "\\.html$" auto-mode-alist)
    (setq auto-mode-alist (cons '("\\.html$" . html-mode) auto-mode-alist)))

(provide 'html-mode)

