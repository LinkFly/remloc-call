(in-package :remloc-call)

(defun reg-call (fn-sym)
  (setf (gethash (list (package-name (symbol-package fn-sym))
                       (symbol-name fn-sym))
                 *reg-call*)
        fn-sym))

;(defun fun1 (&args) "Hi!!!")
;(defun fun2 (&args) "Hello world!!!")
;(defun fun3 (&args) "fun3!!!")
;(defun fun4 (&args) "fun444!!!")
;(reg-call 'fun1)
;(reg-call 'fun2)
;(reg-call 'fun3)
;(reg-call 'fun4)

(defun handler (package-function args &aux fn-sym)
  (setf fn-sym (gethash package-function *reg-call*))
  (if fn-sym
      (list (funcall fn-sym args) nil)
    (list nil (make-condition 'function-not-registered))))

(defun start-remote-call-server (host port)
  (make-thread 
   (lambda ()
     (loop :with socket = (usocket:socket-listen host port)
           :with stream = (socket-stream (socket-accept socket))
           :while t
           :do (destructuring-bind (package-function args)
                   (restore stream)
                 (store (handler package-function args) stream)
                 (force-output stream))))
   :name (format nil "Remote/Local call server (~A ~A)" host port)))

;(remloc-call::start-remote-call-server "127.0.0.1" 2000)

 


  


             