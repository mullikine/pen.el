;; gy -E "openai api engines.generate -h | pavs"

(defvar pen.el-map (make-sparse-keymap)
  "Keymap for `pen.el'.")
;; (makunbound 'pen.el)
(defvar-local pen.el nil)

(define-minor-mode pen.el
  "Mode for working with language models in your  buffers."
  :global t
  :init-value t
  :lighter " pen"
  :keymap pen.el-map)

;; (define-globalized-mode global-pen.el pen.el pen.el)

;; TODO Make a shell script for querying the OpenAI API
;; $SCRIPTS/openai-curl

;; TODO pen-generate
;; This function streams text onto the end of the currently selected region accordig to the current prompt settings


;; (defun pen-generate ()
;;   "This function streams text onto the end of the currently selected region accordig to the current prompt settings"
;;   (interactive)
;;   (if (region-active-p)
;;       (let ((r (selected)))
;;         ;; Send request and replace the text
;;         )))


;; (define-key pen.el-map (kbd "<up>") 'pen-generate)
;; (define-key pen.el-map (kbd "<down>") (lm (tsk "C-n")))
;; (define-key pen.el-map (kbd "<right>") (lm (tsk "M-3")))

(pen.el 1)

;; TODO Create a transient mode for quickly setting prompt settings

;; (define-transient-command prompt-engineer-configure ()
;;   "Transient for configuring the current openai prompt fuction."
;;   :man-page "docker-image-pull"
;;   ["Arguments"
;;    ("-a" "All" "-a")]
;;   [:description docker-utils-generic-actions-heading
;;    ("F" "Pull selection" docker-utils-generic-action)
;;    ("T" "Pull specific tag (sps)" my-docker-pull-specific-tag)
;;    ("N" "Pull a new image" dockerage-pull-one)])

;; This key will be set upon setting pen-openai-key-location
(defcustom pen-openai-key ""
  "OpenAI API key"
  :type 'string
  :group 'prompt-engineer
  :initialize #'custom-initialize-default)

;; This location will be set upon setting pen-openai-key
(defcustom pen-openai-key-location ""
  "OpenAI API key"
  :type 'string
  :group 'prompt-engineer
  :initialize #'custom-initialize-default)

(defcustom pen-prompt-directory ""
  "Directory where .prompt files are located"
  :type 'string
  :group 'prompt-engineer
  :initialize #'custom-initialize-default)

(defvar-local pen-engine nil)

(defvar-local pen-frequency-penalty nil
  "If your completion is filled with lots of\nrepetition you can increase this setting\nto prevent that from happening.\n\nHow much to penalize new tokens based on\ntheir existing frequency in the text so\nfar.\n\nDecreases the model's likelihood to repeat\nthe same line verbatim (the same text).\n\nThe likelihood of the same/similar lines\nbeing repeated in a completion.\n\nSet it high to avoid repetition.\n\nHowever, it could make sense to lower this\nvalue if writing lyrics for a song's\nchorus.")

(defvar-local pen-presence-penalty nil)

(defvar-local pen-best-of nil)

(defvar-local pen-stop-sequences nil)

(defvar-local pen-inject-start-text nil)

(defvar-local pen-inject-restart-text nil)

(defvar-local pen-show-probabilities nil)

(setq pen-prompt-directory "/home/shane/source/git/semiosis/prompts/prompts")

;; + States
;;   - Off
;;   - Most likely
;;   - Least likely
;;   - Full spectrum

(defun load-prompts ()

  )

(provide 'pen.el)


;; (defun pen-tweet-sentiment-classifier (input)
;;   (interactive (list (my/selected-text)))
;;   (let* ((prompt-fp (umn "$MYGIT/mullikine/pen.el/prompts/tweet-sentiment-classifier.prompt"))
;;          (output (if input (sor (chomp (sn (concat "openai-complete " (q prompt-fp) " " (q input))))))))
;;     (if output
;;         (if (interactive-p)
;;             (message output)
;;           output))))

;; (defun pen-summarise-for-second-grader (input)
;;   (interactive (list (my/selected-text)))
;;   (let* ((prompt-fp (umn "$MYGIT/mullikine/pen.el/prompts/summarize-for-2nd-grader.prompt")))
;;     (region-pipe (concat "openai-complete " (q prompt-fp) " " (q input) " | chomp"))))

;; (defun pen-obfuscate-language (input)
;;   (interactive (list (my/selected-text)))
;;   (let* ((prompt-fp (umn "$MYGIT/mullikine/pen.el/prompts/obfuscate-language.prompt")))
;;     (region-pipe (concat "openai-complete " (q prompt-fp) " " (q input) " | chomp"))))

;; (defun pen-make-analogy (former latter)
;;   (interactive (list (read-string-hist "analogy participant: ")
;;                      (read-string-hist "analogy participant: ")))
;;   (let* ((prompt-fp (umn "$MYGIT/mullikine/pen.el/prompts/analogy.prompt")))
;;     (etv (sn (concat "openai-complete " (q prompt-fp) " " (q former) " "
;;                      (q latter) " | chomp")))))


(never
 (defset my-prompt-test (yamlmod-read-file (car (glob "$MYGIT/mullikine/pen.el/prompts/*"))))
 (ht-get my-prompt-test "title")
 (cl-loop for v in (vector2list (ht-get my-prompt-test "vars")) collect `(read-string-hist ,(concat v ": ")))
 (mapcar 'slugify (ht-get my-prompt-test "vars"))

 (describe-hash 'my-prompt-test))

(defun pen-interactively-generate-prompt ()
  "A wizard for quickly building a prompt"
  ;; $MYGIT/mullikine/pen.el/prompts/obfuscate-language.prompt
  (interactive)
  (let* ((meta (read-string "Meta description (The human asks the AI to etc.)\":")))))

(defalias 'cll 'cl-loop)


(defvar pen-prompt-functions nil)


(defun pen-generate-prompt-functions ()
  "Generate prompt functions for the files in the prompts directory
Function names are prefixed with pen-pf- for easy searching"
  (interactive)
  (let ((paths
         (-non-nil (mapcar 'sor (glob (concat pen-prompt-directory "/*.prompt"))))))
    (cl-loop for path in paths do
             ;; results in a hash table
             (let* ((yaml (yamlmod-read-file path))
                    (title (ht-get yaml "title"))
                    (title-slug (slugify title))
                    (doc (ht-get yaml "doc"))
                    (vars (vector2list (ht-get yaml "vars")))
                    (examples (vector2list (ht-get yaml "examples")))
                    (var-slugs (mapcar 'slugify vars))
                    (var-syms (mapcar 'str2sym var-slugs))
                    (func-name (concat "pen-pf-" title-slug))
                    (iargs (let ((iteration 0))
                             (cl-loop for v in vars
                                      collect
                                      (let ((example (nth iteration examples)))
                                        (if (equal 0 iteration)
                                            ;; The first argument may be captured through selection
                                            `(if (selectionp)
                                                 (my/selected-text)
                                               (if (> (length (str2lines ,example)) 1)
                                                   (tvipe ;; ,(concat v ": ")
                                                    ,example)
                                                 (read-string-hist ,(concat v ": ") ,example)))
                                          `(read-string-hist ,(concat v ": ") ,example)))
                                      do
                                      (progn
                                        (setq iteration (+ 1 iteration))
                                        (message (str iteration)))))))
               ;; var names will have to be slugged, too
               (add-to-list 'pen-prompt-functions
                            (eval
                             `(defun ,(str2sym func-name) ,var-syms
                                ,(sor doc title)
                                (interactive ,(cons 'list iargs))
                                (let ((result
                                       (chomp (sn ,(flatten-once
                                                    (list
                                                     (list 'concat "openai-complete " (q path))
                                                     (flatten-once (cl-loop for vs in var-slugs collect
                                                                            (list " "
                                                                                  (list 'q (str2sym vs)))))))))))
                                  (if (interactive-p)
                                      (if (or (>= (prefix-numeric-value current-prefix-arg) 4)
                                              (not (selectedp)))
                                          (etv result)
                                        (replace-region result))
                                    result)))))
               (message (concat "pen-mode: Loaded prompt function " func-name))))))
(pen-generate-prompt-functions)


(define-derived-mode prompt-description-mode yaml-mode "Prompt"
  "Prompt description mode")


;; (define-key global-map (kbd "H-TAB") nil)
(define-key global-map (kbd "H-TAB g") 'pen-generate-prompt-functions)



(defun pen-filter-with-prompt-function ()
  (interactive)
  (let ((f (fz pen-prompt-functions)))
    (if f
        (filter-selected-region-through-function (str2sym f)))))
(define-key global-map (kbd "H-TAB s") 'pen-filter-with-prompt-function)

(defun pen-run-prompt-function ()
  (interactive)
  (let ((f (fz pen-prompt-functions)))
    (if f
        (call-interactively (str2sym f)))))
(defalias 'camille-complete 'pen-run-prompt-function)
(define-key global-map (kbd "H-TAB r") 'pen-run-prompt-function)

;; Camille-complete (because I press SPC to replace
(define-key selected-keymap (kbd "SPC") 'pen-run-prompt-function)
(define-key selected-keymap (kbd "M-SPC") 'pen-run-prompt-function)

;; TODO Make a function for permuting the tuples of monotonically increasing length all starting with the first element

;; TODO Generate a list of completion symbols
;; This should be a permutation of n-nmax tokens of a single response from openai
;; TODO In future, suggest alternative completions from openai
(defun company-pen-filetype--candidates (prefix)
  (let* ((preceding-text (str (buffer-substring (point) (max 1 (- (point) 1000)))))
         (response (pen-pf-generic-file-type-completion (detect-language) preceding-text))
         ;; Take only the first line for starters
         (line (car (str2lines response)))
         (res
          (if (>= (prefix-numeric-value current-prefix-arg) 8)
              (list response)
            ;; Just generate a few
            ;; (pen-pf-generic-file-type-completion (detect-language) preceding-text)
            ;; (pen-pf-generic-file-type-completion (detect-language) preceding-text))
            (str2lines (snc "monotonically-increasing-tuple-permutations.py" line)))))
    ;; Generate a list
    ;; (setq res '("testing" "testing123"))
    (mapcar (lambda (s) (concat (company-pen-filetype--prefix) s))
            res)))

(defun company-pen--grab-symbol ()
  (buffer-substring (point) (save-excursion (skip-syntax-backward "w_.")
                                            (point))))

(defun company-pen-filetype--prefix ()
  "Grab prefix at point."
  (or (company-pen--grab-symbol)
      'stop))

(defun company-pen-filetype (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-pen-filetype))
    (prefix (company-pen-filetype--prefix))
    (candidates (company-pen-filetype--candidates arg))
    ;; TODO doc-buffer may contain info on the completion in the future
    ;; (doc-buffer (company-pen-filetype--doc-buffer arg))
    ;; TODO annotation may contain the probability in the future
    ;; (annotation (company-pen-filetype--annotation arg))
    ))

(require 'company)
(defun my-completion-at-point ()
  (interactive)
  (if (>= (prefix-numeric-value current-prefix-arg) 4)
      (call-interactively 'company-pen-filetype)
    (call-interactively 'completion-at-point)))

(define-key global-map (kbd "M-~") #'my-completion-at-point)

(provide 'my-openai)
(provide 'pen)