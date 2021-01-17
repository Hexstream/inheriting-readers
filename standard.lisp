(in-package #:inheriting-readers)

(defclass inheriting-readers:standard-metaclass (inheriting-readers:inheritance-schemes-mixin
                                                 compatible-metaclasses:standard-class
                                                 compatible-metaclasses:standard-metaclass)
  ()
  (:metaclass compatible-metaclasses:standard-metaclass))

(defmethod inheriting-readers:resolve-inheritance-scheme ((class inheriting-readers:standard-metaclass) (name symbol) &rest rest)
  (or (call-next-method)
      (let ((class (find-class name nil)))
        (when class
          (apply #'inheriting-readers:resolve-inheritance-scheme class t :errorp nil rest)))))


(defclass inheriting-readers:class (cl:standard-class) ())

(defmethod inheriting-readers:resolve-inheritance-scheme ((class inheriting-readers:class) inheritance-scheme-specification &rest rest)
  (apply #'inheriting-readers:resolve-inheritance-scheme
         (class-of class) inheritance-scheme-specification :errorp nil rest))


(defclass inheriting-readers:standard-class (inheriting-readers:inheritance-schemes-mixin
                                             inheriting-readers:inherit-class-option-mixin
                                             class-options:class-mixin
                                             compatible-metaclasses:standard-class)
  ()
  (:metaclass inheriting-readers:standard-metaclass)
  (:inheritance-schemes t (:parent-function #'inheriting-readers:parent)))


(defclass inheriting-readers:direct-slot (c2mop:standard-direct-slot-definition)
  ())

(defclass inheriting-readers:standard-direct-slot (inheriting-readers:inherit-mixin
                                                   inheriting-readers:inheritance-scheme-mixin
                                                   inheriting-readers:direct-slot)
  ())

(defgeneric inheriting-readers:expand-inherit-slot-option (direct-slot &rest initargs &key &allow-other-keys)
  (:method ((slot inheriting-readers:standard-direct-slot)
            &key inherit (inheritance-scheme nil inheritance-scheme-p))
    (declare (ignore inheritance-scheme))
    (if inheritance-scheme-p
        (error "~S must not be supplied directly." :inheritance-scheme)
        (list :inheritance-scheme (inheriting-readers:resolve-inheritance-scheme (class-options:class) inherit)))))

(defmethod initialize-instance :around ((slot inheriting-readers:standard-direct-slot) &rest initargs)
  (apply #'call-next-method slot (nconc (apply #'inheriting-readers:expand-inherit-slot-option slot initargs)
                                        initargs)))

(defmethod c2mop:direct-slot-definition-class ((class inheriting-readers:standard-class) &key inherit)
  (if inherit
      (find-class 'inheriting-readers:standard-direct-slot)
      (call-next-method)))

(defmethod c2mop:reader-method-class ((class inheriting-readers:standard-class) (direct-slot inheriting-readers:direct-slot) &key &allow-other-keys)
  (find-class 'inheriting-readers:standard-reader-method))
