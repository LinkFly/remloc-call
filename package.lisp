(defpackage :remloc-call 
  (:use :cl :usocket :cl-store :bordeaux-threads :lift)
  (:export
   #:start-remote-call-server stop-remote-call-server #:connect-to-remote-call-server
   #:reg-call #:def-call
   #:*local-call* #:*check-registered*
   #:function-not-registered #:local-function-not-registered))