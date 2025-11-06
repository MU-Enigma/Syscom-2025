#!/bin/bash

stty -echo
tput civis


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'


player_hp=100
player_max_hp=100
player_gold=0
player_potions=2
player_attack=15
current_room=1
rooms_cleared=0
game_running=1

monsters=("Goblin" "Skeleton" "Zombie" "Spider" "Bat" "Orc" "Wraith" "Demon")
treasures=("Gold Coins" "Ruby" "Diamond" "Ancient Relic" "Magic Scroll")

# Cleanup on exit
cleanup() {
    tput cnorm
    stty echo
    clear
    echo -e "${GREEN}Thanks for playing Dungeon Escape!${NC}"
    echo -e "${YELLOW}Final Score: $((player_gold + rooms_cleared * 50))${NC}"
    exit 0
}

trap cleanup EXIT INT TERM

clear_screen() {
    clear
}

draw_border() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
}

draw_bottom() {
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}

draw_line() {
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
}

show_stats() {
    echo -e "${CYAN}║${NC} ${RED}HP: $player_hp/$player_max_hp${NC} ${YELLOW}│${NC} ${YELLOW}Gold: $player_gold${NC} ${YELLOW}│${NC} ${MAGENTA}Potions: $player_potions${NC} ${YELLOW}│${NC} ${GREEN}Room: $current_room${NC} ${CYAN}║${NC}"
}

draw_room() {
    local room_type=$1
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    
    case $room_type in
        "empty")
            echo -e "${CYAN}║${NC}              ${GRAY}An empty, dusty chamber...${NC}             ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                   ${GRAY}Nothing here.${NC}                      ${CYAN}║${NC}"
            ;;
        "monster")
            echo -e "${CYAN}║${NC}        ${RED}⚔  A wild $current_monster appears! ⚔${NC}         ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                  ${RED}HP: $monster_hp${NC}                        ${CYAN}║${NC}"
            ;;
        "treasure")
            echo -e "${CYAN}║${NC}           ${YELLOW}✦ You found a treasure chest! ✦${NC}           ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}              ${YELLOW}Inside: $current_treasure${NC}                ${CYAN}║${NC}"
            ;;
        "potion")
            echo -e "${CYAN}║${NC}            ${MAGENTA}⚗ A health potion sits here! ⚗${NC}           ${CYAN}║${NC}"
            ;;
        "exit")
            echo -e "${CYAN}║${NC}              ${GREEN}★ THE EXIT PORTAL! ★${NC}                  ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}            ${GREEN}You can escape the dungeon!${NC}             ${CYAN}║${NC}"
            ;;
    esac
    
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
}

show_options() {
    local options=$1
    echo -e "${CYAN}║${NC} ${WHITE}$options${NC}"
    
    # Pad the line to fit
    local len=${#options}
    local padding=$((58 - len))
    printf "%${padding}s" ""
    echo -e "${CYAN}║${NC}"
}

get_input() {
    local prompt=$1
    echo -e "${CYAN}║${NC} ${WHITE}$prompt${NC}"
    read -n1 choice
    echo "$choice"
}

roll_dice() {
    local max=$1
    echo $((RANDOM % max + 1))
}

combat() {
    monster_types=("Goblin" "Skeleton" "Zombie" "Spider" "Bat" "Orc")
    current_monster=${monster_types[$((RANDOM % ${#monster_types[@]}))]}
    monster_hp=$((30 + RANDOM % 40))
    local monster_attack=$((10 + RANDOM % 15))
    
    while [ $monster_hp -gt 0 ] && [ $player_hp -gt 0 ]; do
        clear_screen
        draw_border
        show_stats
        draw_line
        draw_room "monster"
        draw_line
        show_options "[A]ttack  [D]rink Potion  [R]un Away"
        draw_bottom
        
        read -n1 action
        
        case $action in
            a|A)
                local damage=$((player_attack + RANDOM % 10))
                monster_hp=$((monster_hp - damage))
                
                clear_screen
                draw_border
                echo -e "${CYAN}║${NC} ${GREEN}You strike for $damage damage!${NC}"
                [ $monster_hp -gt 0 ] && echo -e "${CYAN}║${NC} ${RED}The $current_monster hits back for $monster_attack damage!${NC}"
                draw_bottom
                sleep 1
                
                [ $monster_hp -gt 0 ] && player_hp=$((player_hp - monster_attack))
                ;;
            d|D)
                if [ $player_potions -gt 0 ]; then
                    local heal=40
                    player_hp=$((player_hp + heal))
                    [ $player_hp -gt $player_max_hp ] && player_hp=$player_max_hp
                    player_potions=$((player_potions - 1))
                    
                    clear_screen
                    draw_border
                    echo -e "${CYAN}║${NC} ${MAGENTA}Healed for $heal HP!${NC}"
                    echo -e "${CYAN}║${NC} ${RED}The $current_monster attacks for $monster_attack damage!${NC}"
                    draw_bottom
                    sleep 1
                    player_hp=$((player_hp - monster_attack))
                else
                    clear_screen
                    draw_border
                    echo -e "${CYAN}║${NC} ${RED}No potions left!${NC}"
                    draw_bottom
                    sleep 1
                fi
                ;;
            r|R)
                if [ $(roll_dice 100) -gt 50 ]; then
                    clear_screen
                    draw_border
                    echo -e "${CYAN}║${NC} ${GREEN}You escaped!${NC}"
                    draw_bottom
                    sleep 1
                    return 1
                else
                    clear_screen
                    draw_border
                    echo -e "${CYAN}║${NC} ${RED}Failed to escape! The $current_monster attacks!${NC}"
                    draw_bottom
                    sleep 1
                    player_hp=$((player_hp - monster_attack))
                fi
                ;;
        esac
        
        if [ $player_hp -le 0 ]; then
            clear_screen
            draw_border
            echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                   ${RED}YOU DIED!${NC}                           ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}              ${GRAY}The dungeon claims another...${NC}           ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
            draw_bottom
            sleep 2
            game_running=0
            return 1
        fi
    done
    
    if [ $monster_hp -le 0 ]; then
        local gold_reward=$((20 + RANDOM % 30))
        player_gold=$((player_gold + gold_reward))
        rooms_cleared=$((rooms_cleared + 1))
        
        clear_screen
        draw_border
        echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}              ${GREEN}Victory! Monster slain!${NC}                 ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}            ${YELLOW}+ $gold_reward gold collected${NC}                  ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
        draw_bottom
        sleep 2
    fi
    
    return 0
}

