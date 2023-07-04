;; Initialize package archives.
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Use-package for cleaner config.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Basic customizations.
(use-package emacs
  :init
  ;; UI defaults.
  (setq inhibit-startup-message t
	initial-scratch-message nil
	sentence-end-double-space nil
	scroll-step 1
	scroll-conservatively 101)

  ;; Turn off unnecessary frills.
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (menu-bar-mode -1)

  ;; Use y/n instead of overly cumbersome yes/no.
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; Give backup files their own directory, and custom vars their own file.
  (setq backup-directory-alist `(("." . "~/.emacs.bak"))
	custom-file (concat user-emacs-directory "custom.el"))
  (load custom-file 'noerror)

  ;; Uniquify buffer names.
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-after-kill-buffer-p t)     ;; Rename after killing uniquified buffers.
  (setq uniquify-ignore-buffers-re "^\\*")  ;; Don't mess with special buffers.

  ;; Show column numbers everywhere.
  (column-number-mode)

  ;; Overwrite selection on paste.
  (delete-selection-mode t)

  ;; Highlight current line.
  (global-hl-line-mode 1)

  ;; Line numbers everywhere except for shells and Org.
  (global-display-line-numbers-mode t)
  (dolist (mode '(org-mode-hook
		  term-mode-hook
		  vterm-mode-hook
		  shell-mode-hook
		  eshell-mode-hook
		  dired-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  ;; Auto revert buffers.
  (global-auto-revert-mode)

  ;; Follow symlinks automatically.
  (setq vc-follow-symlinks t)

  ;; Recent files mode.
  (recentf-mode t)

  ;; Winner mode to remember window states.
  (winner-mode t)

  ;; Use TAB for indentation and completion.
  (setq tab-always-indent 'complete)

  ;; Close parens automatically. 
  (electric-pair-mode 1)

  ;; Set the garbage collection threshold to high (100 MB) since LSP
  ;; client-server communication generates a lot of output/garbage
  (setq gc-cons-threshold 100000000)

  ;; To increase the amount of data Emacs reads from a process
  (setq read-process-output-max (* 1024 1024)))


;; Themes and Modelines
;; (use-package doom-themes
;;   :init (load-theme 'doom-one t))

(use-package vscode-dark-plus-theme
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))


;; Ace-window for easy window switching.
(use-package ace-window
  :init
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind (("M-o" . 'ace-window)))


;; Some functions for going to frequently used files or buffers.
(defun nadeemm/open-scratch-buffer ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun nadeemm/open-gitconfig ()
  (interactive)
  (find-file "~/.gitconfig"))

(defun nadeemm/open-init-file ()
  (interactive)
  (find-file (concat user-emacs-directory "init.el")))

;; Mimic the nice stuff in Doom with general.el
(use-package general
  :demand t
  :config
  (general-evil-setup)

  ;; Set Space as the leader a la Doom.
  ;; C-SPC for when we're in insert mode.
  (defconst nadeemm/leader "SPC")
  (defconst nadeemm/global-leader "C-SPC")

  (general-create-definer nadeemm/leader-def
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix nadeemm/leader
    :global-prefix nadeemm/global-leader)

  ;; Doom-style hotkeys.
  (nadeemm/leader-def
    "SPC" '(execute-extended-command :which-key "Execute command")
    ;; Equivalent to C-u
    "u" '(universal-argument :which-key "Universal argument")

    ;; Eval Lisp regions.
    ";" '(eval-last-sexp :which-key "Evaluate last sexp")
    ":" '(eval-defun :which-key "Evaluate defun")

    ;; Config
    "c" '(:ignore t :which-key "Config")
    "c g" '(nadeemm/open-gitconfig :which-key "Open .gitconfig")
    "c i" '(nadeemm/open-init-file :which-key "Open init.el")

    ;; Projectile
    "p" '(:ignore t :which-key "Projectile")
    ;; Remaining bindings in Projectile section.

    ;; Files.
    "." '(find-file :which-key "Find file")
    ">" '(find-file-other-window :which-key "Find file (new window)")

    ;; Buffer management.
    "," '(consult-buffer :which-key "Switch buffer")
    "x" '(nadeemm/open-scratch-buffer :which-key "Open scratch buffer")

    "a" '(:ignore t :which-key "Avy")
    ;; Remaining bindings in Avy config.

    "b" '(:ignore t :which-key "Buffers")
    "b b" '(consult-buffer :which-key "Switch buffer")
    "b B" '(ibuffer-list-buffers :which-key "Interactive buffer list")
    "b l" '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
    "b k" '(kill-current-buffer :which-key "Kill current buffer")
    "b d" '(kill-buffer :which-key "Kill buffer")
    "b r" '(revert-buffer-quick :which-key "Revert buffer")

    ;; Window management.
    "o" '(other-window :which-key "Cycle window")
    "O" '(ace-window :which-key "Switch window")
    "w" '(:ignore t :which-key "Windows")
    "w h" '(evil-window-split :which-key "Horizontal split")
    "w v" '(evil-window-vsplit :which-key "Vertical split")
    "w d" '(evil-window-delete :which-key "Delete window")
    "w w" '(delete-other-windows :which-key "Delete other windows")

    ;; Search
    "s" '(:ignore t :which-key "Search")
    "s s" '(consult-line :which-key "Find line")

    ;; Dired.
    "d" '(:ignore t :which-key "Dired")

    ;; Registers
    "r" '(:ignore t :which-key "Registers")
    "r s" '(consult-register-store :which-key "Store register")
    "r l" '(consult-register-load :which-key "Load register")
    "r m" '(consult-bookmark :which-key "Bookmarks")

    ;; Git
    "g" '(:ignore t :which-key "Magit")
    ;; Remaining bindings in magit section.

    ;; LSP
    "l" '(:ignore t :which-key "LSP")
    ;; Remaining bindings in LSP section.

    ;; Flycheck
    "f" '(:ignore t :which-key "Flycheck")
    ;; Remaining bindings in Flycheck section.

    ;; help
    "h" '(:ignore t :which-key "Help")
    "h f" '(helpful-callable :which-key "Describe function")
    "h k" '(helpful-key :which-key "Describe key")
    "h v" '(helpful-variable :which-key "Describe variable")
    "h o" '(helpful-symbol :which-key "Describe symbol")
    "h m" '(describe-mode :which-key "Describe mode")
    "h F" '(describe-face :which-key "Describe face")
    "h w" '(where-is :which-key "where-is")
    "h ." '(display-local-help :which-key "Display local help")))


;; Evil mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-fu)

  :config
  (evil-mode 1)

  ;; TODO: Can this be done more neatly using general?
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (define-key evil-normal-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-insert-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-visual-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "C-a") 'evil-beginning-of-line)
  (define-key evil-insert-state-map (kbd "C-a") 'evil-beginning-of-line)
  (define-key evil-visual-state-map (kbd "C-a") 'evil-beginning-of-line)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))


;; Turn off Evil mode for terminals.
(defun nadeem/emacs-mode-only-hook ()
  (dolist (mode '(term-mode
		  vterm-mode
		  shell-mode
		  git-rebase-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Because mucking around with surroundings is always cool.
(use-package evil-surround
  :general
  (:states 'operator
	   "s" 'evil-surround-edit
	   "S" 'evil-Surround-edit)
  (:states 'visual
	   "S" 'evil-surround-region
	   "gS" 'evil-Surround-region)
  :config
  (global-evil-surround-mode 1))

;; Comments.
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

;; Evil-goggles to make changes more obvious.
(use-package evil-goggles
  :after evil
  :demand
  :init
  (setq evil-goggles-duration 0.05)
  :config
  (push '(evil-operator-eval
          :face evil-goggles-yank-face
          :switch evil-goggles-enable-yank
          :advice evil-goggles--generic-async-advice)
        evil-goggles--commands)
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))


;; Use Avy to move around the page really fast.
(use-package avy
  :general
  (:states 'normal
	   "s" 'avy-goto-char-2)
  (nadeemm/leader-def
    "a a" '(avy-goto-char-2 :which-key "Find bigram")
    "a l" '(avy-goto-line :which-key "Go to line")
    "a s" '(avy-goto-char-timer :which-key "Find by prefix")))


;; Undo fu
(use-package undo-fu
  :demand
  :general
  ;; Bind these to the Evil shortcuts.
  (:states 'normal
	   "u" 'undo-fu-only-undo
	   "C-r" 'undo-fu-only-redo))

;; Natural zoom.
(use-package emacs
  :general
  ("C-=" 'text-scale-increase)
  ("C--" 'text-scale-decrease))


;; Vertico
(use-package vertico
  :bind (:map vertico-map
	      ("C-j" . vertico-next)
	      ("C-k" . vertico-previous)
	      :map minibuffer-local-map
	      ("C-w" . backward-kill-word))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

;; Marginalia
(use-package marginalia
  :after vertico
  :bind (("M-A" . marginalia-cycle))
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; Save history
(use-package savehist
  :init
  (savehist-mode))

;; Orderless for fuzzy completion.
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

;; Consult
(use-package consult
  :init
  (setq register-preview-delay 0.5
	register-preview-function #'consult-register-format))

;; Embark
(use-package embark
  :after vertico
  :general
  (general-nmap "C-l" 'embark-act)
  (vertico-map
   "C-l" #'embark-act))

(use-package embark-consult
  :after (embark consult))

;; Yasnippet
(use-package yasnippet
  :hook
  (prog-mode . yas-minor-mode))

;; Corfu.
(use-package corfu
  :bind
  :general
  ;; Prevent the Emacs kill-line binding from conflicting with corfu-previous.
  (evil-insert-state-map "C-k" nil)
  (:keymaps 'corfu-map
	    ;; Basic keybindings for completion popup.
	    "C-j" #'corfu-next
	    "C-k" #'corfu-previous
	    "M-h" #'corfu-info-documentation
	    ;; For orderless style completion.
	    "SPC" #'corfu-insert-separator)
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-min-width 80)
  (corfu-max-width corfu-min-width) ;; Always use same width.
  (corfu-preselect-first t)
  (corfu-preview-current 'insert)
  ;; Use corfu for LSP completions.
  (lsp-completion-provider :none)
  :init
  (global-corfu-mode))


;; Kind-icon to make Corfu look a bit nicer.
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-use-icons t)
  (kind-icon-defalut-face 'corfu-default)
  (kind-icon-blend-background nil)
  (kind-icon-blend-frac 0.08)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))


;; Helpful and which-key to make life easier.
(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-max-display-columns 6)
  (setq which-key-idle-delay 0.5))


;; Dired setup.
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :general
  (nadeemm/leader-def
    "d j" '(dired-jump :which-key "Open buffer directory")
    "d p" '(projectile-dired :which-key "Open project root"))
  :custom ((dired-listing-switches "-agho --group-directories-first")))

(use-package dired-single
  :after dired
  :general
  (dired-mode-map
   :states 'normal
   "h" 'dired-single-up-directory
   "l" 'dired-single-buffer
   "q" 'kill-current-buffer))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))


;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


;; Go programming support.
(use-package go-mode
  :config
  (require 'lsp-go))

;; Flycheck.
(use-package flycheck
  :hook ((go-mode . flycheck-mode))
  :general
  (nadeemm/leader-def
    "f" '(:keymap flycheck-command-map :which-key "Flycheck")))

;; Protobuf-mode isn't in a package repository, so we
;; pull it from our own unpackaged directory.
;; For reference, this lives at:
;; https://github.com/protocolbuffers/protobuf/blob/main/editors/protobuf-mode.el
(add-to-list 'load-path (concat user-emacs-directory "unpackaged"))
(add-to-list 'auto-mode-alist '("\\.proto$" . protobuf-mode))
(require 'protobuf-mode)

;; Note that this requires installing gopls.
;; $ go get golang.org/x/tools/gopls@latest
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :general
  (nadeemm/leader-def
    "l l" '(:keymap lsp-command-map :which-key "All commands")
    "l ." '(lsp-ui-peek-find-definitions :which-key "Find definition")
    "l t" '(lsp-find-type-definition :which-key "Find type definition")
    "l >" '(lsp-ui-peek-find-references :which-key "Find references")
    "l a" '(lsp-execute-code-action :which-key "Execute code action")
    "l d" '(lsp-describe-thing-at-point :which-key "Describe symbol")
    "l g" '(lsp-ui-doc-glance :which-key "Doc glance")
    "l r" '(lsp-rename :which-key "Rename"))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t)
  :hook
  ((go-mode) . lsp))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t))


;; Magit
(use-package magit
  :general
  (nadeemm/leader-def
    "g s" '(magit-status :which-key "Status")
    "g b" '(magit-blame :which-key "Blame")
    "g l" '(magit-log :which-key "Log"))
  :init
  (setq magit-log-arguments '("--graph" "--decorate" "--color")
	git-commit-fill-column 80))

;; Projectile
(use-package projectile
  :demand
  :general
  (nadeemm/leader-def
    "p" '(:keymap projectile-command-map :which-key "project")
    "p <escape>" 'keyboard-escape-quit
    "p a" '(projectile-add-known-project :wk "add known"))
  :custom
  (projectile-project-search-path '("~/repos"))
  :config
  (projectile-mode))
