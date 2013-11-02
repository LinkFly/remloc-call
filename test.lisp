(defpackage :remloc-call.test (:use :cl :remloc-call :lift))

(in-package :remloc-call.test)
(deftestsuite remloc-call.test () ())

(defparameter *test-port* 3000)

(defparameter *test-call-remote-stream* nil)

(defun fun1 (&rest args) (list "fun1" args))
(defun fun2 (&rest args) (list "fun2" args))
(defun fun3 (&rest args) (list "fun3" args))

(defun run-tests (&key (test-port *test-port*) &aux sock)
  ;(setf test-port 2003)
  (setf sock (second (start-remote-call-server "127.0.0.1" test-port)))
  (unwind-protect
      (let ((*test-call-remote-stream* nil))
        (reg-call 'fun1)
        (reg-call 'fun3)
        (connect-to-remote-call-server "127.0.0.1" test-port '*test-call-remote-stream*)
        (def-call fn1 ("REMLOC-CALL.TEST" "FUN1") :remote-call-stream-sym *test-call-remote-stream*)
        (def-call fn2 ("REMLOC-CALL.TEST" "FUN2") :remote-call-stream-sym *test-call-remote-stream*)
        (def-call fn3 ("REMLOC-CALL.TEST" "FUN3") :remote-call-stream-sym *test-call-remote-stream*)
        (prog1
            (and
             (let ((*local-call* nil))
               (and
                (equal (fn1 :param1 'param1) '("fun1" (:param1 param1)))
                (eq 'function-not-registered (type-of (second (multiple-value-list (ignore-errors (fn2 :param2 'param2))))))
                (equal (fn3 :param3 'param3) '("fun3" (:param3 param3)))))
             (let ((*local-call* t)
                   (*check-registered* t))
               (and
                (equal (fn1 :param1 'param1) '("fun1" (:param1 param1)))
                (eq 'local-function-not-registered (type-of (second (multiple-value-list (ignore-errors (fn2 :param2 'param2))))))
                (equal (let ((*check-registered* nil))
                         (fn2 :param2 'param2))
                       '("fun2" (:param2 param2)))
                (equal (fn3 :param3 'param3) '("fun3" (:param3 param3))))))))
    (stop-remote-call-server "127.0.0.1" test-port)))

(addtest all-tests
  (ensure (run-tests)))

