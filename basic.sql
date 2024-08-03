SELECT * FROM emp;

-- CRUD(Create, Read, Update, Delete)
CREATE TABLE emp2 AS SELECT * FROM emp;
DESC emp2;

// Read
SELECT * FROM emp2;
SELECT * FROM emp2 WHERE deptno=20;
SELECT * FROM emp2 WHERE deptno=20 ORDER BY sal DESC;

// 한행 추가, Create
INSERT INTO emp2 (empno, ename, job, mgr, hiredate, sal ) 
VALUES(7777, '박찬호', '체육', 7902, '2002-11-16', 3030);
SELECT * FROM emp2;

// Update
UPDATE emp2 SET deptno=10 WHERE empno=7777;

// Delete
DELETE FROM emp2 WHERE ename='박찬호';

-- commit : 
commit;

-- 11번 사원정보를 삭제해보세요
DELETE FROM emp2 WHERE empno=7902;
rollback;

-- Sub-Query
// smith와 같은 부서에 근무하는 사원들의 정보를 표시해보세요
SELECT * FROM emp2 WHERE ename='SMITH';
SELECT deptno FROM emp2 WHERE ename='SMITH';
SELECT * FROM emp2 WHERE deptno=
(
    SELECT deptno FROM emp2 WHERE ename='SMITH'
);

// WARD와 같은 상급자를 둔 직원들의 이름, mgr을 표시해보세요.
SELECT ename, mgr FROM emp2 WHERE mgr=
(
    SELECT mgr FROM emp2 WHERE ename='WARD'
);

// 전체 사원의 이름과 급여를 표시하되 급여 내림차순으로 표시해보세요
-- ORDER BY sal, ORDER BY sal DESC
SELECT ename, sal FROM emp2 ORDER BY sal DESC;
-- WHERE sal>=1600;
SELECT * FROM emp2 WHERE sal>=1600;

SELECT * FROM (SELECT * FROM emp2 WHERE sal>=1600)  -- Inline View
WHERE job='MANAGER';

-- Relational Database System(RDBMS)
-- JOIN(Cross JOIN, Equi JOIN, Outer JOIN)

-- 정규형(1,2,3정규형): Normalization
// 사원정보(emp, dept, salgrade)
// smith 사원의 이름과 부서번호, 부서명을 표시해보세요.
SELECT ename, e.deptno, dname
FROM emp e JOIN dept d --INNER Join: 
ON e.deptno=d.deptno;

// 특정 사원의 이름과 부서번호, 부서명을 표시해보세요
// BLAKE
SELECT ename, e.deptno, dname
FROM emp e JOIN dept d --INNER Join: 
ON e.deptno=d.deptno
WHERE ename='BLAKE';

// smith의 호봉은? 이름, 급여액, 호봉수
SELECT ename, sal, grade
FROM emp e JOIN salgrade s
ON e.sal BETWEEN s.losal AND s.hisal
WHERE ename='SMITH';

// smith의 이름과 부서번호, 급여액, 부서명, 호봉수를 표시해보세요.
SELECT ename, e.deptno, sal, dname, grade
FROM emp e JOIN dept d ON e.deptno=d.deptno
JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal;

-- SELF JOIN: 한개의 테이블을 마치 2개의 독립적인 테이블처럼 JOIN에 사용하는 것
// 전체 사원의 번호, 이름, 상급자 번호, 상급자 이름
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON e.mgr=m.empno;

// 각 부서의 평균급여보다 더 많은 급여를 받는 사원의 이름,부서번호,급여액 표시
SELECT ROUND(AVG(sal),2) "전사원의 평균급여" FROM emp;
SELECT ROUND(AVG(sal),2) "전사원의 평균급여", MAX(sal), MIN(sal)
FROM emp2;

// 20번 부서의 평균급여액을 표시
SELECT ROUND(AVG(sal)) FROM emp2 WHERE deptno=20;

// 하위그룹을 지어서 각 그룹에 대한 통계
SELECT deptno, COUNT(*) "사원부" FROM emp2 
GROUP BY deptno
ORDER BY deptno;

// SELF JOIN, INNER JOIN
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON e.mgr=m.empno;

