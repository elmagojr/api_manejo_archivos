/*#####################HUELLAS###########################################################################*/

CREATE TABLE "DBA"."HUELLAS_FIGERS" (
	"HUE_ID" INTEGER NOT NULL DEFAULT AUTOINCREMENT,
	"HUE_CODIGO" VARCHAR(50) NULL,
	"HUE_IDENTIDAD" VARCHAR(50) NOT NULL,
	"HUE_TIPO_PER" VARCHAR(50) NOT NULL,
	"HUELLA" LONG BINARY NOT NULL UNIQUE,
	"FECHA_CREACION" "datetime" NULL DEFAULT CURRENT TIMESTAMP,
	"HUE_COMPANIA" INTEGER NULL,
	"HUE_FILIAL" INTEGER NULL,
	"HUE_OBSERVACION" VARCHAR(200) NOT NULL,
	"FLAG" INTEGER NULL DEFAULT 0,
	"DEDO" VARCHAR(20) NULL,
	"HUELLA_SAMPLE" LONG BINARY NULL,
	"USR_AGREGO" VARCHAR(100) NULL,
	PRIMARY KEY ( "HUE_ID" ASC, "HUELLA" ASC, "HUE_IDENTIDAD" ASC )
) IN "system";
COMMENT ON TABLE "DBA"."HUELLAS_FIGERS" IS 'TABLA DONDE SE REGISTRAN LAS HUELLAS DIGITALES DE LAS PERSONAS';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUE_ID" IS 'identificador unico';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUE_CODIGO" IS 'si HUE_TIPO_PER  es  Coop, guarda el codigo afiliado; si es DEF el secuencial del def con que se registro la huella ';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUE_IDENTIDAD" IS 'idenditidad de la persona';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUE_TIPO_PER" IS 'tipo de persona COOP para cooperativista y DEF para los registrados en la tabla detalles_firma';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUELLA" IS 'guarda la cadena hexadeciamal de la huella';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUE_OBSERVACION" IS 'observacion a la hora de registrar la huella';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."FLAG" IS 'al hacer una verificacion de esta huella se coloca en 1, el addon tomara el valor en 1 para validar la huella';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."DEDO" IS 'identificador de que dedo es: mano derecha DD y DI la izquierda (1 pulgar 5 meñique, en suscecion)  ';
COMMENT ON COLUMN "DBA"."HUELLAS_FIGERS"."HUELLA_SAMPLE" IS 'guarda la imagen de la huella en jpeg en resolucion 80x80 pixeles';


CREATE TRIGGER "trg_tablas_parame" AFTER UPDATE
ORDER 1 ON "DBA"."HUELLAS_FIGERS"
REFERENCING OLD AS old_name NEW AS new_name
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
        declare Campo VARCHAR(100);
        declare Query VARCHAR(1000);
        declare Valor_Anterior VARCHAR(255);
        declare Valor_Nuevo VARCHAR(255);
        declare ExisteCampo integer;
        
        select count(column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'HUELLAS_FIGERS'); 
       -- SELECT COUNT(*) INTO ExisteCampo FROM DBA.TABLAS_PARAMETRIZADAS WHERE TP_COMPANIA = new_name.HUE_COMPANIA AND TP_TABLA = 'HUELLAS_FIGERS' AND TP_ESTADO=1; 
        
        if(ExisteCampo>0) then
        begin
            declare Inserta_Bitacora dynamic scroll cursor for
            select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'HUELLAS_FIGERS');
            --SELECT TP_CAMPO INTO Campo FROM DBA.TABLAS_PARAMETRIZADAS WHERE TP_COMPANIA = new_name.HUE_COMPANIA AND TP_TABLA = 'HUELLAS_FIGERS' AND TP_ESTADO=1;  
            open Inserta_Bitacora;
            fetch next Inserta_Bitacora into Campo;
        
            if(@@sqlstatus = 2) then
              print "No se encontró ningun Registro";
              close Inserta_Bitacora;
              return
            end if;
        
            while(@@sqlstatus = 0) loop
          
            SET Query = 'SELECT old_name.' + Trim(Campo) +',new_name.' + Trim(Campo) + ' INTO Valor_Anterior,Valor_Nuevo FROM DUMMY';
            EXECUTE IMMEDIATE Query;
        
            IF(Trim(Valor_Anterior) <> Trim(Valor_Nuevo)) THEN
               insert into DBA.HISTO_TABLAS ("HT_TABLA","HT_CAMPO_PK","HT_VALOR_PK","HT_CAMPO_AFECTADO","HT_VALOR_ANTERIOR","HT_VALOR_NUEVO") 
               values('HUELLAS_FIGERS', 'HUE_ID', new_name.HUE_ID,Campo,Valor_Anterior,Valor_Nuevo) 
            END IF;
        
               fetch next Inserta_Bitacora into Campo;
               end loop;
               close Inserta_Bitacora;      
            end;
         
            
        end if; 
