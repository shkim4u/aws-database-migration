## DMS 및 SCT를 위한 Oracle 데이터베이스 사용자 생성

* ```애플리케이션 서버 (OnPremAppServer-DMSWorkshop-Source)```에 AWS 콘솔의 ```Session Manager```로 접속합니다.

    ![Session Manager 애플리케이션 접속](../../images/session-manager-connected.png)

* ```Oracle``` 데이터베이스 컨테이너 내로 직접 접속합니다.

    ```bash
    bash
    
    ORACLE_CONTAINER_ID=`docker ps --filter "ancestor=shkim4u/oracle:11.2.0.2-xe" --format "{{.ID}}"`
    echo "Oracle Container ID: $ORACLE_CONTAINER_ID" 
    docker exec -it $ORACLE_CONTAINER_ID /bin/bash
    ```

    ![Oracle 컨테이너 접속](../../images/oracle-container-connected.png)

* ```oracle``` 유저로 전환합니다 (su - oracle).

    ```bash
    su oracle
    ```

* ```sqlplus / as sysdba```로 데이터베이스에 접속합니다.

    ```bash
    sqlplus / as sysdba
    ```

    ![Oracle 데이터베이스 접속](../../images/oracle-database-connected.png)


* ```AWS SCT```및 ```DMS```를 위한 공통 오라클 사용자(```DMSUSER```)를 생성하고 권한을 부여합니다.

    ```sql
    -- 사용자 생성
    CREATE USER DMSUSER IDENTIFIED BY dmsuser123;
    
    -- 권한 부여
    GRANT CREATE SESSION to DMSUSER;
    GRANT SELECT ANY TABLE to DMSUSER;
    GRANT SELECT ANY TRANSACTION to DMSUSER;
    GRANT SELECT ANY DICTIONARY to DMSUSER;
    GRANT SELECT on DBA_TABLESPACES to DMSUSER;
    
    --- DMS Target에 대한 권한 부여
    --- See: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.Oracle.html
    GRANT SELECT on V_$NLS_PARAMETERS to DMSUSER;
    GRANT SELECT on V_$TIMEZONE_NAMES to DMSUSER;
    GRANT SELECT on ALL_INDEXES to DMSUSER;
    GRANT SELECT on ALL_OBJECTS to DMSUSER;
    GRANT SELECT on DBA_OBJECTS to DMSUSER;
    GRANT SELECT on ALL_TABLES to DMSUSER;
    GRANT SELECT on ALL_USERS to DMSUSER;
    GRANT SELECT on ALL_CATALOG to DMSUSER;
    GRANT SELECT on ALL_CONSTRAINTS to DMSUSER;
    GRANT SELECT on ALL_CONS_COLUMNS to DMSUSER;
    GRANT SELECT on ALL_TAB_COLS to DMSUSER;
    GRANT SELECT on ALL_IND_COLUMNS to DMSUSER;
    GRANT DROP ANY TABLE to DMSUSER;
    GRANT INSERT ANY TABLE to DMSUSER;
    GRANT UPDATE ANY TABLE to DMSUSER;
    GRANT CREATE ANY VIEW to DMSUSER;
    GRANT DROP ANY VIEW to DMSUSER;
    GRANT CREATE ANY PROCEDURE to DMSUSER;
    GRANT ALTER ANY PROCEDURE to DMSUSER;
    GRANT DROP ANY PROCEDURE to DMSUSER;
    GRANT CREATE ANY SEQUENCE to DMSUSER;
    GRANT ALTER ANY SEQUENCE to DMSUSER;
    GRANT DROP ANY SEQUENCE to DMSUSER;
    GRANT DELETE ANY TABLE to DMSUSER;
    
    GRANT SELECT on DBA_USERS to DMSUSER;
    GRANT SELECT on DBA_TAB_PRIVS to DMSUSER;
    GRANT SELECT on DBA_OBJECTS to DMSUSER;
    GRANT SELECT on DBA_SYNONYMS to DMSUSER;
    GRANT SELECT on DBA_SEQUENCES to DMSUSER;
    GRANT SELECT on DBA_TYPES to DMSUSER;
    GRANT SELECT on DBA_INDEXES to DMSUSER;
    GRANT SELECT on DBA_TABLES to DMSUSER;
    GRANT SELECT on DBA_TRIGGERS to DMSUSER;
    GRANT SELECT on SYS.DBA_REGISTRY to DMSUSER;
    
    --- DMS Assessment 보고서에서 보고한 권한
    GRANT ALTER ANY TABLE to DMSUSER;
    GRANT CREATE ANY INDEX to DMSUSER;
    GRANT CREATE ANY TABLE to DMSUSER;
    GRANT LOCK ANY TABLE to DMSUSER;
    GRANT SELECT ON SYS.DBA_INDEXES to DMSUSER;
    GRANT SELECT ON SYS.DBA_REGISTRY to DMSUSER;
    GRANT SELECT ON SYS.DBA_SEQUENCES to DMSUSER;
    GRANT SELECT ON SYS.DBA_SYNONYMS to DMSUSER;
    GRANT SELECT ON SYS.DBA_TABLES to DMSUSER;
    GRANT SELECT ON SYS.DBA_TAB_PRIVS to DMSUSER;
    GRANT SELECT ON SYS.DBA_TRIGGERS to DMSUSER;
    GRANT SELECT ON SYS.DBA_TYPES to DMSUSER;
    GRANT SELECT ON SYS.DBA_USERS to DMSUSER;
    GRANT UNLIMITED TABLESPACE to DMSUSER;
    GRANT EXECUTE ON SYS.DBMS_CRYPTO to DMSUSER;
    
    -- DMS Preassessment를 위한 권한 부여
    GRANT SELECT ON V_$INSTANCE TO DMSUSER;
    ```

    ![Oracle DMSUSER 생성 및 권한 부여](../../images/oracle-dmsuser-created.png)

---

## References
* [Configure DMS user with all required permissions on targets. Please refer the document for more information](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.Oracle.html#CHAP_Target.Oracle.Privileges)
