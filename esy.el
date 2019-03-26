(setq env-json-str (shell-command-to-string "esy command-env --json"))
(setq json-key-type 'string)
(setq env-pairs (json-read-from-string env-json-str))

(dolist (e env-pairs)
  (let (
        (var (car e))
        )
    (setenv var (cdr e))
    (message "%s was updated" var)
    (if (equal var "PATH") (setq exec-path (split-string (cdr e) ":"))) nil)
    
  )


(setq merlin-command (executable-find "ocamlmerlin"))
(setq refmt-command (executable-find "refmt"))