END;
/*#####################ROLES DE USUARIO DE HUELLA###########################################################################*/
CREATE TABLE "DBA"."ROL_HUELLA" (
	"ID_ROLHUE" INTEGER NOT NULL DEFAULT AUTOINCREMENT,
	"NOMBRE_ROLHUE" VARCHAR(50) NOT NULL UNIQUE,
	"PERMISOS_ROLHUE" VARCHAR(512) NULL,
	"USR_AGREGO_ROLHUE" VARCHAR(50) NULL,
	"FECHA_CREA_ROLHUE" "datetime" NULL DEFAULT CURRENT TIMESTAMP,
	"FECHA_MODI_ROLHUE" "datetime" NULL,
	"USR_MODI_ROLHUE" VARCHAR(50) NULL,
	PRIMARY KEY ( "ID_ROLHUE" ASC )
) IN "system";
COMMENT ON TABLE "DBA"."ROL_HUELLA" IS 'PERMISOS PARA LA HUELLA DIGITAL';
COMMENT ON COLUMN "DBA"."ROL_HUELLA"."NOMBRE_ROLHUE" IS 'nombre del rol';
COMMENT ON COLUMN "DBA"."ROL_HUELLA"."PERMISOS_ROLHUE" IS 'permisos asingandos a este rol mediante token';


CREATE TRIGGER "TGR_INSERTED" before INSERT
ORDER 1 ON "DBA"."ROL_HUELLA"
 REFERENCING NEW AS new_name 
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
	declare Campo VARCHAR(100);
declare Query VARCHAR(1000);
declare Valor_Anterior VARCHAR(800);
declare Valor_Nuevo VARCHAR(800);
declare ExisteCampo integer;
declare observacion VARCHAR(800);

