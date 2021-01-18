(asdf:defsystem #:inheriting-readers

  :author "Jean-Philippe Paradis <hexstream@hexstreamsoft.com>"

  :license "Unlicense"

  :description "Provides a simple yet powerful value inheritance scheme."

  :depends-on ("closer-mop"
               "class-options"
               "compatible-metaclasses")

  :version "1.0.1"
  :serial cl:t
  :components ((:file "package")
               (:file "inheritance-scheme")
               (:file "inheritance-schemes-mixin")
               (:file "inherit-class-option")
               (:file "standard")
               (:file "reader-method"))

  :in-order-to ((asdf:test-op (asdf:test-op #:inheriting-readers_tests))))