explore_room() {
    local event=$(roll_dice 100)
    
    if [ $current_room -eq 10 ]; then
        clear_screen
        draw_border
        show_stats
        draw_line
        draw_room "exit"
        draw_line
        show_options "[E]scape the dungeon!"
        draw_bottom
        
        read -n1 choice
        if [[ $choice == "e" ]] || [[ $choice == "E" ]]; then
            clear_screen
            draw_border
            echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}           ${GREEN}${BOLD}★ CONGRATULATIONS! ★${NC}                      ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}          ${GREEN}You escaped the dungeon alive!${NC}            ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}          ${YELLOW}Gold Collected: $player_gold${NC}                    ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}          ${GREEN}Rooms Cleared: $rooms_cleared${NC}                     ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}          ${CYAN}Final Score: $((player_gold + rooms_cleared * 50))${NC}          ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
            draw_bottom
            sleep 3
            game_running=0
        fi
        return
    fi
    
    if [ $event -le 50 ]; then
        combat
    elif [ $event -le 70 ]; then
        current_treasure=${treasures[$((RANDOM % ${#treasures[@]}))]}
        local gold_found=$((30 + RANDOM % 50))
        
        clear_screen
        draw_border
        show_stats
        draw_line
        draw_room "treasure"
        draw_line
        show_options "Press any key to collect..."
        draw_bottom
        
        read -n1
        player_gold=$((player_gold + gold_found))
        
        clear_screen
        draw_border
        echo -e "${CYAN}║${NC} ${YELLOW}+ $gold_found gold added!${NC}"
        draw_bottom
        sleep 1
    elif [ $event -le 85 ]; then
        clear_screen
        draw_border
        show_stats
        draw_line
        draw_room "potion"
        draw_line
        show_options "Press any key to take it..."
        draw_bottom
        
        read -n1
        player_potions=$((player_potions + 1))
        
        clear_screen
        draw_border
        echo -e "${CYAN}║${NC} ${MAGENTA}Potion added to inventory!${NC}"
        draw_bottom
        sleep 1
    else
        clear_screen
        draw_border
        show_stats
        draw_line
        draw_room "empty"
        draw_line
        show_options "Press any key to continue..."
        draw_bottom
        read -n1
    fi
}

show_intro() {
    clear_screen
    draw_border
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}${MAGENTA}╔═══════════════════════════╗${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}${MAGENTA}║   DUNGEON ESCAPE          ║${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}${MAGENTA}╚═══════════════════════════╝${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${GRAY}You awaken in a dark dungeon. Fight monsters,${NC}     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${GRAY}collect treasures, and find the exit to escape!${NC}   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${WHITE}Goal: Survive 10 rooms and reach the exit${NC}        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}              ${GREEN}Press any key to begin...${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    draw_bottom
    read -n1
}

# Main game loop
show_intro

while [ $game_running -eq 1 ]; do
    explore_room
    
    if [ $game_running -eq 1 ]; then
        current_room=$((current_room + 1))
        
        clear_screen
        draw_border
        echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}         ${CYAN}Moving to room $current_room...${NC}                       ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
        draw_bottom
        sleep 1
    fi
done

cleanup
