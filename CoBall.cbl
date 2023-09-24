      ******************************************************************
      * Author: Jon
      * Date: Today
      * Purpose:
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. YOUR-PROGRAM-NAME.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BINARY-FILE ASSIGN "OUT.BMP"
               ORGANISATION IS SEQUENTIAL
               ACCESS IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD BINARY-FILE EXTERNAL.
       01 BINARY-DATA PIC X.

       WORKING-STORAGE SECTION.
       77 FILE-PATH PIC X(80).

       01 X PIC 9(9) COMP.
       01 Y PIC 9(9) COMP.
       01 T PIC 9(9) COMP.

       01 XF COMP-1.
       01 YF COMP-1.
       01 FOVX COMP-1.
       01 FOVY COMP-1.
       01 WIDTH-F COMP-1.
       01 HEIGHT-F COMP-1.

       01 TEMP-COLOR PIC XXX.

       01 COLOR_OUT.
         02 COLOR-R PIC 9(9) COMP.
         02 COLOR-G PIC 9(9) COMP.
         02 COLOR-B PIC 9(9) COMP.

       01 HEADER-SIZE PIC 9(9) COMP.
       01 FILE-SIZE PIC 9(9) COMP.

      *oh god am I really gonna try this

       01 BITMAP-IMAGE.
           05 IMAGE-WIDTH PIC 9(9) COMP.
           05 IMAGE-HEIGHT PIC 9(9) COMP.
           05 IMAGE-PIXELS PIC 9(9) COMP.
           05 IMAGE-BYTES PIC 9(9) COMP.

           05 IMAGE-ROWS OCCURS 1 TO 256 TIMES DEPENDING ON IMAGE-WIDTH.
           10 IMAGE-COLS  OCCURS 1 TO 256 TIMES
             DEPENDING ON IMAGE-HEIGHT.
           15 PIXEL-VALUE PIC XXX.

       01 FIX-BROKEN-GARBAGE PIC 9(9) COMP.
       01 FIX-BROKEN-GARBAGE-SHORT PIC 9(4) COMP.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE "./OUT.bmp" TO FILE-PATH

           OPEN OUTPUT BINARY-FILE

           MOVE 54 TO HEADER-SIZE

           MOVE 256 TO IMAGE-WIDTH
           MOVE 256 TO IMAGE-HEIGHT
           MULTIPLY IMAGE-WIDTH BY IMAGE-HEIGHT
               GIVING IMAGE-PIXELS
           MULTIPLY IMAGE-PIXELS BY 3 GIVING IMAGE-BYTES

           ADD IMAGE-BYTES TO HEADER-SIZE GIVING FILE-SIZE

           DISPLAY "IMAGE-WIDTH" IMAGE-WIDTH.
           DISPLAY "IMAGE-PIXELS" IMAGE-PIXELS.
           DISPLAY "IMAGE-BYTES" IMAGE-BYTES.
           DISPLAY "FILE-SIZE" FILE-SIZE.

           MOVE "B" TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE
           MOVE "M" TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE
      *FILESIZE, RESERVED, DATAOFFSET
           CALL 'WRITE-INT-TO-FILE' USING FILE-SIZE
           CALL 'WRITE-INT-TO-FILE' USING 0
           CALL 'WRITE-INT-TO-FILE' USING HEADER-SIZE

      *I DESPISE THIS EXISTANCE
           MOVE 40 TO FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE

           CALL 'WRITE-INT-TO-FILE' USING IMAGE-WIDTH
           CALL 'WRITE-INT-TO-FILE' USING IMAGE-HEIGHT
           MOVE 1 TO FIX-BROKEN-GARBAGE-SHORT
           CALL 'WRITE-SHORT-TO-FILE' USING FIX-BROKEN-GARBAGE-SHORT
           MOVE 24 TO FIX-BROKEN-GARBAGE-SHORT
           CALL 'WRITE-SHORT-TO-FILE' USING FIX-BROKEN-GARBAGE-SHORT
           MOVE 0 TO FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE
           MOVE 1024 TO FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE
           MOVE 16777216 TO FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE
           MOVE 0 TO FIX-BROKEN-GARBAGE
           CALL 'WRITE-INT-TO-FILE' USING FIX-BROKEN-GARBAGE

           MOVE IMAGE-WIDTH TO WIDTH-F
           MOVE IMAGE-HEIGHT TO HEIGHT-F

           MOVE 1.309 TO FOVY
           DIVIDE WIDTH-F INTO HEIGHT-F GIVING FOVX
           MULTIPLY FOVY BY FOVX GIVING FOVX

           MULTIPLY 0.5 BY FOVX
           MULTIPLY 0.5 BY FOVY

           MOVE FUNCTION TAN(FOVX) TO FOVX
           MOVE FUNCTION TAN(FOVY) TO FOVY

           DISPLAY 'FOVX ' FOVX
           DISPLAY 'FOVY ' FOVY

           PERFORM VARYING X FROM 1 BY 1
           UNTIL X > IMAGE-WIDTH
             MOVE X TO XF

             DIVIDE WIDTH-F INTO XF GIVING XF

             MULTIPLY 2.0 BY XF
             SUBTRACT 1.0 FROM XF

             MULTIPLY FOVX BY XF

             PERFORM VARYING Y FROM 1 BY 1
             UNTIL Y > IMAGE-HEIGHT
               MOVE Y TO YF

               DIVIDE HEIGHT-F INTO YF GIVING YF
               SUBTRACT YF FROM 1.0 GIVING YF
               MULTIPLY 2.0 BY YF
               SUBTRACT 1.0 FROM YF

               MULTIPLY FOVY BY YF



               CALL 'RENDER-PIXEL' USING XF,YF,
                 FOVX,FOVY,COLOR_OUT

               CALL 'MAKE-RGB' USING COLOR-R, COLOR-G,
                 COLOR-B, TEMP-COLOR

               MOVE TEMP-COLOR TO PIXEL-VALUE(X,Y)

             END-PERFORM
           END-PERFORM


           PERFORM VARYING Y FROM 1 BY 1
           UNTIL Y > IMAGE-HEIGHT

             PERFORM VARYING X FROM 1 BY 1
             UNTIL X > IMAGE-WIDTH

               MOVE PIXEL-VALUE(X,Y)(1:1) TO BINARY-DATA
               WRITE BINARY-DATA
               MOVE PIXEL-VALUE(X,Y)(2:1) TO BINARY-DATA
               WRITE BINARY-DATA
               MOVE PIXEL-VALUE(X,Y)(3:1) TO BINARY-DATA
               WRITE BINARY-DATA

             END-PERFORM
           END-PERFORM

           CLOSE BINARY-FILE
           DISPLAY 'DONE'
           STOP RUN.
       END PROGRAM YOUR-PROGRAM-NAME.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITE-INT-TO-FILE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BINARY-FILE ASSIGN "OUT.BMP"
               ORGANISATION IS SEQUENTIAL
               ACCESS IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD BINARY-FILE EXTERNAL.
       01 BINARY-DATA PIC X.
       WORKING-STORAGE SECTION.
       01 INT-OUT-CHAR PIC XXXX.
       01 INT-OUT REDEFINES INT-OUT-CHAR PIC 9(9) COMP.
       LINKAGE SECTION.
       01 CALL_VAL PIC 9(9) COMP.
       PROCEDURE DIVISION USING CALL_VAL.
       MAIN-PROCEDURE.
           MOVE CALL_VAL TO INT-OUT

           MOVE INT-OUT-CHAR(4:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.
           MOVE INT-OUT-CHAR(3:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.
           MOVE INT-OUT-CHAR(2:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.
           MOVE INT-OUT-CHAR(1:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.

       END PROGRAM WRITE-INT-TO-FILE.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITE-SHORT-TO-FILE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BINARY-FILE ASSIGN "OUT.BMP"
               ORGANISATION IS SEQUENTIAL
               ACCESS IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD BINARY-FILE EXTERNAL.
       01 BINARY-DATA PIC X.
       WORKING-STORAGE SECTION.
       01 SHORT-OUT-CHAR PIC XX.
       01 SHORT-OUT REDEFINES SHORT-OUT-CHAR PIC 9(4) COMP.
       LINKAGE SECTION.
       01 CALL_VAL PIC 9(4) COMP.
       PROCEDURE DIVISION USING CALL_VAL.
       MAIN-PROCEDURE.
           MOVE CALL_VAL TO SHORT-OUT

           MOVE SHORT-OUT-CHAR(2:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.
           MOVE SHORT-OUT-CHAR(1:1) TO BINARY-DATA
           WRITE BINARY-DATA
           END-WRITE.

       END PROGRAM WRITE-SHORT-TO-FILE.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. MAKE-RGB.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 SHORT-OUT-CHAR PIC XXXX.
       01 SHORT-OUT REDEFINES SHORT-OUT-CHAR PIC 9(9) COMP.
       01 COLOR_OUT_T PIC XXX.
       LINKAGE SECTION.
       01 R PIC 9(9) COMP.
       01 G PIC 9(9) COMP.
       01 B PIC 9(9) COMP.
       01 COLOR_OUT PIC XXX.

       PROCEDURE DIVISION USING R, G, B, COLOR_OUT.
       MAIN-PROCEDURE.
           MOVE R TO SHORT-OUT
           MOVE SHORT-OUT-CHAR(4:1) TO COLOR_OUT_T(3:1)
           MOVE G TO SHORT-OUT
           MOVE SHORT-OUT-CHAR(4:1) TO COLOR_OUT_T(2:1)
           MOVE B TO SHORT-OUT
           MOVE SHORT-OUT-CHAR(4:1) TO COLOR_OUT_T(1:1).
           MOVE COLOR_OUT_T TO COLOR_OUT.

       END PROGRAM MAKE-RGB.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. RENDER-PIXEL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 COLOR-TEMP PIC XXX.

       01 RAY.
         02 RAY-POS.
         03 RAY-POS-VALS COMP-1 OCCURS 3 TIMES.
         02 RAY-DIR.
         03 RAY-DIR-VALS COMP-1 OCCURS 3 TIMES.

       01 A COMP-1.
       01 B COMP-1.
       01 C COMP-1.

       01 NORM.
         02 NORMAL-VALS COMP-1 OCCURS 3 TIMES.
       01 LIGHT-DIR.
         02 LIGHT-DIR-VALS COMP-1 OCCURS 3 TIMES.
       01 HIT-POS.
         02 HIT-POS-VALS COMP-1 OCCURS 3 TIMES.

       LINKAGE SECTION.
       01 L-X-DIR COMP-1.
       01 L-Y-DIR COMP-1.
       01 FOVX COMP-1.
       01 FOVY COMP-1.
       01 COLOR_OUT.
         02 COLOR-R PIC 9(9) COMP.
         02 COLOR-G PIC 9(9) COMP.
         02 COLOR-B PIC 9(9) COMP.

       PROCEDURE DIVISION USING L-X-DIR,L-Y-DIR,FOVX,FOVY,COLOR_OUT.
       MAIN-PROCEDURE.

      *     DISPLAY L-X-DIR " : " L-Y-DIR

           MOVE 0 TO RAY-POS-VALS(1)
           MOVE 0 TO RAY-POS-VALS(2)
           MOVE 3 TO RAY-POS-VALS(3)

           MOVE L-X-DIR TO RAY-DIR-VALS(1)
           MOVE L-Y-DIR TO RAY-DIR-VALS(2)
           MOVE -1.0 TO RAY-DIR-VALS(3)

           CALL 'V3-NORM' USING RAY-DIR, RAY-DIR

           CALL 'SPHERECAST-SCENE' USING RAY, A

           IF A < 100.0 THEN

             MOVE -1 TO LIGHT-DIR-VALS(1)
             MOVE -1 TO LIGHT-DIR-VALS(2)
             MOVE 1 TO LIGHT-DIR-VALS(3)
             CALL 'V3-NORM' USING LIGHT-DIR, LIGHT-DIR

             CALL 'V3-MUL-S' USING RAY-DIR, A, HIT-POS
             CALL 'V3-ADD' USING HIT-POS, RAY-POS, HIT-POS

             CALL 'GET-SURFACE-NORMAL' USING HIT-POS, NORM

             CALL 'V3-LEN'USING NORM, C


             CALL 'V3-NORM' USING NORM, NORM
             CALL 'V3-LEN'USING NORM, C

             CALL 'V3-DOT' USING NORM, LIGHT-DIR, B
             IF B < 0.0 THEN
               MOVE 0.0 TO B
             END-IF

             MULTIPLY 150.0 BY B
             ADD 50.0 TO B


             MOVE B TO COLOR-R
             MOVE B TO COLOR-G
             MOVE B TO COLOR-B
           ELSE
             MOVE 0 TO COLOR-R
             MOVE 0 TO COLOR-G
             MOVE 0 TO COLOR-B
           END-IF


           .
       END PROGRAM RENDER-PIXEL.








       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPHERECAST-SCENE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 DEPTH COMP-1.
       01 DISTANCE COMP-1.
       01 CURRENT-POS.
         02 CURRENT-POS-VALS COMP-1 OCCURS 3 TIMES.

       LINKAGE SECTION.
       01 RAY.
         02 RAY-POS.
           03 RAY-POS-VALS COMP-1 OCCURS 3 TIMES.
         02 RAY-DIR.
           03 RAY-DIR-VALS COMP-1 OCCURS 3 TIMES.
       01 RESULT COMP-1.

       PROCEDURE DIVISION USING RAY, RESULT.
       MAIN-PROCEDURE.

       MOVE 0.0 TO DEPTH
       MOVE 100.0 TO RESULT

       PERFORM 256 TIMES
           CALL 'V3-MUL-S' USING RAY-DIR, DEPTH, CURRENT-POS
           CALL 'V3-ADD' USING CURRENT-POS, RAY-POS, CURRENT-POS
           CALL 'SCENE-SDF' USING CURRENT-POS, DISTANCE


           IF DISTANCE LESS THAN 0.00001 THEN
             MOVE DEPTH TO RESULT
             GOBACK
           END-IF

           ADD DISTANCE TO DEPTH

           IF DEPTH GREATER THAN 100.0 THEN
             GOBACK
           END-IF
       END-PERFORM
                   .
       END PROGRAM SPHERECAST-SCENE.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. SCENE-SDF.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01 WORLD-POS.
         02 WORLD-POS-VALS COMP-1 OCCURS 3 TIMES.
       01 SDF COMP-1.

       PROCEDURE DIVISION USING WORLD-POS, SDF.
       MAIN-PROCEDURE.

         CALL 'V3-LEN' USING WORLD-POS, SDF
         SUBTRACT 1.0 FROM SDF.

       END PROGRAM SCENE-SDF.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. GET-SURFACE-NORMAL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.

       01 OFFSET.
         02 OFFSET-VALS COMP-1 OCCURS 3 TIMES.
       01 QUERY-POS.
         02 QUERY-POS-VALS COMP-1 OCCURS 3 TIMES.
       01 LHS COMP-1.
       01 RHS COMP-1.

       LINKAGE SECTION.
       01 POS.
         02 POS-VALUES COMP-1 OCCURS 3 TIMES.
       01 RESULT.
         02 RESULT-VALUES COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING POS, RESULT.
       MAIN-PROCEDURE.
       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
         MOVE 0.0 TO OFFSET-VALS(I)
       END-PERFORM

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
         MOVE 0.001 TO OFFSET-VALS(I)
         CALL 'V3-ADD' USING POS, OFFSET, QUERY-POS
         CALL 'SCENE-SDF' USING QUERY-POS, LHS
         CALL 'V3-SUB' USING POS, OFFSET, QUERY-POS
         CALL 'SCENE-SDF' USING QUERY-POS, RHS

         COMPUTE RESULT-VALUES(I) = LHS - RHS



         MOVE 0.0 TO OFFSET-VALS(I)
       END-PERFORM


         .
       END PROGRAM GET-SURFACE-NORMAL.


      *=================================================================
      *VECTOR NONSENSE==================================================
      *=================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-ADD.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B.
       02 B-VALS COMP-1 OCCURS 3 TIMES.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R-VALS(I) = A-VALS(I) + B-VALS(I)
       END-PERFORM.

       END PROGRAM V3-ADD.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-SUB.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B.
       02 B-VALS COMP-1 OCCURS 3 TIMES.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R-VALS(I) = A-VALS(I) - B-VALS(I)
       END-PERFORM.

       END PROGRAM V3-SUB.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-MUL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B.
       02 B-VALS COMP-1 OCCURS 3 TIMES.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R-VALS(I) = A-VALS(I) * B-VALS(I)
       END-PERFORM.

       END PROGRAM V3-MUL.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-DIV.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B.
       02 B-VALS COMP-1 OCCURS 3 TIMES.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R-VALS(I) = A-VALS(I) / B-VALS(I)
       END-PERFORM.

       END PROGRAM V3-DIV.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-DOT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B.
       02 B-VALS COMP-1 OCCURS 3 TIMES.
       01 R COMP-1.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.
       MOVE 0.0 TO R
       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R = R + (A-VALS(I) * B-VALS(I))
       END-PERFORM.

       END PROGRAM V3-DOT.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-MUL-S.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 B COMP-1.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,B,R.
       MAIN-PROCEDURE.

       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
       COMPUTE R-VALS(I) = A-VALS(I) * B
       END-PERFORM.

       END PROGRAM V3-MUL-S.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-LEN.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 R COMP-1.

       PROCEDURE DIVISION USING A,R.
       MAIN-PROCEDURE.
       MOVE 0.0 TO R
       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
         COMPUTE R = R + (A-VALS(I) * A-VALS(I))
       END-PERFORM.
         COMPUTE R = FUNCTION SQRT(R).

       END PROGRAM V3-LEN.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. V3-NORM.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 I PIC 9(9) COMP.
       01 LEN COMP-1.
       LINKAGE SECTION.
       01 A.
       02 A-VALS COMP-1 OCCURS 3 TIMES.
       01 R.
       02 R-VALS COMP-1 OCCURS 3 TIMES.

       PROCEDURE DIVISION USING A,R.
       MAIN-PROCEDURE.

       CALL 'V3-LEN' USING A, LEN
       PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
         COMPUTE R-VALS(I) = A-VALS(I) / LEN
       END-PERFORM.

       END PROGRAM V3-NORM.
