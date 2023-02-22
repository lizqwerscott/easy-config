(defsystem "easy-config"
  :version "0.1.0"
  :author "lizqwer scott"
  :license ""
  :depends-on ("lzputils")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "easy-config/tests"))))

(defsystem "easy-config/tests"
  :author ""
  :license ""
  :depends-on ("easy-config"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for easy-config"
  :perform (test-op (op c) (symbol-call :rove :run c)))
