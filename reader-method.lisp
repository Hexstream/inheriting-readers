(in-package #:inheriting-readers)

(defclass inheriting-readers:reader-method (c2mop:standard-reader-method)
  ())

(defclass inheriting-readers:standard-reader-method (inheriting-readers:reader-method)
  ())

(defgeneric inheriting-readers:compute-inheriting-method-initargs-overrides (class slot-definition inheritance-scheme method &rest initargs &key &allow-other-keys)
  (:method ((class inheriting-readers:class)
            (slot-definition c2mop:direct-slot-definition)
            (inheritance-scheme inheriting-readers:standard-inheritance-scheme)
            (method inheriting-readers:reader-method) &key)
    (list :function
          (let ((slot-name (c2mop:slot-definition-name slot-definition))
                (parent-function (inheriting-readers:parent-function inheritance-scheme))
                (nil-is-valid-parent-p (inheriting-readers:nil-is-valid-parent-p inheritance-scheme)))
            (lambda (args #+ccl &optional next-methods)
              (declare (ignore next-methods))
              (let ((object #-ccl (first args) #+ccl (if (listp args) (first args) args)))
                (if (slot-boundp object slot-name)
                    ;; I wanted to call the original method-function, but this bugs out on SBCL.
                    (slot-value object slot-name)
                    (let ((parent (funcall parent-function object)))
                      (if (or parent nil-is-valid-parent-p)
                          (funcall (c2mop:method-generic-function method) parent)
                          (slot-value object slot-name))))))))))

(defmethod initialize-instance :around ((method inheriting-readers:standard-reader-method) &rest initargs &key slot-definition)
  (apply #'call-next-method method
         (nconc (apply #'inheriting-readers:compute-inheriting-method-initargs-overrides
                       (class-options:class)
                       slot-definition
                       (inheriting-readers:inheritance-scheme slot-definition)
                       method
                       initargs)
                initargs)))
