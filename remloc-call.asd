;(push "E:/data/real-projects/remloc-call/" asdf:*central-registry*)
(asdf:defsystem :remloc-call
  :depends-on (:cl-store :usocket :bordeaux-threads :lift)
  :serial t
  :components ((:file "package")
               (:file "remloc-call-share")
               (:file "remloc-call-server")
               (:file "remloc-call-client")
               (:file "test")))
