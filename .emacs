(custom-set-faces
 '(default ((t (:family "DejaVu Sans Mono" :foundry "unknown" :slant normal :weight normal :height 83 :width normal)))))

(custom-set-variables
 '(ansi-color-names-vector ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(column-number-mode t)
 '(custom-enabled-themes (quote (deeper-blue)))
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(show-paren-mode t)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify)))

(semantic-mode 1)

(require 'package)
(dolist (source '(("melpa" . "http://melpa.milkbox.net/packages/")
                  ("marmalade" . "http://marmalade-repo.org/packages/")
		  ("elpa" . "http://tromey.com/elpa/")))
  (add-to-list 'package-archives source t))

;; (add-to-list 'load-path "/home/ricky/.emacs.d/plugins/yasnippet")
;; (require 'yasnippet)
(yas/global-mode 1)
(yas/load-directory "/home/ricky/.emacs.d/elpa/yasnippet-0.9.1/snippets")
 
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(require 'auto-complete)
(global-auto-complete-mode t)

(require 'flycheck-pyflakes)
;; (add-hook 'python-mode-hook 'flycheck-mode)
(require 'flymake-python-pyflakes)
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)

(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'python-mode-hook 'jedi:ac-setup)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
(setq jedi:complete-on-dot t)

(require 'nose)

(require 'linum)
(require 'pycoverage)

(defun my-coverage ()
  (interactive)
  (when (derived-mode-p 'python-mode)
    (progn
      (linum-mode)
      (pycoverage-mode))))
