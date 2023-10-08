;;; terraform-cli.el --- Emacs interface to Terraform CLI -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Alfonso Montero López

;; Author: Alfonso Montero López <amontero@tinet.org>
;; Version: 0.1.0
;; Package-Requires: (transient (emacs "24.4"))
;; Keywords: external, processes, tools, terraform
;; URL: https://github.com/pataquets/terraform-cli.el

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Provides an Emacs interface to Terraform CLI. This package is heavily inspired
;; on the awesome Magit package and uses Transient for its UI.

;;; Code:

(require 'transient)
;; Use 'transient-showcase' functionality for development, if present.
(when (package-installed-p 'transient-showcase)
  (require 'transient-showcase))

(defgroup terraform-cli nil
  "Emacs interface to Terraform CLI."
  :group 'processes)

(defcustom terraform-cli-binary-name "terraform"
  "Terraform binary name."
  :type 'string
  :group 'terraform-cli)

(defcustom terraform-cli-run-debug t
  "Output terraform command invocations to messages buffer."
  :type 'boolean
  :group 'terraform-cli)

(defun terraform-cli-run (command switches)
  "Execute 'terraform COMMAND SWITCHES' on a compilation buffer."
  (let ((cmd (format "%s %s %s" terraform-cli-binary-name
                     command (string-join switches " "))))
    (when terraform-cli-run-debug
      (message (format "terraform-cli-run cmd: %s" cmd)))
    (compile cmd)))

(defun terraform-cli-todo ()
  "Placeholder function for not implemented functionality."
  (interactive)
  (message "terraform-cli: Not implemented yet."))

;;;###autoload
(transient-define-prefix terraform-cli-dispatch ()
  "Main terraform CLI entrypoint. Equivalent to root 'terraform' command."
  ["Terraform CLI"
   ("i" "Init" terraform-cli-init)
   ("v" "Validate" terraform-cli-todo)
   ("p" "Plan" terraform-cli-plan)
   ("a" "Apply" terraform-cli-todo)
   ("D" "Destroy" terraform-cli-todo)
   ""
   ("w" "Workspace" terraform-cli-todo)])

(transient-define-argument terraform-cli-plan:-refresh ()
  :description  "Refresh state"
  :class 'transient-switches
  :key "r"
  :allow-empty nil
  :always-read t
  :argument-format "-refresh=%s"
  :argument-regexp "-refresh=\\(true\\|false\\)"
  :init-value (lambda (obj) (oset obj value "-refresh=true"))
  :choices '("true" "false"))

;;;###autoload
(transient-define-prefix terraform-cli-plan ()
  "Command: 'terraform plan'."
  :value '("-input=false"
           "-refresh=false"
           "-lock=true")
  ["Options" ;; :class 'transient-switches
   ("i" nil "-input=false"      :description "Do NOT ask for input"
    :always-read t :allow-empty nil) ;; Use 'comint' mode for interactiveness
   ("l" nil "-lock="            :description "Hold state lock (DANGEROUS)"
    :always-read t :allow-empty nil :choices ("true" "false"))
   (terraform-cli-plan:-refresh)
   ("c" nil "-compact-warnings" :description "Compact warnings")
   ("d" nil "-destroy"          :description "Select 'destroy' planning mode")
   ("e" nil "-refresh-only"     :description "Refresh only")
   ("C" nil "-no-color"         :description "No color on output")]
  ["Actions"
   ("SPC" "Transient print args" tsc-suffix-print-args
    :if (lambda() (featurep 'transient-showcase)))
   ("RET" "Run plan" terraform-cli-plan-run)])

(defun terraform-cli-plan-arguments ()
  (transient-args 'terraform-cli-plan))

(defun terraform-cli-plan-run (args)
  (interactive (list (terraform-cli-plan-arguments)))
  (terraform-cli-run "plan" args))

;;;###autoload
(transient-define-prefix terraform-cli-init ()
  "Command: 'terraform init'."
  :value '("-input=false"
           "-lock=true")
  ["Options"
   ("i" nil "-input=false" :description "Do NOT ask for input"
    :always-read t :allow-empty nil) ;; Use 'comint' mode for interactiveness
   ("l" nil "-lock="       :description "Hold state lock (DANGEROUS)"
    :always-read t :allow-empty nil :choices ("true" "false"))
   ("u" nil "-upgrade"     :description "Upgrade providers and modules")
   ("C" nil "-no-color"    :description "No color on output")]
  ["Actions"
   ("SPC" "Transient print args" tsc-suffix-print-args
    :if (lambda() (featurep 'transient-showcase)))
   ("RET" "Run init" terraform-cli-init-run)])

(defun terraform-cli-init-arguments ()
  (transient-args 'terraform-cli-init))

(defun terraform-cli-init-run (args)
  (interactive (list (terraform-cli-init-arguments)))
  (terraform-cli-run "init" args))

(provide 'terraform-cli)
;;; terraform-cli.el ends here
