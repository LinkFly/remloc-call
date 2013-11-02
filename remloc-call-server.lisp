(in-package :remloc-call)

(defparameter *remote-call-servers* (make-hash-table :test 'equal))

(defun reg-call (fn-sym)
  (setf (gethash (list (package-name (symbol-package fn-sym))
                       (symbol-name fn-sym))
                 *reg-call*)
        fn-sym))

(defun handler (package-function args &aux fn-sym)
  (setf fn-sym (gethash package-function *reg-call*))
  (if fn-sym
      (list (apply fn-sym args) nil)
    (list nil (make-condition 'function-not-registered))))

(defun start-remote-call-server (host port &aux socket)
  (setf socket (usocket:socket-listen host port))
  (setf (gethash (list host port) *remote-call-servers*)
        (list
         (make-thread
          (lambda ()
            (loop
             :with stream = (socket-stream (socket-accept socket))
             :while t
             :do (destructuring-bind (package-function args)
                     (restore stream)
                   (store (handler package-function args) stream)
                   (force-output stream))))
          :name (format nil "Remote/Local call server (~A ~A)" host port))
         socket)))



(defun stop-remote-call-server (host port &aux (host-port (list host port)))
  ;(setf host "127.0.0.1" port 2010)
  (destructuring-bind (process socket)
      (gethash host-port *remote-call-servers*)
    (socket-close socket)
    (destroy-thread process)
    (remhash host-port *remote-call-servers*)
    t))

;(remloc-call::start-remote-call-server "127.0.0.1" 2011)
;(remloc-call::stop-remote-call-server "127.0.0.1" 2011)
