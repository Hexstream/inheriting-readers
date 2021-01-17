(cl:defpackage #:inheriting-readers
  (:use #:cl)
  (:shadow #:class
           #:standard-class)
  (:export #:inheritance-scheme
           #:parent-mixin
           #:parent
           #:parent-function-mixin
           #:parent-function
           #:nil-is-valid-parent-p-mixin
           #:nil-is-valid-parent-p
           #:standard-inheritance-scheme
           #:inheritance-scheme-mixin
           #:inheritance-scheme-class
           #:resolve-inheritance-scheme

           #:inheritance-schemes-mixin
           #:inheritance-schemes
           #:canonicalize-inheritance-schemes

           #:inherit-mixin
           #:inherit
           #:inherit-class-option-mixin

           #:reader-method
           #:standard-reader-method
           #:compute-inheriting-method-initargs-overrides

           #:standard-metaclass
           #:class
           #:standard-class
           #:direct-slot
           #:standard-direct-slot
           #:expand-inherit-slot-option))
