#!/bin/bash

active_symbol="X"
board=( "1" "2" "3" "4" "5" "6" "7" "8" "9" )
board_size=${#board[@]}
should_quit=0
turn=1

draw_field()
{
	clear
	for i in ${!board[*]}
	do
		printf " %c |" ${board[$i]}
		if [[ $((($i+1)%3)) -eq 0 ]]; then
		printf "\n------------\n"
		fi
	done
}

check_win()
{
	if [[ "${board[0]}" == $1 ]] && [[ "${board[1]}" == $1 ]] && [[ "${board[2]}" == $1 ]]; then return 1; fi
    if [[ "${board[3]}" == $1 ]] && [[ "${board[4]}" == $1 ]] && [[ "${board[5]}" == $1 ]]; then return 1; fi
    if [[ "${board[6]}" == $1 ]] && [[ "${board[7]}" == $1 ]] && [[ "${board[8]}" == $1 ]]; then return 1; fi

    if [[ "${board[0]}" == $1 ]] && [[ "${board[3]}" == $1 ]] && [[ "${board[6]}" == $1 ]]; then return 1; fi
    if [[ "${board[1]}" == $1 ]] && [[ "${board[4]}" == $1 ]] && [[ "${board[7]}" == $1 ]]; then return 1; fi
    if [[ "${board[2]}" == $1 ]] && [[ "${board[5]}" == $1 ]] && [[ "${board[8]}" == $1 ]]; then return 1; fi

    if [[ "${board[0]}" == $1 ]] && [[ "${board[4]}" == $1 ]] && [[ "${board[8]}" == $1 ]]; then return 1; fi
    if [[ "${board[2]}" == $1 ]] && [[ "${board[4]}" == $1 ]] && [[ "${board[6]}" == $1 ]]; then return 1; fi

	return 0
}

function game_loop
{
	clear
	printf "\ns - save game\nr - read previous game\ninput c to play with dumb AI\nany other ASCII key to continue\n"
	read is_ai
	draw_field

	while [[ $should_quit -eq 0 ]]
	do

		if [[ $(($turn % 2)) -eq 0 ]]; then
			active_symbol="Y"
			printf "%c choose move\n" $active_symbol
		else
			active_symbol="X"
			printf "%c choose move\n" $active_symbol
		fi

		if [[ $is_ai == "c" ]] && [[ $active_symbol == "X" ]]; then
			while 
				move=$((($RANDOM % 9) + 1))
				[[ "${board[$((move-1))]}" == "Y" ]] || [[ "${board[$((move-1))]}" == "X" ]]
			do true; done
		else
			read move
		fi

		if [[ "$move" == "s" ]]; then
			set | grep ^board= > save.sav
			cat <<< "active_symbol=$active_symbol" >> "save.sav"
			cat <<< "turn=$turn" >> "save.sav"
			cat <<< "is_ai=$is_ai" >> "save.sav"
		elif [[ "$move" == "r" ]] && [[ -f "save.sav" ]]; then
			source save.sav
		else
			move=$((move-1))

			while [[ ! $move =~ ^[0-9]+$ ]] || [[ $move -ge board_size ]] || [[ $move -lt 0 ]] || [[ "${board[$move]}" == "Y" ]] || [[ "${board[$move]}" == "X" ]]
			do
				draw_field
				printf "%c choose move\n" $active_symbol
				read move
				move=$((move-1))
			done

			board[$move]=$active_symbol
			check_win $active_symbol

			if [[ $? -eq 1 ]]; then
				draw_field
				printf "%c won\n" $active_symbol
				exit
			elif [[ turn -eq 9 ]]; then
				draw_field
				printf "Draw\n"
				exit
			fi

			turn=$((turn+1))
		fi

		draw_field
	done
}

game_loop