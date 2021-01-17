(in-package #:inheriting-readers)

(defclass inheriting-readers:inheritance-scheme () ())


(defclass inheriting-readers:parent-mixin ()
  ((%parent :initarg :parent
            :reader inheriting-readers:parent
            :initform nil)))


(defclass inheriting-readers:parent-function-mixin ()
  ((%parent-function :initarg :parent-function
                     :reader inheriting-readers:parent-function
                     :type (or function symbol)
                     :initform #'inheriting-readers:parent)))

(defmethod shared-initialize :around ((mixin inheriting-readers:parent-function-mixin) slot-names
                                      &rest initargs &key parent-function)
  (if (typep parent-function '(cons (eql function) (cons symbol null)))
      (apply #'call-next-method mixin slot-names
             :parent-function (symbol-function (second parent-function))
             initargs)
      (call-next-method)))

(defclass inheriting-readers:nil-is-valid-parent-p-mixin ()
  ((%nil-is-valid-parent-p :initarg :nil-is-valid-parent-p
                           :reader inheriting-readers:nil-is-valid-parent-p
                           :type boolean
                           :initform nil)))

(defclass inheriting-readers:standard-inheritance-scheme (inheriting-readers:parent-function-mixin
                                                          inheriting-readers:nil-is-valid-parent-p-mixin
                                                          inheriting-readers:inheritance-scheme)
  ())

(defmethod print-object ((inheritance-scheme inheriting-readers:standard-inheritance-scheme) stream)
  (print-unreadable-object (inheritance-scheme stream :type t)
    (prin1 (nconc (let ((parent-function (inheriting-readers:parent-function inheritance-scheme)))
                    (unless (eq parent-function #'inheriting-readers:parent)
                      (list :parent-function parent-function)))
                  (let ((nil-is-valid-parent-p (inheriting-readers:nil-is-valid-parent-p inheritance-scheme)))
                    (when nil-is-valid-parent-p
                      (list :nil-is-valid-parent-p nil-is-valid-parent-p))))
           stream)))


(defclass inheriting-readers:inheritance-scheme-mixin ()
  ((%inheritance-scheme :initarg :inheritance-scheme
                        :reader inheriting-readers:inheritance-scheme
                        :type inheriting-readers:inheritance-scheme)))



(defgeneric inheriting-readers:inheritance-scheme-class (class &rest initargs &key &allow-other-keys)
  (:method ((class cl:class) &key)
    (find-class 'inheriting-readers:standard-inheritance-scheme)))

(defgeneric inheriting-readers:resolve-inheritance-scheme (class inheritance-scheme-specification &key)
  (:method :around (class inheritance-scheme-specification &key (errorp t))
    (or (call-next-method)
        (when errorp
          (error "~S does not name an inheritance scheme in class ~S." inheritance-scheme-specification class))))
  (:method ((class cl:class) (initargs cons) &key)
    (apply #'make-instance (inheriting-readers:inheritance-scheme-class class) initargs))
  (:method (object (inheritance-scheme inheriting-readers:inheritance-scheme) &key)
    (declare (ignore object))
    inheritance-scheme))
