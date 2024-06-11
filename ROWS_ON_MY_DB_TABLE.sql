use MY_DB;

delimiter //
begin not atomic
  declare low int;
  declare high int;
  declare my_note varchar(100);
  declare my_int int;
  FOR ii IN 0..59
  DO
  set my_note=concat('I ',trim(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(substr(concat(md5(rand()),md5(rand()),md5(rand())),1,70),0,' '),1,' '),2,'m'),3,'q'),4,'r'),5,'v'),6,'w'),7,'j'),8,'p'),9,' '),'  ',' '),'  ',' ')),'.');
  insert into `MY_DB_TABLE` (NOTE) VALUES (my_note);
  select min(ID) into low from MY_DB_TABLE;
  select max(ID) into high from MY_DB_TABLE;
  set my_int=FLOOR(low + RAND() * (high - low + 1));
  set my_note=concat('U ',trim(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(substr(concat(md5(rand()),md5(rand()),md5(rand())),1,70),0,' '),1,' '),2,'g'),3,'h'),4,'i'),5,'k'),6,'t'),7,'x'),8,'z'),9,' '),'  ',' '),'  ',' ')),'.');
  update MY_DB_TABLE set NOTE=my_note, ROW_UPDATED=current_timestamp() where ID=my_int;
  DO SLEEP(1);
  END FOR;

end;
//
delimiter ;

