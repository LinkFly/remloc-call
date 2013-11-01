(in-package :remloc-call)

(defparameter *reg-call* (make-hash-table :test 'equal))

(defun as-string (obj)
  (typecase obj
    (symbol (symbol-name obj))
    (string obj)))

(defun reg-call (name)
  (setf (gethash (as-string name) *reg-call*) name))

;(defun fun1 (&args) "Hi!!!")
;(defun fun2 (&args) "Hello world!!!")
;(defun fun3 (&args) "fun3!!!")
;(defun fun4 (&args) "fun444!!!")
;(reg-call 'fun1)
;(reg-call 'fun2)
;(reg-call 'fun3)
;(reg-call 'fun4)

(defun handler (fn-name args &aux fn-sym)
  (setf fn-sym (gethash fn-name *reg-call*))
  (if fn-sym
      (list (funcall fn-sym args) nil)
    (list nil (make-condition 'function-not-registered))))

(defun start-remote-call-server (host port)
  (make-thread 
   (lambda ()
     (loop :with socket = (usocket:socket-listen host port)
           :with stream = (socket-stream (socket-accept socket))
           :while t
           :do (destructuring-bind (remote-function args)
                   (restore stream)
                 (store (handler remote-function args) stream)
                 (force-output stream))))
   :name (format nil "Remote/Local call server (~A ~A)" host port)))

;(remloc-call::start-remote-call-server "127.0.0.1" 2000)

 


  


             