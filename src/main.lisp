(defpackage easy-config
  (:import-from :alexandria :switch)
  (:import-from :alexandria :when-let)
  (:use :cl :lzputils.used :lzputils.json)
  (:export
   :defconfig

   :refersh-config
   
   :get-config
   :set-config))
(in-package :easy-config)

(defvar *config-name* nil)

(defvar *config-dir-root* nil)
(defvar *config-dir* nil)
(defvar *config-path* nil)
(defvar *data-dir* nil)

(defun init-config (name &optional (datap nil))
  (setf *config-name* name)
  (setf *config-dir-root*
        (truename
         (ensure-directories-exist
          (format nil
                  "~A.~A/"
                  "~/"
                  *config-name*))))
  (setf *config-dir*
        (truename
         (ensure-directories-exist
          (merge-pathnames "config/"
                           *config-dir-root*))))
  (setf *config-path*
        (merge-pathnames "config.json"
                         *config-dir*))
  (when datap
    (setf *data-dir*
          (ensure-directories-exist
           (merge-pathnames "data/"
                            *config-dir-root*))))
  *config-dir-root*)

(defvar *key-value* (make-hash-table))

(defun set-key-value (plist)
  (let ((name (car plist))
        (args (cdr plist)))
    (setf (gethash name
                   *key-value*)
          (if-return (getf args :default)
            (when-let (type (getf args :type))
              (switch (type)
                (:str "")
                (:number 0)
                (:bool :false)
                (:array nil)))))))

(defmacro defconfig (name key-value)
  `(progn
     (init-config ,(symbol-to-lower-string (car name))
                  ,(second name))
     (mapcar #'set-key-value
             ',key-value)
     (if (probe-file *config-path*)
         (refersh-config)
         (save-config))))

(defun config-to-json ()
  (let ((res nil))
    (maphash #'(lambda (k v)
                 (setf res
                       (append1 res
                                (cons (symbol-to-lower-string k) v))))
             *key-value*)
    (to-json-a res)))

(defun json-to-config (json)
  (dolist (i json)
    (let ((j-key (read-from-string (car i)))
          (value (cdr i)))
      (multiple-value-bind (l-value havep) (gethash j-key
                                                    *key-value*)
        (when havep
          (setf (gethash j-key
                         *key-value*)
                value))))))

(defun refersh-config ()
  (json-to-config
   (load-json-file
    *config-path*)))

(defun save-config ()
  (save-json-file *config-path*
                  (config-to-json)))

(defun get-config (key)
  (refersh-config)
  (multiple-value-bind (value havep) (gethash key *key-value*)
    (when havep
      value)))

(defun set-config (key value)
  (multiple-value-bind (l-value havep) (gethash key *key-value*)
    (when havep
      (setf (gethash key
                     *key-value*)
            value)
      (save-config)
      l-value)))

(defun test ()
  (defconfig (:connect-any)
      ((name :type :str :default "")
       (id :type :number)
       (host :type :bool)
       (applelist :type :array))))