-- OUTER JOIN
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e LEFT OUTER JOIN emp m ON e.mgr=m.empno;

-- 상관관계 서브커리(Correlated Sub-Query)
// 일반 서브커리는 가장 깊은 괄호안에 있는 커리가 한번만 실행되어 값을 가지지고 있지만
// 상관관계 서브커리는 바깥 커리가 실행될 때마다 한번씩 실행된다
// 각 부서에서 해당부서의 평균급여액보다 더 많이 받는 사원정보만 화면에 표시해보세요.
// SELECT 문장이 실행될 때는 각 행을 검사하여 선택여부를 결정한다
// 각 행마다 포함되어 있는 부서번호(deptno)를 사용하여 평균급여액을 구한다
// 현재 조사 중인 행의 사원정보가 평균급여액보다 더 받는 경우에만 그 행을 선택한다
SELECT ename, sal, deptno FROM emp2 e
WHERE sal>(
    SELECT AVG(sal) FROM emp2 e2 WHERE e.deptno=e2.deptno
)
ORDER BY deptno;

DESC dept;

SELECT empno, ename, e.deptno, dname, grade "호봉"
FROM emp e JOIN dept d ON e.deptno=d.deptno
JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
WHERE empno=7369;

-- AND, OR
SELECT * FROM emp2 WHERE job='CLERK' AND job='MANAGER';
SELECT * FROM emp2 WHERE job='CLERK' OR job='MANAGER';

-- CROSS JOIN
SELECT * FROM emp, dept;   -- 12 x 4 = 48
// 목록을 가져올 때 데이터의 총 행수를 동시에 가져와야 한다
SELECT COUNT(*) FROM emp;
SELECT * FROM emp;

SELECT *
FROM emp2 CROSS JOIN (SELECT COUNT(*)total FROM emp2);

-- 게시글을 작성할 때 첨부파일을 다수개 첨부하는 경우
// board(게시글), attach(첨부)
// 테이블생성, 제약조건(PK, FK)
CREATE TABLE bbs ( --게시판 테이블
    bid NUMBER NOT NULL PRIMARY KEY,
    title VARCHAR2(50) NOT NULL,
    contents VARCHAR2(2000) NOT NULL
);
CREATE TABLE attach(
    aid NUMBER NOT NULL PRIMARY KEY,
    bid NUMBER,
    fname VARCHAR2(30),
    CONSTRAINT fk_bid FOREIGN KEY(bid) REFERENCES bbs (bid)  -- 외래키 지정
);

-- Pagination
// 유사컬럼: 테이블에 없지만 컬럼처럼 사용할 수 있는 내장된 컬럼
// ROWNUM
SELECT * FROM emp2;
SELECT *, ROWNUM AS rn FROM emp2;

// ROWNUM을 사용한 Pagination
SELECT * FROM
(
    SELECT t.*, ROWNUM RN FROM
    (
        SELECT * FROM emp2
    )t
) WHERE RN BETWEEN 10 AND 12;

SELECT SYSDATE "오늘날짜";
SELECT SYSDATE "오늘날짜" FROM DUAL;
SELECT * FROM DUAL;
SELECT 'A' col1,'B' col2,'C' col3 FROM DUAL;
SELECT 5 page, SYSDATE "날짜" FROM DUAL;
SELECT (1/5) "결과" FROM DUAL;
SELECT (2/3) "결과" FROM DUAL;
SELECT TRUNC(5/3) "결과" FROM DUAL;
SELECT (5/3) "결과" FROM DUAL;  -- 1.66666666666666666666666666666666666667
SELECT CEIL(5/3) "결과" FROM DUAL; --2
SELECT FLOOR(5/3) "결과" FROM DUAL;

// 각 행에 대해 소속 페이지 번호를 포함시키기
SELECT * FROM
(
    SELECT t2.*, TRUNC((RN-1)/3+1) AS page FROM
    (
        SELECT t.*, ROWNUM RN FROM
        (
            SELECT * FROM emp2
        )t
    )t2
)
WHERE page=2;

