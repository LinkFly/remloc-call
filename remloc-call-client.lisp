(in-package :remloc-call)

(defparameter *local-call* nil)
(defparameter *check-registered* t)

;;;;;;;;;
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
