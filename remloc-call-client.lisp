(in-package :remote-call)

(defparameter *remote-call-stream* nil)

(defun get-remote-call-stream (host port)
  (socket-connect host port))

(defun connect-to-remote-call-server (host port &optional (remote-call-stream-sym '*remote-call-stream*))
 (set remote-call-stream-sym (get-remote-call-stream host port)))

;(connect-to-remote-call-server "127.0.0.1" 2002)

(defmacro def-call (name remote-function &key (remote-call-stream-sym '*remote-call-stream*)  &aux name-str)
  ;(setf name "FUN1")
  `(defun ,name (&rest args)
     (let ((stream (socket-stream (symbol-value ',remote-call-stream-sym))))
       (store (list ,remote-function args) stream)
       (force-output stream)
       (restore stream))))

(def-call fn1 "FUN1")
(def-call fn2 "FUN2")
(def-call fn3 "FUN3")
(def-call fn4 "FUN4")
(fn1 2)
(fn2 2)
(fn3 2)
(fn4 2)
