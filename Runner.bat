@ECHO OFF
SETLOCAL enabledelayedexpansion

GOTO :start_app

REM %~1 - array name
:array_struct
IF "%~1" == "" EXIT /b
SET %~1=%~1
SET /a %~1.length=0
EXIT /b

REM %~1 - array name
REM %~2 - item
:array_struct_add
IF "%~1" == "" EXIT /b
IF "%~2" == "" EXIT /b
SET %~1[!%~1.length!]=%~2
SET /a %~1.length+=1
EXIT /b

REM %~1 - array name
REM %~2 - index
:array_struct_remove
IF "%~1" == "" EXIT /b
SET /a max_length=!%~1.length!-1
IF %~2 gtr %max_length% EXIT /b
IF %~2 lss 0 EXIT /b
SET /a index=%~2
FOR /l %%i IN (%~2,1,!%~1.length!) DO (
  SET %~1[!index!]=!%~1[%%i]!
  SET /a index=%%i
)
SET /a %~1.length-=1
CALL SET %~1[%%%~1.length%%]=
EXIT /b

REM %~1 - array name
REM %~2 - index
REM %~3 - item
:array_struct_replace
IF "%~1" == "" EXIT /b
SET /a max_length=!%~1.length!-1
IF %~2 gtr %max_length% EXIT /b
IF %~2 lss 0 EXIT /b
IF "%~3" == "" EXIT /b
SET %~1[%~2]=%~3
EXIT /b

:start_app
SET "key_listener="
SET player=O
SET obstacle=X
SET platform=-
SET safe_area=.
SET /a player_health=1
SET /a player_position=1
SET /a player_jumping=0
SET /a score=0
CALL :array_struct row1
CALL :array_struct row2
CALL :array_struct row3
CALL :array_struct row4
CALL :array_struct row5
CALL :array_struct row6
CALL :array_struct row7
CALL :array_struct row8
CALL :array_struct all_rows
CALL :array_struct next_rows_elements
CALL :initiate_rows

:pre_game
CLS
ECHO WITAJ W GRZE RUNNER
ECHO\
ECHO wybierz operacje:
ECHO 1-zagraj
ECHO 2-wyjdz
SET /a choice=0
SET /p "choice=numer:"
IF %choice% == 1 (
  CALL :start_RunnerListener
  GOTO :in_game
)
IF %choice% == 2 GOTO :end_app
GOTO :pre_game

:in_game
CLS
CALL :update_rows
CALL :check_jump
CALL :jump
CALL :check_collision
IF !player_health! lss 1 GOTO :post_game
CALL :draw_rows
SET /a score=%score%+1
ECHO %score%
GOTO :in_game

:post_game
ECHO "game over"
ECHO "twoj wynik = %score%"
PAUSE
GOTO :start_app

:update_rows
CALL :clear_obstacles
SET /a random_number = %random% %% 10
IF %random_number% gtr 6 (CALL :instantiate_obstacles 2)
IF %random_number% lss 2 (CALL :shuffle next_rows_elements)
SET /a iterations_max = !all_rows.length! - 1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  CALL :array_struct_add !all_rows[%%i]! !next_rows_elements[%%i]!
  CALL :array_struct_remove !all_rows[%%i]! 0
)
EXIT /b

REM %~1 - number of obstacles
:instantiate_obstacles
SET /a iterations_max = !next_rows_elements.length! / 2 - 1
IF %~1 gtr %iterations_max% EXIT /b
IF %~1 lss 1 EXIT /b
CALL :array_struct safe_area_positions
SET /a iterations_max = !next_rows_elements.length! - 1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  IF "!next_rows_elements[%%i]!" == "%safe_area%" (
    CALL :array_struct_add safe_area_positions %%i
  )
)
CALL :shuffle safe_area_positions
SET /a iterations_max = %~1 - 1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  CALL :array_struct_replace %next_rows_elements% !safe_area_positions[%%i]! %obstacle%
)
EXIT /b