select count(column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA'); 

if(ExisteCampo>0) then
    begin
        declare Inserta_Bitacora dynamic scroll cursor for
        select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA');
        open Inserta_Bitacora;
        fetch next Inserta_Bitacora into Campo;
    
        if(@@sqlstatus = 2) then
          print "No se encontró ningun Registro";
          close Inserta_Bitacora;
          return
        end if;
    
        while(@@sqlstatus = 0) loop
        
      SET Query = 'SELECT new_name.' + Trim(Campo) + ' INTO Valor_Nuevo FROM DUMMY';
        EXECUTE IMMEDIATE Query;

        IF (Campo in ('ID_ROLHUE','NOMBRE_ROLHUE','PERMISOS_ROLHUE')) THEN 
                if  Campo = 'PERMISOS_ROLHUE' THEN   
                       set observacion ='Nuevo rol';                 
                      set Valor_Nuevo = '(NEW_DATA)';
                ELSE    
                        set observacion =''; 
                end if;            

                INSERT INTO "DBA"."HISTO_HUELLAS" ("HISTO_TABLA","HISTO_IDENTIFICADOR","HISTO_CAMPO","HISTO_VANTERIOR","HISTO_VACTUAL","HISTO_ACCION","HISTO_USR_ACCION","HISTO_FECHA_ACCION","HISTO_INFO_ADICIONAL","HISTO_OBSERVACION")
                VALUES('ROL_HUELLA',new_name.ID_ROLHUE, Campo,NULL,Valor_Nuevo,'I',current user,CURRENT TIMESTAMP ,(SELECT "DBA"."func_trae_info_sys"(3)),observacion);
        end if;

         fetch next Inserta_Bitacora into Campo;
           end loop;
           close Inserta_Bitacora;      
        end;
 
    
end if; 
END;
COMMENT ON TRIGGER "DBA"."ROL_HUELLA"."TGR_INSERTED" IS 'PARA EL INSERT';


CREATE TRIGGER "TGR_ONDELETE" BEFORE DELETE
ORDER 1 ON "DBA"."ROL_HUELLA"
 REFERENCING OLD AS old_name 
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN

declare Campo VARCHAR(100);
declare Query VARCHAR(1000);
declare Valor_Anterior VARCHAR(800);
declare Valor_Nuevo VARCHAR(800);
declare ExisteCampo integer;
per
select count( column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA'); 

if(ExisteCampo>0) then
    begin
        declare Inserta_Bitacora dynamic scroll cursor for
        select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA');
        open Inserta_Bitacora;
        fetch next Inserta_Bitacora into Campo;
    
        if(@@sqlstatus = 2) then
          print "No se encontró ningun Registro";
          close Inserta_Bitacora;
          return
        end if;
    
        while(@@sqlstatus = 0) loop
        
        SET Query = 'SELECT old_name.' + Trim(Campo) +' INTO Valor_Anterior FROM DUMMY';
        EXECUTE IMMEDIATE Query;
        IF (Campo in ('ID_ROLHUE','NOMBRE_ROLHUE')) THEN 
                IF Campo ='ID_ROLHUE' THEN  
                    DELETE FROM DBA.USUARIOS_HUELLAS WHERE ID_ROLUSR=Valor_Anterior;
                END IF;
                INSERT INTO "DBA"."HISTO_HUELLAS" ("HISTO_TABLA","HISTO_IDENTIFICADOR","HISTO_CAMPO","HISTO_VANTERIOR","HISTO_VACTUAL","HISTO_ACCION","HISTO_USR_ACCION","HISTO_FECHA_ACCION","HISTO_INFO_ADICIONAL","HISTO_OBSERVACION")
                VALUES('ROL_HUELLA',old_name.ID_ROLHUE,Campo,Valor_Anterior,NULL,'D',current user,CURRENT TIMESTAMP ,(SELECT "DBA"."func_trae_info_sys"(3)),'Motivo: Gestion de roles, Eliminacion de rol');
            end if;
         fetch next Inserta_Bitacora into Campo;
           end loop;
           close Inserta_Bitacora;      
        end;
 
    
end if; 

END;
COMMENT ON TRIGGER "DBA"."ROL_HUELLA"."TGR_ONDELETE" IS 'AL ELIMNAR UN ROL';


CREATE TRIGGER "TRG_ONUPDATE" AFTER UPDATE 
ORDER 1 ON "DBA"."ROL_HUELLA"
REFERENCING OLD AS old_name NEW AS new_name
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN

declare Campo VARCHAR(100);
declare Query VARCHAR(1000);
declare Valor_Anterior VARCHAR(800);
declare Valor_Nuevo VARCHAR(800);
declare ExisteCampo integer;
declare observacion VARCHAR(800);

select count(column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA'); 

if(ExisteCampo>0) then
    begin
        declare Inserta_Bitacora dynamic scroll cursor for
        select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'ROL_HUELLA');
        open Inserta_Bitacora;
        fetch next Inserta_Bitacora into Campo;
    
        if(@@sqlstatus = 2) then
          print "No se encontrÃ³ ningun Registro";
          close Inserta_Bitacora;
          return
        end if;
    
        while(@@sqlstatus = 0) loop
        
      SET Query = 'SELECT old_name.' + Trim(Campo) +',new_name.' + Trim(Campo) + ' INTO Valor_Anterior,Valor_Nuevo FROM DUMMY';
        EXECUTE IMMEDIATE Query;
    IF(Trim(Valor_Anterior) <> Trim(Valor_Nuevo)) THEN
        IF (Campo in ('ID_ROLHUE','NOMBRE_ROLHUE','PERMISOS_ROLHUE')) THEN 
                if  Campo = 'PERMISOS_ROLHUE' THEN   
                       set observacion ='Se modificaron los permisos del rol';
                       SET Valor_Anterior = '(NO_DATA)'; 
                       SET Valor_Nuevo = '(NO_DATA)';  
                ELSE    
                        set observacion =''; 
                end if;
            

                INSERT INTO "DBA"."HISTO_HUELLAS" ("HISTO_TABLA","HISTO_IDENTIFICADOR","HISTO_CAMPO","HISTO_VANTERIOR","HISTO_VACTUAL","HISTO_ACCION","HISTO_USR_ACCION","HISTO_FECHA_ACCION","HISTO_INFO_ADICIONAL","HISTO_OBSERVACION")
                VALUES('ROL_HUELLA',old_name.ID_ROLHUE,Campo,Valor_Anterior,Valor_Nuevo,'U',current user,CURRENT TIMESTAMP ,(SELECT "DBA"."func_trae_info_sys"(3)),observacion);
        end if;
    END IF;
         fetch next Inserta_Bitacora into Campo;
           end loop;
           close Inserta_Bitacora;      
        end;
 
    
end if; 
	/* Type the trigger statements here */
END;
COMMENT ON TRIGGER "DBA"."ROL_HUELLA"."TRG_ONUPDATE" IS 'PARA UPDATE';

/*##################### USUARIO DE HUELLA###########################################################################*/
CREATE TABLE "DBA"."USUARIOS_HUELLAS" (
	"ID_USR" INTEGER NOT NULL DEFAULT AUTOINCREMENT,
	"ID_ROLUSR" INTEGER NOT NULL,
	"NOMBRE_USR" VARCHAR(50) NOT NULL,
	"FECHA_CREADO_USR" "datetime" NULL DEFAULT CURRENT TIMESTAMP,
	"FECHA_MODIFICADO_USR" "datetime" NULL,
	"TOKEN_ID" VARCHAR(512) NULL,
	"USR_CREADO_USR" VARCHAR(50) NULL,
	"USR_MODI_USR" VARCHAR(50) NULL,
	PRIMARY KEY ( "ID_USR" ASC )
) IN "system";
COMMENT ON TABLE "DBA"."USUARIOS_HUELLAS" IS 'USUARIOS PARA LA HUELLA';
COMMENT ON COLUMN "DBA"."USUARIOS_HUELLAS"."ID_ROLUSR" IS 'rol del usr asignado a este usuario ';
COMMENT ON COLUMN "DBA"."USUARIOS_HUELLAS"."NOMBRE_USR" IS 'nombre del usuario ';
COMMENT ON COLUMN "DBA"."USUARIOS_HUELLAS"."TOKEN_ID" IS 'token que valida que los permisos y el acceso al add on';


CREATE TRIGGER "TRG_DELETE_USR" BEFORE DELETE
ORDER 1 ON "DBA"."USUARIOS_HUELLAS"
 REFERENCING OLD AS old_name 
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
        declare Campo VARCHAR(100);
        declare Query VARCHAR(1000);
        declare Valor_Anterior VARCHAR(800);
        declare Valor_Nuevo VARCHAR(800);
        declare ExisteCampo integer;
        
        select count( column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'USUARIOS_HUELLAS'); 
        
        if(ExisteCampo>0) then
            begin
                declare Inserta_Bitacora dynamic scroll cursor for
                select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'USUARIOS_HUELLAS');
                open Inserta_Bitacora;
                fetch next Inserta_Bitacora into Campo;
            
                if(@@sqlstatus = 2) then
                  print "No se encontró ningun Registro";
                  close Inserta_Bitacora;
                  return
                end if;
            
                while(@@sqlstatus = 0) loop
                
                SET Query = 'SELECT old_name.' + Trim(Campo) +' INTO Valor_Anterior FROM DUMMY';
                EXECUTE IMMEDIATE Query;
                IF (Campo in ('ID_USR','NOMBRE_USR')) THEN 
                        INSERT INTO "DBA"."HISTO_HUELLAS" ("HISTO_TABLA","HISTO_IDENTIFICADOR","HISTO_CAMPO","HISTO_VANTERIOR","HISTO_VACTUAL","HISTO_ACCION","HISTO_USR_ACCION","HISTO_FECHA_ACCION","HISTO_INFO_ADICIONAL","HISTO_OBSERVACION")
                        VALUES('USUARIOS_HUELLAS',old_name.ID_USR,Campo,Valor_Anterior,'(NO_DATA)','D',current user,CURRENT TIMESTAMP ,(SELECT "DBA"."func_trae_info_sys"(3)),'Motivo: Gestion de  USUARIOS HUELLA, Quitar rol');
                    end if;
                 fetch next Inserta_Bitacora into Campo;
                   end loop;
                   close Inserta_Bitacora;      
                end;
         
            
        end if; 
END;
COMMENT ON TRIGGER "DBA"."USUARIOS_HUELLAS"."TRG_DELETE_USR" IS 'PARA QUITAR ROL DE UN USUARIO DE HUELLA';


CREATE TRIGGER "TRG_UPDATE_USR" AFTER UPDATE
ORDER 1 ON "DBA"."USUARIOS_HUELLAS"
 REFERENCING OLD AS old_name NEW AS new_name 
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
    declare Campo VARCHAR(100);
    declare Query VARCHAR(1000);
    declare Valor_Anterior VARCHAR(800);
    declare Valor_Nuevo VARCHAR(800);
    declare ExisteCampo integer;
    declare observacion VARCHAR(800);
    
    select count(column_name) INTO ExisteCampo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'USUARIOS_HUELLAS'); 
        
    if(ExisteCampo>0) then
        begin
            declare Inserta_Bitacora dynamic scroll cursor for
            select column_name INTO Campo from sys.SYSCOLUMN where table_id=(SELECT table_id FROM SYS.SYSTABLE WHERE table_name = 'USUARIOS_HUELLAS');
            open Inserta_Bitacora;
            fetch next Inserta_Bitacora into Campo;
        
            if(@@sqlstatus = 2) then
              print "No se encontró ningun Registro";
              close Inserta_Bitacora;
              return
            end if;
        
            while(@@sqlstatus = 0) loop
            
          SET Query = 'SELECT old_name.' + Trim(Campo) +',new_name.' + Trim(Campo) + ' INTO Valor_Anterior,Valor_Nuevo FROM DUMMY';
            EXECUTE IMMEDIATE Query;
        IF(Trim(Valor_Anterior) <> Trim(Valor_Nuevo)) THEN
            IF (Campo in ('ID_ROLUSR','NOMBRE_USR','ID_USR', 'TOKEN_ID')) THEN 
                    if  Campo = 'ID_ROLUSR' THEN   
                           set observacion ='Se cambio de rol';                                     
                    ELSEIF Campo = 'TOKEN_ID'   THEN 
                            set observacion ='Se cambio la informacion de acceso'; 
                            SET Valor_Anterior = '(NO_DATA)'; 
                            SET Valor_Nuevo = '(NO_DATA)';  
                    ELSE
                             set observacion =''; 
                    end if;
                
    
                    INSERT INTO "DBA"."HISTO_HUELLAS" ("HISTO_TABLA","HISTO_IDENTIFICADOR","HISTO_CAMPO","HISTO_VANTERIOR","HISTO_VACTUAL","HISTO_ACCION","HISTO_USR_ACCION","HISTO_FECHA_ACCION","HISTO_INFO_ADICIONAL","HISTO_OBSERVACION")
                    VALUES('USUARIOS_HUELLAS',old_name.ID_USR,Campo,Valor_Anterior,Valor_Nuevo,'U',current user,CURRENT TIMESTAMP ,(SELECT "DBA"."func_trae_info_sys"(3)),observacion);
            end if;
        END IF;
             fetch next Inserta_Bitacora into Campo;
               end loop;
               close Inserta_Bitacora;      
            end;
     
        
    end if; 
