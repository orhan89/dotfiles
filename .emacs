(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("f366d4bc6d14dcac2963d45df51956b2409a15b770ec2f6d730e73ce0ca5c8a7" default))
 '(package-selected-packages
   '(forge org org-modern zenburn-theme notmuch yafolding weechat web-mode use-package typescript-mode twittering-mode tuareg tide terraform-doc rustic rust-playground rust-auto-use rjsx-mode request-deferred rego-mode rainbow-identifiers racer powerline pdf-tools ov org-roam nvm nov nodejs-repl nix-mode mu4e-views mu4e-overview mu4e-marker-icons mu4e-maildirs-extension mu4e-alert mix lsp-ui lsp-treemacs lsp-grammarly kubernetes-helm kubernetes kubedoc kubectx-mode k8s-mode json-mode jedi haskell-mode go-mode frame-purpose flymake-go flymake-elixir flymake-easy flycheck-yamllint flycheck-grammarly flycheck-elixir find-file-in-project emms elpy elixir-yasnippets elfeed csv-mode csv company-terraform company-quickhelp cargo async ansible anaphora alchemist a)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; global-set-key

(global-set-key (kbd "C-z") ctl-x-map)
(global-set-key (kbd "C-x C-h") help-map)
(global-set-key (kbd "C-h") 'backward-kill-word)
(global-set-key (kbd "C-t") 'previous-line)
(global-set-key (kbd "M-z") 'execute-extended-command)

;; basic functionalities

(setq-default
 column-number-mode t
 inhibit-startup-screen t
 initial-scratch-message nil
 indent-tabs-mode nil
 tab-width 2
 cursor-type 'box
)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
;; (show-paren-mode)

(display-battery-mode)
(display-time-mode)

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; package

(require 'package)

(setq package-check-signature nil)
(setq package-archives '(("melpa-stable" . "https://stable.melpa.org/packages/")
				("melpa" . "https://melpa.org/packages/")
				("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; zenburn theme

(use-package zenburn-theme
  ;; :custom-face
  ;; (default ((t (:family "Hack" :foundry "unknown" :slant normal :weight normal :height 100 :width normal))))
  :config
  (load-theme 'zenburn t))

;; ido

(use-package ido
  :config
  (setq ido-everywhere t)
  (setq ido-enable-flex-matching t)
  (setq ido-use-filename-at-point 'guess)
  (setq ido-create-new-buffer 'always)
  :init
  (ido-mode))

;; paren

(use-package paren
  :init
  (show-paren-mode))

;; org-mode

(defun log-todo-next-creation-date (&rest ignore)
  "Log NEXT creation time in the property drawer under the key 'ACTIVATED'"
  (when (and (string= (org-get-todo-state) "NEXT")
             (not (org-entry-get nil "ACTIVATED")))
    (org-entry-put nil "ACTIVATED" (format-time-string "[%Y-%m-%d]"))))

(defun gtd-save-org-buffers ()
  "Save `org-agenda-files' buffers without user confirmation.
See also `org-save-all-org-buffers'"
  (interactive)
  (message "Saving org-agenda-files buffers...")
  (save-some-buffers t (lambda () 
			 (when (member (buffer-file-name) org-agenda-files) 
			   t)))
  (message "Saving org-agenda-files buffers... done"))

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :bind (
         ("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("<s-right>" . org-shiftright)
         ("<s-left>" . org-shiftleft))
  :config (progn
            (setq org-directory "~/.org/")
            (setq org-agenda-files (list "~/.org/inbox.org" "~/.org/agenda.org" "~/.org/notes.org" "~/.org/projects.org"))
            (setq org-capture-templates
                  `(("i" "Inbox" entry  (file "inbox.org") "* TODO %?\nEntered on %U")
                    ("m" "Meeting" entry  (file+headline "agenda.org" "Future") "* %? :meeting:\n<%<%Y-%m-%d %a %H:00>>")
                    ("n" "Note" entry  (file "notes.org") "* Note (%a)\nEntered on %U\n" "\n" "%?")))
            (setq org-agenda-prefix-format
                  '((agenda . " %i %-12:c%?-12t% s")
                    (todo   . " ")
                    (tags   . " %i %-12:c")
                    (search . " %i %-12:c")))
            (setq org-refile-targets '(("~/.org/projects.org" :regexp . "\\(?:\\(?:Note\\|Habit\\|Task\\)s\\)")))
            (setq org-refile-use-outline-path 'file)
            (setq org-outline-path-complete-in-steps nil)
            (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "|" "DONE(d)")))
            (setq org-agenda-custom-commands
                  '(("g" "Get Things Done (GTD)"
                     ((agenda ""
                              ((org-agenda-skip-function
                                '(org-agenda-skip-entry-if 'deadline))
                               (org-deadline-warning-days 0)))
                      (todo "NEXT"
                            ((org-agenda-skip-function
                              '(org-agenda-skip-entry-if 'deadline))
                             (org-agenda-prefix-format "  %i %-12:c [%e] ")
                             (org-agenda-overriding-header "\nTasks\n")))
                      (agenda nil
                              ((org-agenda-entry-types '(:deadline))
                               (org-agenda-format-date "")
                               (org-deadline-warning-days 7)
                               (org-agenda-skip-function
                                '(org-agenda-skip-entry-if 'notregexp "\\* NEXT"))
                               (org-agenda-overriding-header "\nDeadlines")))
                      (todo "TODO"
                            ((org-agenda-skip-function
                              '(org-agenda-skip-entry-if 'deadline))
                             (org-agenda-prefix-format "  %?-12t% s")
                             (org-agenda-overriding-header "\nBacklog\n")))
                      (tags-todo "inbox"
                                 ((org-agenda-prefix-format "  %?-12t% s")
                                  (org-agenda-overriding-header "\nInbox\n")))
                      (tags "CLOSED>=\"<today>\""
                            ((org-agenda-overriding-header "\nCompleted today\n")))))))
            (setq org-log-done 'time)
            (setq org-agenda-hide-tags-regexp ".")
            (advice-add 'org-refile :after 'org-save-all-org-buffers)
            (add-to-list 'org-modules 'org-habit t))
  :hook ((org-capture-mode . delete-other-windows)
         (org-after-todo-state-change . log-todo-next-creation-date)))

;; (use-package forge
;;   :after magit)
