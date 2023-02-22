(defpackage easy-config/tests/main
  (:use :cl
        :easy-config
        :rove))
(in-package :easy-config/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :easy-config)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
