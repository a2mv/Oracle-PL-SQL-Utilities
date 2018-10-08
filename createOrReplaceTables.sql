procedure createOrReplaceTables 
    is 
    cnt number := 0;
    cntD number := 0;
    begin

    -- PARA TABLAS EFACTURA Y EFACTURADESC
    select count(*) into cnt from ALL_TABLES where table_name = 'EFACTURA';
    if cnt > 0 then
        select count(*) into cntD from ALL_TABLES where table_name = 'EFACTURADESC';
        if cntD > 0 then
            EXECUTE IMMEDIATE 'DROP TABLE EFACTURADESC';
        end if;
        EXECUTE IMMEDIATE 'DROP TABLE EFACTURA';
    end if;
    EXECUTE IMMEDIATE 'CREATE TABLE EFACTURA 
    (
        EFAID NUMBER(10) PRIMARY KEY NOT NULL,
        EFAFUE varchar2(4),
        EFADOC varchar2(12),
        EFAFCHDOC Date,
        EFAVERXML Varchar2(6),
        EFAFCHVERXML Date
    )';
    EXECUTE IMMEDIATE 'CREATE TABLE EFACTURADESC 
    (
        EFADID NUMBER(10) PRIMARY KEY NOT NULL,
        EFAID NUMBER(10),
        EFATAG varchar2(60),
        EFAPAR varchar2(60),
        EFAVAL Varchar2(60),
        CONSTRAINT EFACTURADESC_EFACTURA_EFAID_fk FOREIGN KEY (EFAID) REFERENCES EFACTURA (EFAID)
    )';
    EXECUTE IMMEDIATE 'COMMENT ON COLUMN EFACTURADESC.EFATAG IS ''Nombre del TAG''';
    EXECUTE IMMEDIATE 'COMMENT ON COLUMN EFACTURADESC.EFAPAR IS ''Parent (padre) si es diferente de null debe ir el EFATAG del padre''';
    EXECUTE IMMEDIATE 'COMMENT ON COLUMN EFACTURADESC.EFAVAL IS ''value que va en el tag''';
    
    -- SEQUENCIAS
    select count(*) into cnt from ALL_SEQUENCES where sequence_name = 'SEQ_EFACTURA_ID';
    if cnt > 0 then 
        EXECUTE IMMEDIATE 'alter sequence SEQ_EFACTURA_ID INCREMENT by 1 minvalue 0';
    else 
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_EFACTURA_ID
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE';    
    end if;
    select count(*) into cntD from ALL_SEQUENCES where sequence_name = 'SEQ_EFACTURADESC_ID';
    if cntD > 0 then 
        EXECUTE IMMEDIATE 'alter sequence SEQ_EFACTURADESC_ID INCREMENT by 1 minvalue 0';
    else 
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_EFACTURADESC_ID
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE';    
    end if;

    -- TRIGGERS
    select count(*) into cnt from ALL_TRIGGERS where trigger_name ='TRIG_EFACTURA_SEQ';
    if cnt = 0 then
        EXECUTE IMMEDIATE 'CREATE TRIGGER TRIG_EFACTURA_SEQ
        BEFORE INSERT ON EFACTURA
        for each row
        BEGIN
            select SEQ_EFACTURA_ID.nextval into :new.EFAID FROM dual;
        END;'; 
    end if;

    select count(*) into cntd from ALL_TRIGGERS where trigger_name ='TRIG_EFACTURADESC_SEQ';
    if cntD = 0 then
        EXECUTE IMMEDIATE 'CREATE TRIGGER TRIG_EFACTURADESC_SEQ
        BEFORE INSERT ON EFACTURADESC
        for each row
        BEGIN
            select SEQ_EFACTURADESC_ID.nextval into :new.EFADID FROM dual;
        END;'; 
    end if;
    

    exception
        when no_data_found then
        dbms_output.put_line(SQLCODE);

    end createOrReplaceTables;
