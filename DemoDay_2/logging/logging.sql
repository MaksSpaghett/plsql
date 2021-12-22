--Таблица логов
create table LEBEDEV_MA.error_logging(
    id_log number generated by default as identity
    (start with 1 maxvalue 9999999999999999999999999999 minvalue 1 nocycle nocache noorder) primary key,
    log_user varchar2(100) default user,
    log_date date default sysdate,
    object_name varchar2(200),
    log_type varchar2(1000),
    value varchar2(100),
    params varchar2(4000)
)
partition by range (log_date) (
    partition part_first values less than (to_date('24.12.2021 12:00', 'dd.mm.yyyy hh24:mi')),
    partition part_second values less than (to_date('24.01.2022 12:00', 'dd.mm.yyyy hh24:mi')),
    partition part_third values less than (to_date('24.02.2022 12:00', 'dd.mm.yyyy hh24:mi')),
    partition part_max values less than (maxvalue)
);

--Процедура создания лога
create or replace procedure LEBEDEV_MA.add_error_log(
    p_object_name varchar2,
    p_params varchar2,
    p_log_type varchar2 default 'common',
    p_value varchar2 default null
)
as
pragma autonomous_transaction;
begin
    insert into LEBEDEV_MA.error_logging(object_name, log_type, value , params)
    values (p_object_name, p_log_type, p_value, p_params);
    commit;
    DBMS_OUTPUT.PUT_LINE('Было выброшено исключение, см. логи');
end;

--Вставление новой секции
alter table LEBEDEV_MA.error_logging
split partition part_max at (to_date('24.03.2022 12:00', 'dd.mm.yyyy hh24:mi'))
into (partition part_fourth, partition part_max);

--Пересборка индекса
alter index LEBEDEV_MA.SYS_C0029057 rebuild;

--Удаление таблицы со всеми секциями
drop table LEBEDEV_MA.error_logging purge;
