;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

(doom!
       :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       company
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       indent-guides
       modeline
       nav-flash
       neotree
       ophints
       (popup +defaults)
       tabs
       treemacs
       unicode
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets
       word-wrap

       :emacs
       dired
       electric
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       docker
       (eval +overlay)
       lookup
       lsp
       magit
       make
       pdf
       tree-sitter
       upload

       :os
       tty

       :lang
       emacs-lisp
       json
       (javascript +lsp)
       latex
       markdown
       org
       (python +lsp)
       (rust +lsp)
       sh
       (web +lsp)
       yaml

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       calendar

       :config
       (default +bindings +smartparens))