--**Создать метод записи с проверками пациента
-- на соответствие всем пунктам для записи

--Пациент ещё не записан на этот талон
create or replace procedure LEBEDEV_MA.check_appointment(
    p_id_patient number,
    p_id_talon number
)
as
    v_count int;
    e_exception exception;
    pragma exception_init(e_exception, -20001);
begin
    select count(*)
    into v_count
    from LEBEDEV_MA.JOURNAL jr
    where jr.ID_PATIENT = p_id_patient
      and jr.ID_TALON = p_id_talon
      and jr.ID_STATUS = LEBEDEV_MA.PKG_JOURNAL.C_JOURNAL_CONFIRMED;
    if (v_count != 0) then
        raise_application_error(-20001, 'Пациент уже записан на этот талон');
    end if;
end;

--Совпадение пола пациента с полом специальности
create or replace function LEBEDEV_MA.check_gender_compatibility(
    p_id_patient number,
    p_id_talon number
)
return boolean
as
    v_count int;
begin
    select count(*)
        into v_count
        from
            LEBEDEV_MA.PATIENTS p
            join LEBEDEV_MA.GENDER gend on p.ID_GENDER = gend.ID_GENDER
            join LEBEDEV_MA.REQUIRED_GENDER reqGen on gend.ID_GENDER = reqGen.ID_GENDER
            join LEBEDEV_MA.SPECIALITY spec on reqGen.ID_SPECIALITY = spec.ID_SPECIALITY
            join LEBEDEV_MA.DOCTORS doc on spec.ID_SPECIALITY = doc.ID_SPECIALITY
            join LEBEDEV_MA.TALON tal on doc.ID_DOCTOR = tal.ID_DOCTOR
        where
              tal.ID_TALON = p_id_talon and p.ID_PATIENT = p_id_patient and
              (p.ID_GENDER = reqGen.ID_GENDER);
    if (v_count != 0) then
        return true;
    else
        return false;
    end if;
end;

--Попадание по возрасту пациента в возрастной диапазон специальности
create or replace function LEBEDEV_MA.check_age_compatibility(
    p_id_patient number,
    p_id_talon number
)
return boolean
as
    v_count int;
begin
    select count(*)
    into v_count
    from
         LEBEDEV_MA.PATIENTS p
         join LEBEDEV_MA.GENDER gend on p.ID_GENDER = gend.ID_GENDER
         join LEBEDEV_MA.REQUIRED_GENDER reqGen on gend.ID_GENDER = reqGen.ID_GENDER
         join LEBEDEV_MA.SPECIALITY spec on reqGen.ID_SPECIALITY = spec.ID_SPECIALITY
         join LEBEDEV_MA.REQUIRED_AGE reqAge on spec.ID_AGE_REQUIRED = reqAge.ID_REQUIRED_AGE
         join LEBEDEV_MA.DOCTORS doc on spec.ID_SPECIALITY = doc.ID_SPECIALITY
         join LEBEDEV_MA.TALON tal on doc.ID_DOCTOR = tal.ID_DOCTOR
    where
          tal.ID_TALON = p_id_talon and p.ID_PATIENT = p_id_patient and
          (sysdate - p.DATEOFBIRTH) > reqAge.START_INTERVAL and
          (sysdate - p.DATEOFBIRTH) < reqAge.END_INTERVAL;
    if (v_count != 0) then
        return true;
    else
        return false;
    end if;
end;

--Талон на который записываются должен быть открыт
create or replace function LEBEDEV_MA.check_talon_is_opened(
    p_id_talon number
)
return boolean
as
    v_count int;
begin
    select count(*)
    into v_count
    from LEBEDEV_MA.TALON tal
    where tal.ID_TALON = p_id_talon and tal.ISOPEN = 0;
    if (v_count != 0) then
        return true;
    else
        return false;
    end if;
end;

--Время начала талона на который записываются не должен быть больше текущего времени
create or replace function LEBEDEV_MA.check_talon_time(
    p_id_talon number
)
return boolean
as
    v_count int;
begin
    select count(*)
    into v_count
    from LEBEDEV_MA.TALON tal
    where
          tal.ID_TALON = p_id_talon and
          tal.STARTDATE <= sysdate;
    if (v_count != 0) then
        return true;
    else
        return false;
    end if;
end;

--Получение id доктора
create or replace function LEBEDEV_MA.get_doctor_id(
    p_id_talon number
)
return boolean
as
    v_id int default -1;
