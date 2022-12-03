;;; init.el --- Emacs configuration file

;;; Commentary:

;;; Code:
(defvar *emacs-init-load-start* (current-time))

(defun time-to-ms (time)
  "Convert TIME to milliseconds."
  (+ (* (+ (* (car time) (expt 2 16)) (car (cdr time))) 1000000) (car (cdr (cdr time)))))

(defun display-timing ()
  "Display delta time between '*emacs-init-load-start*' and the 'current-time'."
  (message "Emacs loaded in %dms with %d garbage collections."
           (/ (- (time-to-ms (current-time)) (time-to-ms *emacs-init-load-start*)) 1000)
           gcs-done))

(add-hook 'emacs-startup-hook #'display-timing t)

(setq gc-cons-threshold (* 200 1000 1000))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

(straight-use-package 'use-package)

(use-package no-littering
  :custom
  (auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package nord-theme)

(use-package image-dired)

(use-package dired-atool
  :config (dired-atool-setup))

(use-package dired-collapse
  :hook ((dired-mode . dired-collapse-mode)))

(use-package delight
  :init
  (delight '((eldoc-mode nil "eldoc")
             (emacs-lisp-mode "ELisp" :major)
             (yas-minor-mode nil yasnippet)
             (lsp-lens-mode nil lsp-lens))))

(use-package command-log-mode
  :commands command-log-mode
  :bind (("C-c c l" . command-log-mode)))

(use-package which-key
  :defer 0
  :delight
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.2))

(use-package ace-window
  :delight
  :bind (("M-o" . ace-window)))

(use-package ivy
  :delight
  :bind (("C-s"     . swiper-isearch)
         ("M-x"     . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-r" . counsel-recentf)
         ("C-x d"   . counsel-dired)
         ("M-y"     . counsel-yank-pop)
         ("C-x b"   . ivy-switch-buffer)
         ("C-c v"   . ivy-push-view)
         ("C-c V"   . ivy-pop-view)
         ("C-c k"   . counsel-rg)
         ("C-c b"   . counsel-bookmark)
         ("C-c d"   . counsel-descbinds)
         ("C-c o"   . counsel-outline))
  :config
  (ivy-mode 1)
  :custom
  (ivy-count-format "(%d/%d) "))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :after ivy
  :delight
  :init
  (counsel-mode 1))

(use-package swiper
  :after ivy)

(use-package ivy-xref
  :after ivy
  :custom
  (xref-show-definitions-function #'ivy-xref-show-defs)
  (xref-show-xrefs-function #'ivy-xref-show-xrefs))

(use-package company
  :delight
  :hook (prog-mode . company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :delight
  :hook (company-mode . company-box-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package projectile
  :delight
  :config
  (projectile-mode)
  :custom
  (projectile-completion-system 'ivy)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package counsel-projectile
  :after projectile
  :delight
  :config
  (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :bind
  ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package paredit
  :delight
  :hook ((emacs-lisp-mode                  . 'enable-paredit-mode)
         (lisp-mode                        . 'enable-paredit-mode)
         (lisp-interaction-mode            . 'enable-paredit-mode)
         (scheme-mode                      . 'enable-paredit-mode)
         (eval-expression-minibuffer-setup . 'enable-paredit-mode)
         (clojure-mode                     . 'enable-paredit-mode)
         (clojurescript-mode               . 'enable-paredit-mode)
         (clojurec-mode                    . 'enable-paredit-mode)
         (cider-repl-mode                  . 'enable-paredit-mode))
  :config
  (show-paren-mode t)
  :bind (("M-[" . paredit-wrap-square)
         ("M-{" . paredit-wrap-curly)))

(use-package flycheck
  :delight
  :init
  (global-flycheck-mode))

(use-package yasnippet
  :delight
  :init
  (progn (yas-global-mode 1)))

(use-package clojure-mode
  :custom
  (clojure-toplevel-inside-comment-form t)
  (clojure-indent-style 'align-arguments)
  (clojure-align-forms-automatically t))

(use-package clojure-snippets
  :delight)

(use-package clj-refactor
  :delight
  :after clojure-mode
  :hook ((clojure-mode . clj-refactor-mode)
         (clojure-mode . yas-minor-mode))
  :custom
  (cljr-add-ns-to-blank-clj-files nil))

(use-package cljr-ivy
  :bind ("C-c r" . cljr-ivy))

(use-package cider
  :delight
  :hook (cider-mode . (lambda ()
                        (remove-hook 'completion-at-point
                                     #'cider-complete-at-point)))
  :custom
  (cider-show-error-buffer 'only-in-repl)
  (cider-auto-jump-to-error nil)
  (cider-connection-message-fn #'cider-random-tip)
  (cider-font-lock-dynamically nil)
  (cider-prompt-for-symbol nil)
  (cider-use-xref nil)
  (cider-repl-display-help-banner nil)
  (cider-print-fn 'fipp)
  (cider-result-overlay-position 'at-eol)
  (cider-overlays-use-font-lock t)
  (cider-repl-buffer-size-limit 100)
  (cider-save-file-on-load t)
  (cider-repl-pop-to-buffer-on-connect nil)
  (cider-eldoc-display-for-symbol-at-point nil))

(setq inhibit-startup-message t)
(setq visible-bell nil)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(column-number-mode)
(global-display-line-numbers-mode t)
(set-default-coding-systems 'utf-8)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(defalias 'yes-or-no-p 'y-or-n-p)
(setq-default indent-tabs-mode nil)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil
                    :font "Source Code Pro" ;; list fonts: fc-list | cut -d: -f2 | sort -u
                    :height 180
                    :weight 'normal)

(load-theme 'nord t)

(setq gc-cons-threshold (* 2 1000 1000))

;;; init.el ends here
