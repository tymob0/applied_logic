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
            (B step 1 4) (B step 2 4) (B step 3 4) 
        )
)

(define-fun CompareTwoTowers ((step1 Int)(step2 Int)(tower Int)) (Bool)
    (and
        (= (B step1 tower 1) (B step2 tower 1))
        (= (B step1 tower 2) (B step2 tower 2))
        (= (B step1 tower 3) (B step2 tower 3))
        (= (B step1 tower 4) (B step2 tower 4))
    )
)

(define-fun DiskMoved ((step1 Int)(step2 Int)(tower Int)(isZero Bool)) (Bool) 
    (exists ((l1 Int)(l2 Int)(l3 Int)(l4 Int))
        (and
            (distinct l1 l2 l3 l4)
			(<= 1 l1 DiskCount)
			(<= 1 l2 DiskCount)
			(<= 1 l3 DiskCount)
            (<= 1 l4 DiskCount)
            (distinct (B step1 tower l1) (B step2 tower l1))
            (= (B step1 tower l2) (B step2 tower l2))
            (= (B step1 tower l3) (B step2 tower l3))
            (= (B step1 tower l4) (B step2 tower l4))
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
(= (B 1 1 4) 4) (= (B 1 2 4) 0) (= (B 1 3 4) 0)

;Target state.
;Between 1 and MAX there exists a permutation [[0,0,0], [0,0,0], [1,2,3]].
;Z3 will define which step is the MAX.
(= (B MaxStep 1 1) 0) (= (B MaxStep 2 1) 0) (= (B MaxStep 3 1) 1)  
(= (B MaxStep 1 2) 0) (= (B MaxStep 2 2) 0) (= (B MaxStep 3 2) 2) 
(= (B MaxStep 1 3) 0) (= (B MaxStep 2 3) 0) (= (B MaxStep 3 3) 3) 
(= (B MaxStep 1 4) 0) (= (B MaxStep 2 4) 0) (= (B MaxStep 3 4) 4) 
;
;Limit Max steps
(= MaxStep 16)

;Three disks
(= DiskCount 4)

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
            (<= (B step tower 1) (B step tower 2) (B step tower 3) (B step tower 4))
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
    (+ (* 1000 (B 1 1 1)) (* 100 (B 1 1 2)) (* 10 (B 1 1 3)) (B 1 1 4)) 
    (+ (* 1000 (B 1 2 1)) (* 100 (B 1 2 2)) (* 10 (B 1 2 3)) (B 1 2 4)) 
    (+ (* 1000 (B 1 3 1)) (* 100 (B 1 3 2)) (* 10 (B 1 3 3)) (B 1 3 4))
    2
    (+ (* 1000 (B 2 1 1)) (* 100 (B 2 1 2)) (* 10 (B 2 1 3)) (B 2 1 4))
    (+ (* 1000 (B 2 2 1)) (* 100 (B 2 2 2)) (* 10 (B 2 2 3)) (B 2 2 4))
    (+ (* 1000 (B 2 3 1)) (* 100 (B 2 3 2)) (* 10 (B 2 3 3)) (B 2 3 4))
    3
    (+ (* 1000 (B 3 1 1)) (* 100 (B 3 1 2)) (* 10 (B 3 1 3)) (B 3 1 4))
    (+ (* 1000 (B 3 2 1)) (* 100 (B 3 2 2)) (* 10 (B 3 2 3)) (B 3 2 4))
    (+ (* 1000 (B 3 3 1)) (* 100 (B 3 3 2)) (* 10 (B 3 3 3)) (B 3 3 4)) 
    4
    (+ (* 1000 (B 4 1 1)) (* 100 (B 4 1 2)) (* 10 (B 4 1 3)) (B 4 1 4))
    (+ (* 1000 (B 4 2 1)) (* 100 (B 4 2 2)) (* 10 (B 4 2 3)) (B 4 2 4))
    (+ (* 1000 (B 4 3 1)) (* 100 (B 4 3 2)) (* 10 (B 4 3 3)) (B 4 3 4))
    5
    (+ (* 1000 (B 5 1 1)) (* 100 (B 5 1 2)) (* 10 (B 5 1 3)) (B 5 1 4))
    (+ (* 1000 (B 5 2 1)) (* 100 (B 5 2 2)) (* 10 (B 5 2 3)) (B 5 2 4))
    (+ (* 1000 (B 5 3 1)) (* 100 (B 5 3 2)) (* 10 (B 5 3 3)) (B 5 3 4))
    6
    (+ (* 1000 (B 6 1 1)) (* 100 (B 6 1 2)) (* 10 (B 6 1 3)) (B 6 1 4))
    (+ (* 1000 (B 6 2 1)) (* 100 (B 6 2 2)) (* 10 (B 6 2 3)) (B 6 2 4))
    (+ (* 1000 (B 6 3 1)) (* 100 (B 6 3 2)) (* 10 (B 6 3 3)) (B 6 3 4))
    7
    (+ (* 1000 (B 7 1 1)) (* 100 (B 7 1 2)) (* 10 (B 7 1 3)) (B 7 1 4))
    (+ (* 1000 (B 7 2 1)) (* 100 (B 7 2 2)) (* 10 (B 7 2 3)) (B 7 2 4))
    (+ (* 1000 (B 7 3 1)) (* 100 (B 7 3 2)) (* 10 (B 7 3 3)) (B 7 3 4))
    8
    (+ (* 1000 (B 8 1 1)) (* 100 (B 8 1 2)) (* 10 (B 8 1 3)) (B 8 1 4))
    (+ (* 1000 (B 8 2 1)) (* 100 (B 8 2 2)) (* 10 (B 8 2 3)) (B 8 2 4))
    (+ (* 1000 (B 8 3 1)) (* 100 (B 8 3 2)) (* 10 (B 8 3 3)) (B 8 3 4))
    9
    (+ (* 1000 (B 9 1 1)) (* 100 (B 9 1 2)) (* 10 (B 9 1 3)) (B 9 1 4))
    (+ (* 1000 (B 9 2 1)) (* 100 (B 9 2 2)) (* 10 (B 9 2 3)) (B 9 2 4))
    (+ (* 1000 (B 9 3 1)) (* 100 (B 9 3 2)) (* 10 (B 9 3 3)) (B 9 3 4))
    10
    (+ (* 1000 (B 10 1 1)) (* 100 (B 10 1 2)) (* 10 (B 10 1 3)) (B 10 1 4))
    (+ (* 1000 (B 10 2 1)) (* 100 (B 10 2 2)) (* 10 (B 10 2 3)) (B 10 2 4))
    (+ (* 1000 (B 10 3 1)) (* 100 (B 10 3 2)) (* 10 (B 10 3 3)) (B 10 3 4))
    11
    (+ (* 1000 (B 11 1 1)) (* 100 (B 11 1 2)) (* 10 (B 11 1 3)) (B 11 1 4))
    (+ (* 1000 (B 11 2 1)) (* 100 (B 11 2 2)) (* 10 (B 11 2 3)) (B 11 2 4))
    (+ (* 1000 (B 11 3 1)) (* 100 (B 11 3 2)) (* 10 (B 11 3 3)) (B 11 3 4))
    12
    (+ (* 1000 (B 12 1 1)) (* 100 (B 12 1 2)) (* 10 (B 12 1 3)) (B 12 1 4))
    (+ (* 1000 (B 12 2 1)) (* 100 (B 12 2 2)) (* 10 (B 12 2 3)) (B 12 2 4))
    (+ (* 1000 (B 12 3 1)) (* 100 (B 12 3 2)) (* 10 (B 12 3 3)) (B 12 3 4))
    13
    (+ (* 1000 (B 13 1 1)) (* 100 (B 13 1 2)) (* 10 (B 13 1 3)) (B 13 1 4))
    (+ (* 1000 (B 13 2 1)) (* 100 (B 13 2 2)) (* 10 (B 13 2 3)) (B 13 2 4))
    (+ (* 1000 (B 13 3 1)) (* 100 (B 13 3 2)) (* 10 (B 13 3 3)) (B 13 3 4))
    14
    (+ (* 1000 (B 14 1 1)) (* 100 (B 14 1 2)) (* 10 (B 14 1 3)) (B 14 1 4))
    (+ (* 1000 (B 14 2 1)) (* 100 (B 14 2 2)) (* 10 (B 14 2 3)) (B 14 2 4))
    (+ (* 1000 (B 14 3 1)) (* 100 (B 14 3 2)) (* 10 (B 14 3 3)) (B 14 3 4))
    15
    (+ (* 1000 (B 15 1 1)) (* 100 (B 15 1 2)) (* 10 (B 15 1 3)) (B 15 1 4))
    (+ (* 1000 (B 15 2 1)) (* 100 (B 15 2 2)) (* 10 (B 15 2 3)) (B 15 2 4))
    (+ (* 1000 (B 15 3 1)) (* 100 (B 15 3 2)) (* 10 (B 15 3 3)) (B 15 3 4))
    16
    (+ (* 1000 (B 16 1 1)) (* 100 (B 16 1 2)) (* 10 (B 16 1 3)) (B 16 1 4))
    (+ (* 1000 (B 16 2 1)) (* 100 (B 16 2 2)) (* 10 (B 16 2 3)) (B 16 2 4))
    (+ (* 1000 (B 16 3 1)) (* 100 (B 16 3 2)) (* 10 (B 16 3 3)) (B 16 3 4))

)
)




