(in-package :remote-call)

(defparameter *reg-call* (make-hash-table :test 'equal))

(defun as-string (obj)
  (typecase obj
    (symbol (symbol-name obj))
    (string obj)))

(defun reg-call (name)
  (setf (gethash (as-string name) *reg-call*) name))

(defun fun1 (&args) "Hi!!!")
(defun fun2 (&args) "Hello world!!!")
(defun fun3 (&args) "fun3!!!")
(defun fun4 (&args) "fun444!!!")
;(reg-call 'fun1)
;(reg-call 'fun2)
;(reg-call 'fun3)
;(reg-call 'fun4)

(defun handler (fn-name args &aux fn-sym)
  (setf fn-sym (gethash fn-name *reg-call*))
  (when fn-sym
    (funcall fn-sym args)))

(defun start-remote-call-server (host port &aux (seq (make-array 5 :element-type '(unsigned-byte 8))))
  (make-thread 
   (lambda ()
     (loop :with socket = (usocket:socket-listen host port)
           :with stream = (socket-stream (socket-accept socket))
           :while t
           :do (destructuring-bind (remote-function args)
                   (restore stream)
                 (store (handler remote-function args) stream)
                 (force-output stream))))
   :name (format nil "Remote call server (~A ~A)" host port)))

 


  


             