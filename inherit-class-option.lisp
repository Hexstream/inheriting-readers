(in-package #:inheriting-readers)

(defclass inheriting-readers:inherit-mixin ()
  ((%inherit :initarg :inherit
             :reader inheriting-readers:inherit
             :initform nil)))

(defclass inheriting-readers:inherit-class-option-mixin (inheriting-readers:inherit-mixin
                                                         class-options:options-mixin
                                                         inheriting-readers:class)
  ())

(defmethod class-options:canonicalize-options ((class inheriting-readers:inherit-class-option-mixin)
                                               &key (inherit nil inheritp) (direct-slots nil direct-slots-p))
  (let ((inherit (ecase (class-options:operation)
                   (initialize-instance
                    inherit)
                   (reinitialize-instance
                    (if inheritp
                        (unless direct-slots-p
                          (error "Must not supply ~S without ~S during reinitialization."
                                 :inherit :direct-slots))
                        (inheriting-readers:inherit class)))))
        (rest (call-next-method)))
    (if (and inherit direct-slots)
        (list* :direct-slots (mapcar (lambda (slot)
                                       (if (get-properties '(:inherit) slot)
                                           slot
                                           (list* :inherit inherit slot)))
                                     direct-slots)
               rest)
        rest)))
