create table LEBEDEV_MA.regions(
    ID_Region number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Name varchar2(100) not null
);
create table LEBEDEV_MA.cities(
    ID_City number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_region number references LEBEDEV_MA.regions(ID_Region) not null,
    Name nvarchar2(100) not null
);
create table LEBEDEV_MA.med_organisations(
    ID_Med_Organisation number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_city number references LEBEDEV_MA.cities(ID_City) not null,
    Name varchar2(999) not null
);
create table LEBEDEV_MA.type(
    ID_Type number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Name varchar2(25) not null
);
create table LEBEDEV_MA.hospitals(
    ID_Hospital number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_MedOrgan number references LEBEDEV_MA.med_organisations(ID_Med_Organisation) not null,
    IsAvailable number not null,
    id_Type number references LEBEDEV_MA.type(ID_Type) not null,
    Deleted date
);
create table LEBEDEV_MA.schedule(
    ID_Schedule number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Hospital number references LEBEDEV_MA.hospitals(ID_Hospital) not null,
    DayOfWeek varchar2(11) not null,
    Start_Work date not null,
    End_Work date not null
);
create table LEBEDEV_MA.gender(
    ID_Gender number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Name varchar2(20) not null
);
create table LEBEDEV_MA.Required_Age(
    ID_Required_Age number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Start_Interval number not null,
    End_Interval number
);
create table LEBEDEV_MA.speciality(
    ID_Speciality number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Name varchar2(50) not null,
    id_Age_Required number references LEBEDEV_MA.Required_Age(ID_Required_Age) not null,
    Deleted date
);
create table LEBEDEV_MA.Required_Gender(
    ID_Required_Gender number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    ID_Speciality number references LEBEDEV_MA.speciality(ID_Speciality) not null,
    ID_Gender number references LEBEDEV_MA.gender(ID_Gender) not null
);
create table LEBEDEV_MA.Education(
    ID_Education number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Education varchar2(50)
);
create table LEBEDEV_MA.Qualification(
    ID_Qualification number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Qualification varchar2(6)
);
create table LEBEDEV_MA.doctors(
    ID_Doctor number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Hospital number references LEBEDEV_MA.hospitals(ID_Hospital) not null,
    Surname varchar2(100) not null,
    Name varchar2(100) not null,
    Patronymic varchar2(100),
    id_Gender number references LEBEDEV_MA.gender(ID_Gender) not null,
    id_Speciality number references LEBEDEV_MA.speciality(ID_Speciality) not null,
    id_Qualification number references LEBEDEV_MA.Qualification(ID_Qualification) not null,
    Salary number not null,
    Rating number not null,
    Area varchar2(10) not null,
    Deleted date
);
create table LEBEDEV_MA.Reviews(
    ID_Review number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Doctor number references LEBEDEV_MA.doctors(ID_Doctor) not null,
    Review varchar2(500) not null
);
create table LEBEDEV_MA.Doctors_Educations(
    ID_Doctors_Educations number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    ID_Doctors number references LEBEDEV_MA.doctors(ID_Doctor) not null,
    ID_Education number references LEBEDEV_MA.Education(ID_Education) not null
);
create table LEBEDEV_MA.Hospital_Speciality(
    id_Speciality number references LEBEDEV_MA.speciality(ID_Speciality),
    id_Hospital number references  LEBEDEV_MA.hospitals(ID_Hospital)
);
create table LEBEDEV_MA.account(
    ID_Account number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Login varchar2(50) not null,
    Password varchar2(50) not null
);
create table LEBEDEV_MA.patients(
    ID_Patient number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Surname varchar2(100) not null,
    Name varchar2(100) not null,
    Patronymic varchar2(100),
    DateOfBirth date not null,
    id_Gender number references LEBEDEV_MA.gender(ID_Gender) not null,
    PhoneNumber varchar2(11),
    Area varchar2(10) not null,
    id_Account number references LEBEDEV_MA.account(ID_Account) not null
);
create table LEBEDEV_MA.document(
    ID_Document number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Name varchar2(15) not null
);
create table LEBEDEV_MA.Documents_Numbers(
    ID_Document_Number number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Patient number references LEBEDEV_MA.patients(ID_Patient) not null,
    id_Document number references LEBEDEV_MA.document(ID_Document) not null,
    Value varchar2(50) not null
);
create table LEBEDEV_MA.talon(
    ID_Talon number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Doctor number references LEBEDEV_MA.doctors(ID_Doctor) not null,
    IsOpen number not null,
    StartDate date not null,
    EndDate date not null
);
create table LEBEDEV_MA.status(
    ID_Status number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    Status_Name varchar2(12) not null
);
create table LEBEDEV_MA.journal(
    ID_Journal number generated by default as identity
        (start with 1 maxvalue 999999999 minvalue 1 nocycle nocache noorder) primary key,
    id_Patient number references LEBEDEV_MA.patients(ID_Patient) not null,
    Id_Talon number references LEBEDEV_MA.talon(ID_Talon) not null,
    id_Status number references LEBEDEV_MA.status(ID_Status) not null
);