END;
COMMENT ON TRIGGER "DBA"."USUARIOS_HUELLAS"."TRG_UPDATE_USR" IS 'par update  usr';

/*#####################FIRMAS POR CUENTA###########################################################################*/
CREATE TABLE "DBA"."HISTO_HUELLAS" (
	"HISTO_ID" INTEGER NOT NULL DEFAULT AUTOINCREMENT UNIQUE,
	"HISTO_TABLA" VARCHAR(50) NULL,
	"HISTO_IDENTIFICADOR" VARCHAR(100) NULL,
	"HISTO_CAMPO" VARCHAR(50) NULL,
	"HISTO_VANTERIOR" VARCHAR(800) NULL,
	"HISTO_VACTUAL" VARCHAR(800) NULL,
	"HISTO_ACCION" CHAR(20) NULL,
	"HISTO_USR_ACCION" VARCHAR(50) NULL,
	"HISTO_FECHA_ACCION" TIMESTAMP NULL DEFAULT CURRENT TIMESTAMP,
	"HISTO_INFO_ADICIONAL" VARCHAR(500) NULL,
	"HISTO_OBSERVACION" VARCHAR(500) NULL,
	PRIMARY KEY ( "HISTO_ID" ASC )
) IN "system";
COMMENT ON TABLE "DBA"."HISTO_HUELLAS" IS 'HISTORICO EN CASO DE BORRAR HUELLAS';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_TABLA" IS 'TABLA DEL MODULO DE HUELLAS AFECTADO';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_IDENTIFICADOR" IS 'identificador de la fila afectada';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_CAMPO" IS 'CAMPO DE ALGUNA TABLA AFECTADA';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_VANTERIOR" IS 'VALOR ANTERIOR DE ESA TABLA';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_VACTUAL" IS 'VALOR ACTUAL TRAS LA ACCION DE UPDATE';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_ACCION" IS 'ACCION REALIZADA';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_USR_ACCION" IS 'USAURIO QUE REALIZO LA ACCION';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_FECHA_ACCION" IS 'FECHA EN QUE SE REALIZO LA ACCION ';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_INFO_ADICIONAL" IS 'INFORMACION ADICIONAL (DEL EQUIPO)';
COMMENT ON COLUMN "DBA"."HISTO_HUELLAS"."HISTO_OBSERVACION" IS 'en caso de eliminacion de una huella debera ir la justificacion';
/*#####################ROLES DE USUARIO DE HUELLA###########################################################################*/
CREATE TABLE "DBA"."FIRMAS_X_CUENTA" (
	"FXC_SEQ" INTEGER NOT NULL UNIQUE,
	"FXC_IDENTIDAD" VARCHAR(50) NULL,
	"FXC_CTA_AHO" VARCHAR(50) NULL,
	"FXC_TIPO_PERSONA" VARCHAR(10) NULL,
	"FXC_MANCOMUNADA" INTEGER NULL DEFAULT 0,
	"FXC_AGREGO" VARCHAR(50) NULL,
	"FXC_FECHA_AGREGO" "datetime" NULL DEFAULT CURRENT TIMESTAMP,
	"FXC_MOD" VARCHAR(50) NULL,
	"FXC_FECHA_MOD" "datetime" NULL,
	"FXC_IDEN_DEF" VARCHAR(50) NULL,
	"FXC_COMPANIA" INTEGER NULL,
	"FXC_FILIAL" INTEGER NULL,
	"FXC_PARENTEZCO" VARCHAR(50) NULL,
	PRIMARY KEY ( "FXC_SEQ" ASC )
) IN "system";
COMMENT ON TABLE "DBA"."FIRMAS_X_CUENTA" IS 'Tabla que almacena personas que estan relacionadas a una cuenta de ahorro.';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_SEQ" IS 'Indentificador unico';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_IDENTIDAD" IS 'Numero de indentidad de la persona relacionada a la cuenta';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_CTA_AHO" IS 'Numero de cuenta de ahorro';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_TIPO_PERSONA" IS 'Tipo de la persona, COOP = Cooperativista / DEF = Firma autorizada';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_MANCOMUNADA" IS 'Campo que identifica si la persona registrada mancomuna la cuenta de ahorro';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_AGREGO" IS 'Usuario que agrego';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_FECHA_AGREGO" IS 'fecha en que se agrego';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_MOD" IS 'Usuario que modifico';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_FECHA_MOD" IS 'Fecha en que se modifico';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_IDEN_DEF" IS 'Identificacion de registro si se trata de una Firma autorizada';
COMMENT ON COLUMN "DBA"."FIRMAS_X_CUENTA"."FXC_PARENTEZCO" IS 'QUE PARENTEZCO TIENE LA PERSONA DE ESTA FIRMA CON EL DUEÑO DE LA CUENTA';