begin
    select doc.ID_DOCTOR
    into v_id
    from
         LEBEDEV_MA.TALON tal
         join LEBEDEV_MA.DOCTORS doc on tal.ID_DOCTOR = doc.ID_DOCTOR
    where
          tal.ID_TALON = p_id_talon and
          doc.DELETED is null;
    if (v_id = -1) then
        return true;
    else
        return false;
    end if;
end;

--Наличие у пациента ОМС
create or replace function LEBEDEV_MA.check_OMS(
    p_id_patient number
)
return boolean
as
    v_count int;
begin
    select count(*)
    into v_count
    from
         LEBEDEV_MA.PATIENTS pat
         join LEBEDEV_MA.DOCUMENTS_NUMBERS docNum on pat.ID_PATIENT = docNum.ID_PATIENT
         join LEBEDEV_MA.DOCUMENT doc on docNum.ID_DOCUMENT = doc.ID_DOCUMENT
    where
          pat.ID_PATIENT = p_id_patient and
          doc.NAME = 'ОМС';
    if (v_count = 0) then
        return true;
    else
        return false;
    end if;
end;

--Проверка условий
create or replace procedure LEBEDEV_MA.sign_up_for_a_talon(
    p_id_talon number,
    p_id_patient number
)
as
    v_signUp_status varchar2(5000) := '';
    v_error_status boolean := false;
begin
    --Пациент ещё не записан на этот талон
    LEBEDEV_MA.check_appointment(p_id_patient => p_id_patient, p_id_talon => p_id_talon);

    --Совпадение пола пациента с полом специальности
    if (LEBEDEV_MA.check_gender_compatibility(p_id_patient => p_id_patient, p_id_talon => p_id_talon)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Пол пациента не совпадает с полом специальности';
    end if;

    --Попадание по возрасту пациента в возрастной диапазон специальности
    if (LEBEDEV_MA.check_age_compatibility(p_id_patient => p_id_patient, p_id_talon => p_id_talon)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Возраст пациента не попадает в возрастной диапазон специальности';
    end if;

    --Талон на который записываются должен быть открыт
    if (LEBEDEV_MA.check_talon_is_opened(p_id_talon => p_id_talon)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Талон закрыт для записи';
    end if;

    --Время начала талона на который записываются не должен быть больше текущего времени
    if (LEBEDEV_MA.check_talon_time(p_id_talon => p_id_talon)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Время талона уже начато, запись на него невозможна';
    end if;

    --Получение id доктора
    if (LEBEDEV_MA.get_doctor_id(p_id_talon => p_id_talon)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Запись к данному доктору невозможна';
    end if;

    --Наличие у пациента ОМС
    if (LEBEDEV_MA.check_OMS(p_id_patient => p_id_patient)) then
        v_error_status := true;
        v_signUp_status := v_signUp_status || chr(10)
            || 'Нет полиса ОМС';
    end if;

    --Запись если ошибок нет
    if (not v_error_status) then
        LEBEDEV_MA.PKG_TALON.REGISTRATION_FOR_THE_TALON(p_id_patient => p_id_patient, p_id_talon => p_id_talon);
        v_signUp_status := 'Запись произведена успешно';
    else
        v_signUp_status := 'Не удалось произвести запись:' || chr(10)
            || v_signUp_status;
    end if;

    DBMS_OUTPUT.PUT_LINE(v_signUp_status);

exception
    when others then
        begin
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            --rollback, если все процедуры будут сделаны с выбросом исключения
            LEBEDEV_MA.add_error_log( 'LEBEDEV_MA.sign_up_for_a_talon',
                       '{"error":"' || sqlerrm
                        ||'","backtrace":"' || dbms_utility.format_error_backtrace()
                        ||'"}');
        end;
end;

--Основная часть
declare
    v_id_talon number;
    v_id_patient number;
begin
    DBMS_OUTPUT.ENABLE();
    select p.ID_Patient into v_id_patient from LEBEDEV_MA.PATIENTS p where p.SURNAME = 'Логвенков';
    v_id_talon := 6;
    LEBEDEV_MA.sign_up_for_a_talon(p_id_talon => v_id_talon, p_id_patient => v_id_patient);
end;

--ВЫВОД
--Процедура check_appointment была сделана с выбросом исключения.
--С одной стороны процедуру sign_up_for_a_talon можно сделать компактнее, если всё оформить через исключения, но
--при выбрасывании исключений вместо возврата boolean возникли сложности с выводом информации в консоль о том,
--какая именно проверка не прошла, для каждой функции нужно создавать отдельное исключение, чтобы
--выводить соответствующее сообщение, что излишне "раздувает" программу, а также
--логгирование пользовательских ошибок при записи на талон считаю ненужным, исходя из всего этого делаю вывод, что
--выбрасывание исключений в этом случае - нецелесобразно.