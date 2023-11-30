; Map (3-dimenions). 1-Step, 2-Tower, 3-Level. Value-disk diameter.
;Level 1 - the top level, Level 2 - the middle level, Level 3 - the bottom level.  
; Diameters. Smallest disk - 1, Medium disk - 2, Large disk - 3. 
(declare-fun B (Int Int Int) Int)

;Disk Count
(declare-const DiskCount Int)

;Max step
(declare-const MaxStep Int)

;Count total
(define-fun Total ((step Int)) Int
        (+
            (B step 1 1) (B step 2 1) (B step 3 1) 
            (B step 1 2) (B step 2 2) (B step 3 2) 
            (B step 1 3) (B step 2 3) (B step 3 3) 
        )
)

;Compare if two towers at certain step are the same
(define-fun CompareTwoTowers ((step1 Int)(step2 Int)(tower Int)) (Bool)
    (and
        (= (B step1 tower 1) (B step2 tower 1))
        (= (B step1 tower 2) (B step2 tower 2))
        (= (B step1 tower 3) (B step2 tower 3))
    )
)

;All the elements in the tower are unaltered except one. The one is either zero (disk removed)
;or non-zero (disk added). Depends on parameter. Negeting exclusive or to get exclusive end.
;So that either both are true, or both are false.
(define-fun DiskMoved ((step1 Int)(step2 Int)(tower Int)(isZero Bool)) (Bool) 
    (exists ((l1 Int)(l2 Int)(l3 Int))
        (and
            (distinct l1 l2 l3)
			(<= 1 l1 3)
			(<= 1 l2 3)
			(<= 1 l3 3)
            (distinct (B step1 tower l1) (B step2 tower l1))
            (= (B step1 tower l2) (B step2 tower l2))
            (= (B step1 tower l3) (B step2 tower l3))
            (not (xor (= (B step2 tower l1) 0) isZero))
        ) 
    )
)


(assert
(and

;Initial state: Step 1 - [[1,2,3], [0,0,0], [0,0,0]]
(= (B 1 1 1) 1) (= (B 1 2 1) 0) (= (B 1 3 1) 0)  
(= (B 1 1 2) 2) (= (B 1 2 2) 0) (= (B 1 3 2) 0)
(= (B 1 1 3) 3) (= (B 1 2 3) 0) (= (B 1 3 3) 0)

;Target state.
;Between 1 and MAX there exists a permutation [[0,0,0], [0,0,0], [1,2,3]].
;Z3 will define which step is the MAX.
(= (B MaxStep 1 1) 0) (= (B MaxStep 2 1) 0) (= (B MaxStep 3 1) 1)  
(= (B MaxStep 1 2) 0) (= (B MaxStep 2 2) 0) (= (B MaxStep 3 2) 2) 
(= (B MaxStep 1 3) 0) (= (B MaxStep 2 3) 0) (= (B MaxStep 3 3) 3) 

;Limit Max steps
(<= 1 MaxStep 8)

;Three disks
(= DiskCount 3)

;Total stays the same
(forall ((step Int))
    (=> (<= 1 step (- MaxStep 1))
        (= (Total step) (Total (+ step 1)))
    )
)

;Entry is between 0 and disk count
;No larger disk is placed on top of smaller
(forall ((step Int) (tower Int) (level Int))
    (=> (<= 1 step MaxStep) 
        (and
            (<= 0 (B step tower level) DiskCount)
            (<= (B step tower 1) (B step tower 2) (B step tower 3))
        )
    )
)

;One tower is unaltered.
;One disk is moved at a time.
(forall ((step Int))
    (=> (<= 1 step MaxStep)
        (exists ((t1 Int) (t2 Int) (t3 Int))
            (and
                (distinct t1 t2 t3)
                (<= 1 t1 3)
                (<= 1 t2 3)
                (<= 1 t3 3)

                (CompareTwoTowers step (+ step 1) t1)
                (DiskMoved step (+ step 1) t2 true)
                (DiskMoved step (+ step 1) t3 false)
            )
        ) 
    )
)
))
;Applying the formula to make the output readable.
(check-sat)
(get-value 
(
    MaxStep

    1
    (+ (* 100 (B 1 1 1)) (* 10 (B 1 1 2)) (B 1 1 3))
    (+ (* 100 (B 1 2 1)) (* 10 (B 1 2 2)) (B 1 2 3))
    (+ (* 100 (B 1 3 1)) (* 10 (B 1 3 2)) (B 1 3 3))
    2
    (+ (* 100 (B 2 1 1)) (* 10 (B 2 1 2)) (B 2 1 3))
    (+ (* 100 (B 2 2 1)) (* 10 (B 2 2 2)) (B 2 2 3))
    (+ (* 100 (B 2 3 1)) (* 10 (B 2 3 2)) (B 2 3 3))
    3
    (+ (* 100 (B 3 1 1)) (* 10 (B 3 1 2)) (B 3 1 3))
    (+ (* 100 (B 3 2 1)) (* 10 (B 3 2 2)) (B 3 2 3))
    (+ (* 100 (B 3 3 1)) (* 10 (B 3 3 2)) (B 3 3 3)) 
    4
    (+ (* 100 (B 4 1 1)) (* 10 (B 4 1 2)) (B 4 1 3))
    (+ (* 100 (B 4 2 1)) (* 10 (B 4 2 2)) (B 4 2 3))
    (+ (* 100 (B 4 3 1)) (* 10 (B 4 3 2)) (B 4 3 3))
    5
    (+ (* 100 (B 5 1 1)) (* 10 (B 5 1 2)) (B 5 1 3))
    (+ (* 100 (B 5 2 1)) (* 10 (B 5 2 2)) (B 5 2 3))
    (+ (* 100 (B 5 3 1)) (* 10 (B 5 3 2)) (B 5 3 3))
    6
    (+ (* 100 (B 6 1 1)) (* 10 (B 6 1 2)) (B 6 1 3))
    (+ (* 100 (B 6 2 1)) (* 10 (B 6 2 2)) (B 6 2 3))
    (+ (* 100 (B 6 3 1)) (* 10 (B 6 3 2)) (B 6 3 3))
    7
    (+ (* 100 (B 7 1 1)) (* 10 (B 7 1 2)) (B 7 1 3))
    (+ (* 100 (B 7 2 1)) (* 10 (B 7 2 2)) (B 7 2 3))
    (+ (* 100 (B 7 3 1)) (* 10 (B 7 3 2)) (B 7 3 3))
    8
    (+ (* 100 (B 8 1 1)) (* 10 (B 8 1 2)) (B 8 1 3))
    (+ (* 100 (B 8 2 1)) (* 10 (B 8 2 2)) (B 8 2 3))
    (+ (* 100 (B 8 3 1)) (* 10 (B 8 3 2)) (B 8 3 3))
)
)




