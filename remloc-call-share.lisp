(in-package :remloc-call)

(defparameter *reg-call* (make-hash-table :test 'equal))

(define-condition function-not-registered (error)
  ())

