(in-package #:inheriting-readers)

(defclass inheriting-readers:inheritance-schemes-mixin ()
  ((%inheritance-schemes :reader inheriting-readers:inheritance-schemes
                         :initform nil)))

(defmethod inheriting-readers:resolve-inheritance-scheme ((mixin inheriting-readers:inheritance-schemes-mixin) (name symbol) &key)
  (let ((found (assoc name (inheriting-readers:inheritance-schemes mixin) :test #'eq)))
    (if found
        (cdr found)
        (call-next-method))))

(defun %mapplist (function plist)
  (mapcon (let ((processp t))
            (lambda (tail)
              (prog1 (when processp
                       (list (funcall function (first tail) (second tail))))
                (setf processp (not processp)))))
          plist))

(defgeneric inheriting-readers:canonicalize-inheritance-schemes (class inheritance-scheme-specifications)
  (:method ((mixin inheriting-readers:inheritance-schemes-mixin) (inheritance-scheme-specifications list))
    (%mapplist (lambda (name inheritance-scheme-specification)
                 (cons name (inheriting-readers:resolve-inheritance-scheme
                             mixin inheritance-scheme-specification)))
               inheritance-scheme-specifications)))

(defun %init-inheritance-schemes (mixin inheritance-schemes)
  (setf (slot-value mixin '%inheritance-schemes)
        (inheriting-readers:canonicalize-inheritance-schemes mixin inheritance-schemes)))

(defmethod initialize-instance :before ((mixin inheriting-readers:inheritance-schemes-mixin)
                                        &key inheritance-schemes)
  (%init-inheritance-schemes mixin inheritance-schemes))

(defmethod reinitialize-instance :before ((mixin inheriting-readers:inheritance-schemes-mixin)
                                          &key (inheritance-schemes nil inheritance-schemes-p))
  (when inheritance-schemes-p
    (setf (slot-value mixin '%inheritance-schemes) nil)
    (%init-inheritance-schemes mixin inheritance-schemes)))
