;(push "E:/data/real-projects/remloc-call/" asdf:*central-registry*)
(asdf:defsystem :remloc-call
  :depends-on (:cl-store :usocket :bordeaux-threads :lift)
  :serial t
  :components ((:file "package")
               (:file "remloc-call-share")
               (:file "remloc-call-server")
               (:file "remloc-call-client")
               (:file "test")))

(defmethod perform ((o test-op) (c (eql (asdf:find-system :remloc-call))))
  (declare (ignore o c))
  (funcall (find-symbol "RUN-REMLOC-CALL-TESTS" :remloc-call.test)))
