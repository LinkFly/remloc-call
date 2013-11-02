(in-package :remloc-call)

(defparameter *local-call* nil)
;(defparameter *local-call* t)
(defparameter *check-registered* t)
;(defparameter *check-registered* nil)

(defparameter *remote-call-stream* nil)

(define-condition local-function-not-registered (function-not-registered)
  ())

(defun check-registered (package-function)
  (unless (gethash package-function *reg-call*)
    (error (make-condition 'local-function-not-registered))))

(defun get-remote-call-stream (host port)
  (socket-connect host port))

(defun connect-to-remote-call-server (host port &optional (remote-call-stream-sym '*remote-call-stream*))
 (set remote-call-stream-sym (get-remote-call-stream host port)))

(defun remote-call (remote-call-stream-sym package function args &aux socket-stream)  
  (if *local-call*
      (progn (when *check-registered*
               (check-registered (list package function)))
        (apply (find-symbol function package) args))
    (progn
      (setf socket-stream (symbol-value remote-call-stream-sym))
      (destructuring-bind (result call-status)
          (let ((stream (socket-stream socket-stream)))
            (store `((,package ,function) ,args) stream)
            (force-output stream)
            (restore stream))
        (when call-status
          (typecase call-status
            (function-not-registered (error call-status))
            (error "Remote local call: Unknown error")))
        result))))

(defmacro def-call (name (package function) &key (remote-call-stream-sym '*remote-call-stream*))
  `(defun ,name (&rest args)
     (remote-call ',remote-call-stream-sym ,package ,function args)))

;(remloc-call::connect-to-remote-call-server "127.0.0.1" 2000)
;(defun fun2 (&args) "Hello world!!!")
;(reg-call 'fun2)
;(def-call fn1 ("REMLOC-CALL" "FUN1"))
;(def-call fn2 ("REMLOC-CALL" "FUN2"))
;(def-call fn3 "FUN3")
;(def-call fn4 "FUN4")
;(fn1 2)
;(fn2 2)
;(fn3 2)
;(fn4 2)
