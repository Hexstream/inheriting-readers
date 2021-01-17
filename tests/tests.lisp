(cl:defpackage #:inheriting-readers_tests
  (:use #:cl #:parachute))

(cl:in-package #:inheriting-readers_tests)

(defmacro are (comp expected form &optional description &rest format-args)
  `(is ,comp ,expected (multiple-value-list ,form) ,description ,@format-args))

(defvar *dynamic-parent* nil)

(defun dynamic-parent (&optional object)
  (declare (ignore object))
  *dynamic-parent*)

(defclass alt-parent-mixin ()
  ((%alt-parent :initarg :alt-parent
                :reader alt-parent
                :initform nil)))

(defclass my-class (inheriting-readers:parent-mixin alt-parent-mixin)
  ((%name :initarg :name
          :reader name
          :initform nil)
   (%normal-slot :initarg :normal-slot
                 :reader normal-slot)
   (%inherited-slot :inherit t
                    :initarg :inherited-slot
                    :reader inherited-slot)
   (%alt-inherited-slot :inherit alt
                        :initarg :alt-inherited-slot
                        :reader alt-inherited-slot)
   (%ad-hoc-inherited-slot :inherit (:parent-function #'dynamic-parent :nil-is-valid-parent-p t)
                           :initarg :ad-hoc-inherited-slot
                           :reader ad-hoc-inherited-slot))
  (:metaclass inheriting-readers:standard-class)
  (:inheritance-schemes alt (:parent-function #'alt-parent)))

(defmethod ad-hoc-inherited-slot ((default null))
  'default)

(defmethod print-object ((object my-class) stream)
  (print-unreadable-object (object stream :type t)
    (princ (name object) stream)))

(define-test "main"
  (let ((object (make-instance 'my-class :name :unbound-slots)))
    (fail (normal-slot object) 'unbound-slot)
    (fail (inherited-slot object) 'unbound-slot))
  (let ((object (make-instance 'my-class :name :bound-slots
                                         :normal-slot 1 :inherited-slot 2 :alt-inherited-slot 3 :ad-hoc-inherited-slot 4)))
    (is eql 1 (normal-slot object))
    (is eql 2 (inherited-slot object))
    (is eql 3 (alt-inherited-slot object))
    (is eql 4 (ad-hoc-inherited-slot object))
    (let ((future-dynamic-parent object)
          (object (make-instance 'my-class :name :child :parent object)))
      (fail (normal-slot object) 'unbound-slot)
      (is eql 2 (inherited-slot object))
      (fail (alt-inherited-slot object) 'unbound-slot)
      (is eq 'default (ad-hoc-inherited-slot object))
      (let ((*dynamic-parent* future-dynamic-parent))
        (is eql 4 (ad-hoc-inherited-slot object))))
    (let ((object (make-instance 'my-class :alt-parent object)))
      (is eql 3 (alt-inherited-slot object)))))
