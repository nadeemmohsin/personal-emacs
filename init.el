;; Basic UI customizations.
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Fix the default jerky scrolling.
(setq scroll-step 1)

;; Put backup files in a separate directory.
(setq backup-directory-alist `(("." . "~/.emacs.bak")))

;; Keep customized variables in a separate file.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

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
  (setq completion-styles '(substring orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Consult
(use-package consult)


;; Ace-window for easy window switching.
(use-package ace-window
  :init
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind (("M-o" . 'ace-window)))

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

;; Themes and Modelines
(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))


;; Evil mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)

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
  :config
  (global-evil-surround-mode 1))

;; Comments.
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

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
  :config
  (general-evil-setup t)

  ;; Set Space as the leader a la Doom.
  (defconst my-leader "SPC")
  (general-create-definer my-leader-def
    :prefix my-leader)
  (general-override-mode) ;; https://github.com/noctuid/general.el/issues/99#issuecomment-360914335

  ;; Doom-style hotkeys.
  (my-leader-def
    :states '(motion normal visual)
    :keymaps 'override ;; https://github.com/noctuid/general.el/issues/99#issuecomment-360914335

    ;; Equivalent to C-u
    "u" '(universal-argument :which-key "Universal argument")

    ;; Eval Lisp regions.
    ";" '(eval-region :which-key "eval-region")

    ;; Config
    "c" '(:ignore t :which-key "Config")
    "c g" '(nadeemm/open-gitconfig :which-key "Open .gitconfig")
    "c i" '(nadeemm/open-init-file :which-key "Open init.el")
    
    ;; Projectile
    "p" '(:ignore t :which-key "Projectile")
    "p ." '(projectile-find-file :which-key "Projectile find file")
    "p >" '(projectile-find-file-other-window :which-key "Projectile find file (new window)")

    ;; Files.
    "." '(find-file :which-key "Find file")
    ">" '(find-file-other-window :which-key "Find file (new window)")

    ;; Buffer management.
    "," '(consult-buffer :which-key "Switch buffer")
    "x" '(nadeemm/open-scratch-buffer :which-key "Open scratch buffer")

    "b" '(:ignore t :which-key "Buffers")
    "b b" '(consult-buffer :which-key "Switch buffer")
    "b B" '(ibuffer-list-buffers :which-key "Interactive buffer list")
    "b l" '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
    "b k" '(kill-current-buffer :which-key "Kill current buffer")
    "b d" '(kill-buffer :which-key "Kill buffer")
    "b r" '(revert-buffer-quick :which-key "Revert buffer")

    ;; Window management.
    "o" '(other-window :which-key "Switch window")
    "O" '(ace-window :which-key "Find window")
    "w" '(:ignore t :which-key "Windows")
    "w h" '(evil-window-split :which-key "Horizontal split")
    "w v" '(evil-window-vsplit :which-key "Vertical split")
    "w d" '(evil-window-delete :which-key "Delete window")
    "w w" '(delete-other-windows :which-key "Delete other windows")

    ;; Search
    "s" '(:ignore t :which-key "Search")
    "s s" '(consult-line :which-key "Find line")

    ;; Dired.
    "d" '(dired-jump :which-key "dired-jump")

    ;; LSP
    "l" '(:ignore t :which-key "LSP")
    "l." '(lsp-find-definition :which-key "Find definition")
    "l >" '(lsp-find-references :which-key "Find references")
    "l r" '(lsp-rename :which-key "Rename")
    "l d" '(lsp-describe-thing-at-point :which-key "Describe symbol")

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


;; Dired setup.
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

;; Highlight current line.
(global-hl-line-mode 1)

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Auto revert buffers.
(global-auto-revert-mode)

;; Uniquify buffer names.
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-after-kill-buffer-p t)     ;; Rename after killing uniquified buffers.
(setq uniquify-ignore-buffers-re "^\\*")  ;; Don't mess with special buffers.

;; Show column numbers everywhere.
(column-number-mode)

;; Line numbers everywhere except for shells and Org.
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
		term-mode-hook
		vterm-mode-hook
		shell-mode-hook
		eshell-mode-hook
		dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


;; Go programming support.
(use-package go-mode)

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

;; Set the garbage collection threshold to high (100 MB)
;; since LSP client-server communication generates a lot of output/garbage
(setq gc-cons-threshold 100000000)
;; To increase the amount of data Emacs reads from a process
(setq read-process-output-max (* 1024 1024)) 
