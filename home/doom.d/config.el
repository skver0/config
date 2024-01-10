(setq user-full-name "Sárdi Károly"
      user-mail-address "skver@tuta.io")

(setq doom-theme 'ewal-doom-one)

(require 'elcord)
(elcord-mode)

(setq doom-line-numbers-style 'normal)

(use-package! copilot
  :config (setq copilot--base-dir (getenv "EMACS_PATH_COPILOT"))
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-accept-completion-by-word)
         ("C-<tab>" . 'copilot-accept-completion-by-word)
         :map copilot-completion-map
         ("<tab>" . 'copilot-accept-completion)
         ("TAB" . 'copilot-accept-completion)))
