(asdf:defsystem #:inheriting-readers_tests

  :author "Jean-Philippe Paradis <hexstream@hexstreamsoft.com>"

  :license "Unlicense"

  :description "inheriting-readers unit tests."

  :depends-on ("inheriting-readers"
               "compatible-metaclasses"
               "parachute")

  :serial cl:t
  :components ((:file "tests"))

  :perform (asdf:test-op (op c) (uiop:symbol-call '#:parachute '#:test '#:inheriting-readers_tests)))