CREATE TRIGGER "after_actauliza_identidad_firmas" AFTER UPDATE OF "FXC_IDENTIDAD"
ORDER 2 ON "DBA"."FIRMAS_X_CUENTA"
 REFERENCING OLD AS old_name NEW AS new_name 
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
DECLARE @contenido INTEGER ;
DECLARE @firma varchar (100);

--old_name.FXC_IDENTIDAD
--old_name.FXC_CTA_AHO

WITH  temporal AS(    
SELECT 'F1' as firma, Codigo_Cta_Aho as CTA, FIRMA1_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO 
    UNION
    SELECT 'F2' as firma, Codigo_Cta_Aho as CTA, FIRMA2_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
    UNION 
    SELECT 'F3' as firma, Codigo_Cta_Aho as CTA, FIRMA3_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
    UNION 
    SELECT 'F4' as firma, Codigo_Cta_Aho as CTA, FIRMA4_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
)


  SELECT COUNT(*) INTO @contenido FROM temporal where identidad =old_name.FXC_IDENTIDAD;
if  @contenido > 0 then
WITH  temporal AS(    
    SELECT 'F1' as firma, Codigo_Cta_Aho as CTA, FIRMA1_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO 
    UNION
    SELECT 'F2' as firma, Codigo_Cta_Aho as CTA, FIRMA2_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
    UNION 
    SELECT 'F3' as firma, Codigo_Cta_Aho as CTA, FIRMA3_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
    UNION 
    SELECT 'F4' as firma, Codigo_Cta_Aho as CTA, FIRMA4_AHO_IDEN AS IDENTIDAD FROM  dba.Firmas_Ahorro 
    WHERE Codigo_Cta_Aho = old_name.FXC_CTA_AHO
)
SELECT firma into @firma from temporal where identidad =old_name.FXC_IDENTIDAD;
    case   @firma 
    when 'F1' THEN
        update dba.Firmas_Ahorro set FIRMA1_AHO_IDEN = new_name.FXC_IDENTIDAD where FIRMA1_AHO_IDEN =old_name.FXC_IDENTIDAD;

    WHEN 'F2' THEN 
        update dba.Firmas_Ahorro set FIRMA2_AHO_IDEN = new_name.FXC_IDENTIDAD where FIRMA2_AHO_IDEN =old_name.FXC_IDENTIDAD;
    WHEN 'F3' THEN 
        update dba.Firmas_Ahorro set FIRMA3_AHO_IDEN = new_name.FXC_IDENTIDAD where FIRMA3_AHO_IDEN = old_name.FXC_IDENTIDAD;
    WHEN 'F4' THEN 
        update dba.Firmas_Ahorro set FIRMA4_AHO_IDEN = new_name.FXC_IDENTIDAD where FIRMA4_AHO_IDEN = old_name.FXC_IDENTIDAD;
    END CASE;
end if;
	/* Type the trigger statements here */
END;
COMMENT ON TRIGGER "DBA"."FIRMAS_X_CUENTA"."after_actauliza_identidad_firmas" IS 'actauliza la identidad en la tabla Firmas Ahorros';



CREATE TRIGGER "tgr_secuencial_fxc" BEFORE INSERT
ORDER 1 ON "DBA"."FIRMAS_X_CUENTA"
REFERENCING NEW AS new_name 
FOR EACH ROW  WHEN( current user <> 'DBA' and current user <> 'USR_SPS' ) 
BEGIN
  declare numero decimal(15);
  declare filial smallint;
  declare compania smallint;
  select USU_FILIAL,USU_COMPANIA into filial,compania from DBA.Usuarios where USU_CODIGO = current user;
  select func_llaves('FIRMAS_X_CUENTA.FXC_SEQ',filial) into numero from SYS.DUMMY;
  set new_name.FXC_SEQ=numero;
END;