// 특정 페이지가 표시될 때, 현재 페이지 번호와 총 페이지수를 화면에 표시해보세요
SELECT * FROM
(
    SELECT t2.*, TRUNC((RN-1)/3+1) AS page FROM
    (
        SELECT t.*, ROWNUM RN FROM
        (
            SELECT * FROM emp2,(SELECT CEIL(COUNT(*)/3) total FROM emp2)
        )t
    )t2
)
WHERE page=2;

-- 계층구조 커리(Hierarchical Query)
Hello
  ㄴ Reply:Hello
       ㄴ AAAAA 
       
-- START WITH ~ CONNECT BY PRIOR ~연결조건
SELECT empno, ename, deptno, sal, mgr FROM emp2
START WITH mgr IS NULL
CONNECT BY PRIOR empno=mgr;

-- 계층구조 커리에서만 사용가능한 유사컬럼(LEVEL)을 사용하여 시각적인 계층구조 출력
SELECT '   ' || ename ename FROM emp2; 
SELECT LPAD('A', 5, 'a') FROM DUAL;  --A의 왼쪽에 'a'를 붙여서 최대길이가 5가 되게한다
SELECT empno, LPAD(' ', 2*3, ' ') || ename "이름", deptno FROM emp2;

SELECT empno, LPAD('　', (LEVEL-1)*3, '　')||ename ename, deptno, sal, mgr FROM emp2
START WITH mgr IS NULL
CONNECT BY PRIOR empno=mgr
ORDER SIBLINGS BY empno;

SELECT * FROM
(
    SELECT t2.*, TRUNC((RN-1)/3+1) AS page FROM
    (
        SELECT t.*, ROWNUM RN FROM
        (
            SELECT empno, 
            LPAD('　', (LEVEL-1)*3, '　')||ename ename, 
            sal, deptno, job, hiredate
            FROM emp2,
            (
                SELECT CEIL(COUNT(*)/3) total FROM emp2
            ) 
            START WITH mgr IS NULL
            CONNECT BY PRIOR empno=mgr
            ORDER SIBLINGS BY empno
        )t
    )t2
)WHERE page=2;
-- LEVEL

-- Oracle Sequence : 
CREATE SEQUENCE my_seq
       INCREMENT BY 1
       START WITH 1
       MINVALUE 1
       --MAXVALUE 9999
       NOMAXVALUE
       NOCYCLE
       NOCACHE
       NOORDER;
       
-- 시퀀스를 SQL문장에서 사용하는 예
SELECT board_seq.NEXTVAL FROM DUAL;  -- 1
SELECT board_seq.CURRVAL FROM DUAL;  -- 1
-- 게시글번호를 시퀀스로 하는 경우
INSERT INTO board (num, title, contents) VALUES
( board_seq.NEXTVAL, 'sample', 'contents...');

// board(bid,title,contents)
// attch(bid,fnum,fname)

-- 첨부파일번호로 사용될 시퀀스 선언(attach_seq)
// board 테이블에 한행의 데이터를 추가한다(INSERT)
INSERT INTO board VALUES(board_seq.CURRVAL, '첫번째 글', '시퀀스 테스트');
SELECT * FROM board;
// attach 테이블에 현재 게시글의 첨부파일을 2개 저장해보세요.
// 글번호(bid)는 동일하고, 파일번호(fnum)은 서로 달라야 한다
INSERT INTO attach VALUES(board_seq.CURRVAL, attach_seq.NEXTVAL,'sample.txt');
INSERT INTO attach VALUES(board_seq.CURRVAL, attach_seq.NEXTVAL,'sample2.txt');
SELECT * FROM attach;
SELECT * FROM board b INNER JOIN attach a
ON b.bid=a.bid;

-- Java와 DB 연동
-- Java에서 SQL 문장을 오라클에 전달하여 실행하게 하고 그 결과를 Java에서 처리한다
-- Java프로세스에서 Oracle 프로세스에 연결할 수 있는 중간자 역할을 하는 소프트웨어가 필요함
-- JDBC(Java Database Connectivity), JDBC Driver(ojdbc11.jar)
-- 프로젝트에 JDBC 드라이버를 반드시 포함해야만 Java와 DB가 연결된다