:clear_obstacles
SET /a iterations_max = !next_rows_elements.length! - 1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  IF "!next_rows_elements[%%i]!" == "%obstacle%" (
    CALL :array_struct_replace %next_rows_elements% %%i %safe_area%
  )
)
EXIT /b

:check_collision
SET row_to_check=!all_rows[%player_position%]!
IF NOT !%row_to_check%[0]! == %safe_area% (
  SET /a player_health-=1
)
EXIT /b

:check_jump
set /p key_listener=<keystroke.txt
IF NOT "!key_listener!" == "j" EXIT /b
SET /a row_index = %player_position% - 1
SET row_to_check=!all_rows[%row_index%]!
IF !%row_to_check%[0]! == %platform% (SET /a player_jumping+=1)
SET /a row_index = %player_position% + 1
SET row_to_check=!all_rows[%row_index%]!
IF !%row_to_check%[0]! == %platform% (SET /a player_jumping-=1)
break>"keystroke.txt"
SET "key_listener="
IF !player_jumping! == 0 CALL :start_RunnerListener
EXIT /b

:jump
IF %player_jumping% == 0 EXIT /b
SET /a row_index = %player_position% + %player_jumping%
SET row_to_check=!all_rows[%row_index%]!
IF !%row_to_check%[0]! == %platform% (
  SET /a player_jumping=0
  CALL :start_RunnerListener
)
SET /a player_position+=%player_jumping%
EXIT /b

:start_RunnerListener
START "" RunnerListener.bat
EXIT /b

REM %~1 - array name
:draw_row
IF "%~1" == "" EXIT /b
SET row_to_draw=I
SET /a iterations_max=!%~1.length!-1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  CALL SET row_to_draw=!row_to_draw!!%~1[%%i]!
)
ECHO %row_to_draw%
EXIT /b

:draw_rows
CALL :array_struct_replace !all_rows[%player_position%]! 0 %player%
FOR /l %%i IN (1,1,!all_rows.length!) DO (
  CALL :draw_row row%%i
)
EXIT /b

:initiate_rows
FOR /l %%i IN (1,1,20) DO (
  CALL :array_struct_add row1 %platform%
  CALL :array_struct_add row2 %safe_area%
  CALL :array_struct_add row3 %safe_area%
  CALL :array_struct_add row4 %safe_area%
  CALL :array_struct_add row5 %safe_area%
  CALL :array_struct_add row6 %safe_area%
  CALL :array_struct_add row7 %safe_area%
  CALL :array_struct_add row8 %platform%
)
CALL :array_struct_add all_rows row1
CALL :array_struct_add all_rows row2
CALL :array_struct_add all_rows row3
CALL :array_struct_add all_rows row4
CALL :array_struct_add all_rows row5
CALL :array_struct_add all_rows row6
CALL :array_struct_add all_rows row7
CALL :array_struct_add all_rows row8
SET /a iterations_max=!all_rows.length!-2
CALL :array_struct_add next_rows_elements %platform%
FOR /l %%i IN (1,1,%iterations_max%) DO (
  CALL :array_struct_add next_rows_elements %safe_area%
)
CALL :array_struct_add next_rows_elements %platform%
EXIT /b

REM %~1 - array name
:shuffle
IF "%~1" == "" EXIT /b
CALL :array_struct temp_array
SET /a iterations_max=!%~1.length!-1
FOR /l %%i IN (0,1,%iterations_max%) DO (
  CALL :array_struct_add temp_array !%~1[%%i]!
)
FOR /l %%i IN (0,1,%iterations_max%) DO (
  SET /a random_position = %random% %% !temp_array.length!
  CALL SET %~1[%%i]=%%temp_array[!random_position!]%%
  CALL :array_struct_remove temp_array !random_position!
)
EXIT /b

:end_app
EXIT