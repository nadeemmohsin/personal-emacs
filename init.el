;; Basic UI customizations.
(setq inhibit-startup-message t) 
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Bit of breathing room on the side.
(set-fringe-mode 10)

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
(use-package consult
  :bind (("C-s" . consult-line)
	 ("M-m" . consult-buffer)
	 ("M-M" . consult-buffer-other-window)))


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

    ;; Projectile
    "p" '(:ignore t :which-key "Projectile")
    "p." '(projectile-find-file :which-key "Projectile find file")
    "p>" '(projectile-find-file-other-window :which-key "Projectile find file (new window)")

    ;; Files.
    "." '(find-file :which-key "Find file")
    ">" '(find-file-other-window :which-key "Find file (new window)")

    ;; Buffer management.
    "," '(consult-buffer :which-key "Switch buffer")
    "x" '(open-scratch-buffer :which-key "Open scratch buffer")
    "b" '(:ignore t :which-key "Buffers")
    "bb" '(consult-buffer :which-key "Switch buffer")
    "bl" '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
    "bk" '(kill-current-buffer :which-key "Kill current buffer")
    "bd" '(kill-buffer :which-key "Kill buffer")
    "br" '(revert-buffer-quick :which-key "Revert buffer")

    ;; Window management.
    "o" '(other-window :which-key "Switch window")
    "O" '(ace-window :which-key "Find window")
    "w" '(:ignore t :which-key "Windows")
    "wh" '(evil-window-split :which-key "Horizontal split")
    "wv" '(evil-window-vsplit :which-key "Vertical split")
    "wd" '(evil-window-delete :which-key "Delete window")
    "ww" '(delete-other-windows :which-key "Delete other windows")
    
    ;; Dired.
    "d" '(dired-jump :which-key "dired-jump")

    ;; help
    "h" '(:ignore t :which-key "Help")
    "hf" '(helpful-callable :which-key "Describe function")
    "hk" '(helpful-key :which-key "Describe key")
    "hv" '(helpful-variable :which-key "Describe variable")
    "ho" '(helpful-symbol :which-key "Describe symbol")
    "hm" '(describe-mode :which-key "Describe mode")
    "hF" '(describe-face :which-key "Describe face")
    "hw" '(where-is :which-key "where-is")
    "h." '(display-local-help :which-key "Display local help")))


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

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Auto revert buffers.
(global-auto-revert-mode)

;; Uniquify buffer names.
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-after-kill-buffer-p t)     ;; Rename after killing uniquified buffers.
(setq uniquify-ignore-buffers-re "^\\*")  ;; Don't mess with special buffers.

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
