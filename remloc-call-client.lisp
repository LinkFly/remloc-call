(in-package :remloc-call)

(defparameter *remote-call-stream* nil)

(defun get-remote-call-stream (host port)
  (socket-connect host port))

(defun connect-to-remote-call-server (host port &optional (remote-call-stream-sym '*remote-call-stream*))
 (set remote-call-stream-sym (get-remote-call-stream host port)))

(defun remote-local-call (socket-stream remote-function args)
  (destructuring-bind (result call-status)
      (let ((stream (socket-stream socket-stream)))
        (store (list remote-function args) stream)
        (force-output stream)
        (restore stream))
    (when call-status
      (typecase call-status
        (function-not-registered (error call-status)
        (error "Remote local call: Unknown error"))))
    result))

(defmacro def-call (name remote-function &key (remote-call-stream-sym '*remote-call-stream*)  &aux name-str)
  `(defun ,name (&rest args)
     (remote-local-call (symbol-value ',remote-call-stream-sym) ,remote-function args)))

;(remloc-call::connect-to-remote-call-server "127.0.0.1" 2000)

;(def-call fn1 "FUN1")
;(def-call fn2 "FUN2")
;(def-call fn3 "FUN3")
;(def-call fn4 "FUN4")
;(fn1 2)
;(fn2 2)
;(fn3 2)
;(fn4 2)
