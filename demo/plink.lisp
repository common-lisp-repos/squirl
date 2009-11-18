(in-package :squirl-demo)

(defclass plink-demo (demo)
  ((num-verts :initarg :num-verts :initform 5 :accessor plink-num-verts)
   (static-body :initarg :static-body :initform (make-body :actor :not-grabbable)
                :accessor demo-static-body))
  (:default-initargs :name "Plink!"))

(defun reset-fallen-body (body)
  (let* ((position (body-position body))
         (x (vec-x position))
         (y (vec-y position)))
    (when (or (< y -260) (> (abs x) 340))
      (setf (body-position body)
            (vec (- (random 640) 320) 260)))))

(defmethod update-demo ((demo plink-demo) dt)
  (declare (ignore dt))
  (world-step (world demo) (physics-timestep demo))
  (map-world #'reset-fallen-body (world demo)))

(defun create-static-triangles (demo)
  (let* ((verts (list (vec -15 -15)
                      (vec 0 10)
                      (vec 15 -15))))
    (dotimes (i 9)
      (dotimes (j 6)
        (let* ((stagger (* (mod j 2) 40))
               (offset (vec (- (* i 80) 320 (- stagger))
                            (- (* j 70) 240))))
          (attach-shape (make-poly verts :restitution 1 :friction 1 :offset offset)
                        (demo-static-body demo)))))))

(defun create-polygons (demo)
  (let* ((verts (loop for i below (plink-num-verts demo)
                   collect (let ((angle (/ (* (- 2) pi i) (plink-num-verts demo))))
                             (vec (* 10 (cos angle)) (* 10 (sin angle))))))
         (inertia (moment-for-poly 1 verts)))
    (dotimes (i 300)
      (world-add-body (world demo)
                      (make-body :mass 1 :inertia inertia :position (vec (- (random 640) 320) 350)
                                 :shapes (list (make-poly verts :friction 0.4)))))))

(defmethod init-demo ((demo plink-demo))
  (setf (world demo) (make-world :iterations 5 :gravity (vec 0 -100)))
  (resize-world-active-hash (world demo) 40 999)
  (resize-world-static-hash (world demo) 30 2999)
  (create-static-triangles demo)
  (world-add-body (world demo) (demo-static-body demo))
  (create-polygons demo)
  (world demo))

(pushnew 'plink-demo *demos*)